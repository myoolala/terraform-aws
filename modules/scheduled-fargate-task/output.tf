output "container_sg" {
  value = aws_security_group.service.id
}

output "ecr_repo" {
  value = var.create_ecr_repo ? aws_ecr_repository.service_repo[0].repository_url : "N/A"
}

output "ecr_arn" {
  value = var.create_ecr_repo ? aws_ecr_repository.service_repo[0].arn : "N/A"
}

output "cluster_arn" {
  value = var.cluster.create ? aws_ecs_cluster.cluster[0].arn : var.cluster.arn
}