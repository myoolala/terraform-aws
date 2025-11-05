output "task_definition_arn" {
  value = aws_ecs_task_definition.service.arn
  description = "ARN of the new Task Definition"
}