output "application_name" {
  description = "Name of the Elastic Beanstalk application."
  value       = aws_elastic_beanstalk_application.this.name
}

output "environment_name" {
  description = "Name of the Elastic Beanstalk environment."
  value       = aws_elastic_beanstalk_environment.this.name
}

output "application_version_label" {
  description = "Label of the deployed application version."
  value       = aws_elastic_beanstalk_application_version.this.name
}

output "s3_bucket" {
  description = "S3 bucket containing the application bundle."
  value       = local.s3_bucket
}

output "s3_key" {
  description = "S3 key of the application bundle."
  value       = local.s3_key
}
