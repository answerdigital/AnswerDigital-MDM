
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

output "mdm-elb-dns" {
  value = aws_elb.mdm_elb.dns_name
}