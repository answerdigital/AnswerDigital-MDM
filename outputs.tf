output "public_ip" {
  description = "The public IP address of the web server"
  value       = aws_eip.mdm_eip[0].public_ip
  depends_on  = [aws_eip.mdm_eip]
}

output "web_public_dns" {
  description = "The public DNS address of the web server"
  value       = aws_eip.mdm_eip[0].public_dns
  depends_on  = [aws_eip.mdm_eip]
}

output "database_endpoint" {
  description = "The endpoint of the database"
  value       = aws_rds_cluster_instance.postgres_primary_instance[0].endpoint
}

output "database_port" {
  description = "The port of the database"
  value       = aws_rds_cluster.postgres_cluster.port
}