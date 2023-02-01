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
    Name = "tutorial_private_subnet_${count.index}"
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

resource "aws_eip" "mdm_eip" {
  count    = 1
  instance = aws_instance.mdm_java[count.index].id
  vpc      = true
  tags = {
    Name = "mdm_eip_${count.index}"
  }
}

resource "aws_instance" "mdm_java" {
  count                  = 1
  ami                    = "ami-084e8c05825742534"
  instance_type          = "t2.large"
  subnet_id              = aws_subnet.mdm_public_subnet[count.index].id
  vpc_security_group_ids = [aws_security_group.mdm_api_sg.id]
  key_name               = aws_key_pair.generated_key.key_name


  user_data = <<-EOF
                #!/bin/bash

                set -e
                # Output all log
                exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
                # Make sure we have all the latest updates when we launch this instance
                yum update -y && yum upgrade -y
                # Install components
                yum install -y docker
                yum install -y git

                # Add credential helper to pull from ECR
                mkdir -p ~/.docker && chmod 0700 ~/.docker
                # Start docker now and enable auto start on boot
                service docker start && chkconfig docker on
                # Allow the ec2-user to run docker commands without sudo
                usermod -a -G docker ec2-user
                # Run application at start
                git clone https://github.com/MauroDataMapper/mdm-docker.git
                cd mdm-docker

                # install docker compose
                curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
                sudo chmod +x /usr/local/bin/docker-compose

                # run docker containers based on the built docker compose images
                docker-compose build
                docker network create -d bridge mdm-network
                # docker run -d -v postgres12:/var/lib/postgresql/data --name postgres --shm-size 512mb --network mdm-network -e POSTGRES_PASSWORD=postgresisawesome maurodatamapper/postgres:12.0-alpine
                # docker run -d --network mdm-network -p 8082:8080 -e PGPASSWORD=postgresisawesome -e runtime.config.path=/usr/local/tomcat/conf/runtime.yml maurodatamapper/mauro-data-mapper:2022.3
                # docker container run --name answer-king-rest-api-container  --restart=always --name answer-king-rest-api-container -e "RDS_USERNAME=${var.db_username}" -e "RDS_PASSWORD=${var.db_password}" -e "RDS_HOSTNAME=${aws_rds_cluster.postgres_cluster.endpoint}" -e "RDS_PORT=${var.db_port}" -e "RDS_DB_NAME=${var.db_name}" -e "MYSQLDB_PASSWORD=${var.db_password}" -e "MYSQLDB_USER=${var.db_username}" -e "MYSQL_URL=jdbc:mysql://${aws_rds_cluster.postgres_cluster.endpoint}:${var.db_port}/${var.db_name}" -p ${var.http_server_port}:${var.http_server_port} -d ghcr.io/answerconsulting/answerking-java/answer-king-rest-api_app:latest
                EOF

  user_data_replace_on_change = true
  tags = {
    Name = "mdm-app"
  }
}

resource "aws_rds_cluster" "postgres_cluster" {
  cluster_identifier      = "aurora-cluster-mdm"
  engine                  = "aurora-postgresql"
  availability_zones      = ["eu-west-2a"]
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

resource "aws_rds_cluster_instance" "postgres_instances" {
  identifier = "mdm-postgresdb-${count.index}"
  count = 1
  cluster_identifier = aws_rds_cluster.postgres_cluster.id
  instance_class     = "db.t3.medium"

  engine             = aws_rds_cluster.postgres_cluster.engine
  engine_version     = aws_rds_cluster.postgres_cluster.engine_version
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
    description     = "Allow MySQL traffic from only the web sg"
    from_port       = "3306"
    protocol        = "tcp"
    to_port         = "3306"
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

resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = var.ec2_key_name
  public_key = tls_private_key.example.public_key_openssh
}
