output "arn" {
  value = aws_dynamodb_table.this.arn
}

output "id" {
  value = aws_dynamodb_table.this.id
}

output "replica_arns" {
  value = aws_dynamodb_table.this.replica[*].arn
}