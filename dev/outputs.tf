
output "s3_bucket_arn" {
  value = aws_s3_bucket.mdm_mauro_terraform_state.arn
  description = "The ARN of the S3 bucket"
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.mdm_tf_locks.name
  description = "The name of the DynamoDB table"
}

output "database_endpoint" {
  description = "The endpoint of the database"
  value       = aws_rds_cluster_instance.postgres_primary_instance[0].endpoint
}

output "secondary_database_endpoint" {
  description = "The endpoint of secondary database"
  value       = aws_rds_cluster_instance.postgres_secondary_instance[0].endpoint
}

output "database_port" {
  description = "The port of the database"
  value       = aws_rds_cluster.postgres_cluster.port
}

output "mdm-alb-dns" {
  value = aws_lb.mdm_lb.dns_name
}