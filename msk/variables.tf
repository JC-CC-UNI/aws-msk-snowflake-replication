variable "region" {
  description = "AWS Region"
  type        = string
}

variable "environment" {
  description = "Environment"
  type        = string
}

variable "vpc_id" {
  description = "VPC id"
  type        = string
}

variable "key_name" {
  description = "EC2 instance SSH key name"
  type        = string
}

variable "kafka_version" {
  description = "Kafka version"
  type        = string
}

variable "kafka_node_count" {
  description = "Number of broker nodes in Kafka cluster"
  type        = string
}

variable "kafka_instance_type" {
  description = "Instance type of Kafka nodes"
  type        = string
}

variable "ebs_volume_size" {
  description = "EBS volume size for Kafka nodes"
  type        = string
}

variable "ebs_provisioned_throughput_enabled" {
  description = "Enable provisioned throughput on EBS volumes on Kafka Nodes"
  type        = string
}

variable "ebs_provisioned_volume_throughput" {
  description = "Throughput value of the EBS volumes for the data drive on each kafka broker node in MiB per second"
  type        = string
}

variable "kafka_default_replication_factor" {
  description = "Replication factor for auto created topics"
  type        = string
}

variable "kafka_num_partitions" {
  description = "Number of partitions for auto created topics"
  type        = string
}