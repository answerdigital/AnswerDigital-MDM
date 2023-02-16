provider "aws" {
  region = "eu-west-2"
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "mdm_vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true

  tags = {
    Name = "mdm_vpc"
  }
}

resource "aws_internet_gateway" "mdm_igw" {
  vpc_id = aws_vpc.mdm_vpc.id

  tags = {
    Name = "mdm_igw"
  }
}

resource "aws_subnet" "mdm_public_subnet" {
  count             = var.subnet_count.public
  cidr_block        = var.public_subnet_cidr_blocks[count.index]
  vpc_id            = aws_vpc.mdm_vpc.id
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "mdm_public_subnet_${count.index}"
  }
}

resource "aws_subnet" "mdm_private_subnet" {
  count             = var.subnet_count.private
  vpc_id            = aws_vpc.mdm_vpc.id
  cidr_block        = var.private_subnet_cidr_blocks[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "mdm_private_subnet_${count.index}"
  }
}

resource "aws_route_table" "mdm_public_rt" {
  vpc_id = aws_vpc.mdm_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.mdm_igw.id
  }
}

resource "aws_route_table_association" "public" {
  count          = var.subnet_count.public
  route_table_id = aws_route_table.mdm_public_rt.id
  subnet_id      = aws_subnet.mdm_public_subnet[count.index].id
}

resource "aws_route_table" "mdm_private_rt" {
  vpc_id = aws_vpc.mdm_vpc.id
}

resource "aws_route_table_association" "private" {
  count          = var.subnet_count.private
  route_table_id = aws_route_table.mdm_private_rt.id
  subnet_id      = aws_subnet.mdm_private_subnet[count.index].id
}

resource "aws_rds_cluster" "postgres_cluster" {
  cluster_identifier      = "aurora-cluster-mdm"
  engine                  = "aurora-postgresql"
  engine_mode             = "global"
  availability_zones      = [var.az_west_a, var.az_west_b]
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
  count = 1
  cluster_identifier = aws_rds_cluster.postgres_cluster.id
  instance_class     = "db.t3.medium"
  availability_zone  = var.az_west_a

  engine              = aws_rds_cluster.postgres_cluster.engine
  engine_version      = aws_rds_cluster.postgres_cluster.engine_version
  publicly_accessible = false
}
resource "aws_rds_cluster_instance" "postgres_secondary_instance" {
  identifier         = "mdm-postgresdb-secondary"
  count = 1
  cluster_identifier = aws_rds_cluster.postgres_cluster.id
  instance_class     = "db.t3.medium"
  availability_zone  = var.az_west_b

  engine              = aws_rds_cluster.postgres_cluster.engine
  engine_version      = aws_rds_cluster.postgres_cluster.engine_version
  publicly_accessible = false
}

resource "aws_security_group" "mdm_api_sg" {
  name        = "mdm_api_sg"
  description = "Security group for tutorial web servers"
  vpc_id      = aws_vpc.mdm_vpc.id

  ingress {
    from_port   = var.http_server_port
    protocol    = "tcp"
    to_port     = var.http_server_port
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = var.ssh_server_port
    to_port     = var.ssh_server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "mdm_api_sg"
  }
}

resource "aws_security_group" "mdm_db_sg" {
  name        = "mdm_db_sg"
  description = "Security group for database"

  vpc_id = aws_vpc.mdm_vpc.id

  ingress {
    description     = "Allow DB traffic from only the web sg"
    from_port       = var.db_port
    protocol        = "tcp"
    to_port         = var.db_port
    security_groups = [aws_security_group.mdm_api_sg.id]
  }

  tags = {
    Name = "mdm_db_sg"
  }

}

resource "aws_db_subnet_group" "mdm_db_subnet_group" {
  name        = "mdm_db_subnet_group"
  description = "DB subnet group"
  subnet_ids  = [for subnet in aws_subnet.mdm_private_subnet : subnet.id]
}

