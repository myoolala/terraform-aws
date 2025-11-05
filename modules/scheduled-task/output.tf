output "container_sg" {
  value = aws_security_group.service.id
  description = "Security Group for the container"
}

output "ecr_repo" {
  value = var.create_ecr_repo ? aws_ecr_repository.service_repo[0].repository_url : "N/A"
  description = "Repository URL for the ECR Repo if one was created"
}

output "ecr_arn" {
  value = var.create_ecr_repo ? aws_ecr_repository.service_repo[0].arn : "N/A"
  description = "ARN for the ECR Repo if one was created"
}

output "cluster_arn" {
  value = var.cluster.create ? aws_ecs_cluster.cluster[0].arn : var.cluster.arn
  description = "ARN for the ECS cluster"
}