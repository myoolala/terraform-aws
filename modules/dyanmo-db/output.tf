output "arn" {
  value = aws_dynamodb_table.this.arn
  description = "ARN of the DDB table"
}

output "id" {
  value = aws_dynamodb_table.this.id
  description = "ID for the DDB table"
}

output "replica_arns" {
  value = aws_dynamodb_table.this.replica[*].arn
  description = "List of ARNs for the replica tables if there are any"
}