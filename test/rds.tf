resource "aws_rds_cluster" "postgres_cluster" {
  cluster_identifier      = "aurora-cluster-mdm"
  engine                  = "aurora-postgresql"
  engine_mode             = "provisioned"
  availability_zones      = [var.az_west_a, var.az_west_b, var.az_west_c]
  database_name           = var.db_name
  master_username         = var.db_username
  master_password         = var.db_password
  backup_retention_period = 5
  skip_final_snapshot     = true
  preferred_backup_window = "07:00-09:00"
  db_subnet_group_name    = aws_db_subnet_group.mdm_db_subnet_group.id
  vpc_security_group_ids  = [aws_security_group.mdm_db_sg.id]

  tags = {
    Name = "mdm-rds-cluster"
  }
}

resource "aws_rds_cluster_instance" "postgres_primary_instance" {
  identifier         = "mdm-postgresdb-primary"
  count              = 1
  cluster_identifier = aws_rds_cluster.postgres_cluster.id
  instance_class     = "db.t3.medium"
  availability_zone  = var.az_west_a


  engine         = aws_rds_cluster.postgres_cluster.engine
  engine_version = aws_rds_cluster.postgres_cluster.engine_version
  preferred_maintenance_window = "sun:04:00-sun:05:00"

  publicly_accessible = false
}
resource "aws_rds_cluster_instance" "postgres_secondary_instance" {
  depends_on         = [aws_rds_cluster_instance.postgres_primary_instance]
  identifier         = "mdm-postgresdb-secondary"
  count              = 1
  cluster_identifier = aws_rds_cluster.postgres_cluster.id
  instance_class     = "db.t3.medium"
  availability_zone  = var.az_west_b

  engine         = aws_rds_cluster.postgres_cluster.engine
  engine_version = aws_rds_cluster.postgres_cluster.engine_version

  publicly_accessible = false
}

resource "aws_db_cluster_snapshot" "auroradb_snapshot" {
  db_cluster_identifier          = aws_rds_cluster.postgres_cluster.id
  db_cluster_snapshot_identifier = "${var.db_name}-db"
}