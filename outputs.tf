
output "web_public_dns" {
  description = "The public DNS address of the web server"
  value       = aws_alb.eip_lb.dns_name
  depends_on  = [aws_alb.eip_lb]
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