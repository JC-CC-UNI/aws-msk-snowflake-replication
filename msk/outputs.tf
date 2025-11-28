output "private_subnet_ids" {
  value = data.aws_subnets.private_subnets.ids
}

output "msk_security_group_id" {
  value = aws_security_group.msk_security_group.id
}

output "msk_cluster" {
  value = aws_msk_cluster.msk_cluster
}
