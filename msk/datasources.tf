data "aws_subnets" "private_subnets" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
  filter {
    name   = "tag:Name"
    values = ["dev-private-1", "dev-private-2"]
  }
}

data "aws_subnets" "public_subnets" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
  filter {
    name   = "tag:Name"
    values = ["dev-public-1", "dev-public-2"]
  }
}

locals {
  common_tags = {
    Initiative  = "Analytics"
    Component   = "MSK"
    Environment = var.environment
  }
}


