terraform {
  backend "s3" {
    bucket = "qsi-snowconnect-jlca"
    key    = "msk/dev/terraform.tfstate"
    region = "us-east-1"
  }
  required_version = ">= 1.4.2, < 2.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.60.0"
    }
  }
}

provider "aws" {
  region = var.region
}


resource "aws_security_group" "msk_security_group" {
  name        = "msk-cluster-security-group-${var.environment}"
  description = "Allow MSK inbound traffic"
  vpc_id      = var.vpc_id

  tags = merge(
    local.common_tags
  )
}

resource "aws_vpc_security_group_ingress_rule" "msk_plaintext_ingress_rule" {
  security_group_id = aws_security_group.msk_security_group.id

  description                  = "PLAINTEXT"
  referenced_security_group_id = aws_security_group.msk_security_group.id
  from_port                    = 9092
  ip_protocol                  = "tcp"
  to_port                      = 9092

  tags = merge(
    local.common_tags
  )
}

resource "aws_vpc_security_group_ingress_rule" "msk_zookeeper_ingress_rule" {
  security_group_id = aws_security_group.msk_security_group.id

  description                  = "Zookeeper"
  referenced_security_group_id = aws_security_group.msk_security_group.id
  from_port                    = 2182
  ip_protocol                  = "tcp"
  to_port                      = 2182

  tags = merge(
    local.common_tags
  )
}

resource "aws_vpc_security_group_egress_rule" "msk_egress_rule" {
  security_group_id = aws_security_group.msk_security_group.id

  description = "All Traffic"
  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"

  tags = merge(
    local.common_tags
  )
}

resource "aws_cloudwatch_log_group" "msk_cloudwatch_log_group" {
  name              = "msk-cluster-${var.environment}-logs"
  retention_in_days = 14

  tags = merge(
    local.common_tags
  )
}

resource "aws_msk_configuration" "msk_cluster_configuration" {
  kafka_versions = [var.kafka_version]
  name           = "msk-cluster-configuration-${var.environment}"

  server_properties = <<PROPERTIES
auto.create.topics.enable = true
delete.topic.enable = true
default.replication.factor = ${var.kafka_default_replication_factor}
num.partitions = ${var.kafka_num_partitions}
PROPERTIES
}

resource "aws_msk_cluster" "msk_cluster" {
  cluster_name           = "msk-cluster-${var.environment}"
  kafka_version          = var.kafka_version
  number_of_broker_nodes = var.kafka_node_count

  broker_node_group_info {
    instance_type  = var.kafka_instance_type
    client_subnets = data.aws_subnets.public_subnets.ids
    storage_info {
      ebs_storage_info {
        volume_size = var.ebs_volume_size
        dynamic "provisioned_throughput" {
          for_each = var.ebs_provisioned_throughput_enabled ? ["go"] : []

          content {
            enabled           = true
            volume_throughput = var.ebs_provisioned_volume_throughput
          }
        }

      }
    }
    security_groups = [aws_security_group.msk_security_group.id]
  }

  client_authentication {
    unauthenticated = true
  }

  encryption_info {
    # Encryption at rest (Using AWS managed KMS ('aws/msk' managed service) key)
    encryption_in_transit {
      client_broker = "PLAINTEXT"
      in_cluster    = true
    }
  }

  logging_info {
    broker_logs {
      cloudwatch_logs {
        enabled   = true
        log_group = aws_cloudwatch_log_group.msk_cloudwatch_log_group.name
      }
    }
  }

  configuration_info {
    arn      = aws_msk_configuration.msk_cluster_configuration.arn
    revision = aws_msk_configuration.msk_cluster_configuration.latest_revision
  }

  tags = merge(
    local.common_tags
  )
}

resource "aws_security_group" "msk_client_security_group" {
  name        = "msk-client-security-group-${var.environment}"
  description = "Allow MSK client inbound traffic"
  vpc_id      = var.vpc_id

  tags = merge(
    local.common_tags
  )
}

resource "aws_vpc_security_group_ingress_rule" "msk_client_ssh_ingress_rule" {
  security_group_id = aws_security_group.msk_client_security_group.id

  description = "SSH"
  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22

  tags = merge(
    local.common_tags
  )
}

resource "aws_vpc_security_group_egress_rule" "msk_client_egress_rule" {
  security_group_id = aws_security_group.msk_client_security_group.id

  description = "All Traffic"
  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"

  tags = merge(
    local.common_tags
  )

}

resource "aws_instance" "msk_client" {
  ami                         = "ami-04581fbf744a7d11f"
  instance_type               = "t2.micro"
  key_name                    = var.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.msk_security_group.id, aws_security_group.msk_client_security_group.id]
  subnet_id                   = data.aws_subnets.public_subnets.ids[0]
  user_data                   = file("init_no_client_auth_encrypt.sh")

  tags = merge(
    local.common_tags,
    tomap({
      Name = "msk-client-${var.environment}"
    })
  )
}
