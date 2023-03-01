provider "aws" {
  region = "eu-west-2"
}

data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc_subnet" {
  source              = "git::https://github.com/AnswerConsulting/AnswerKing-Infrastructure.git//Terraform_modules/vpc_subnets?ref=v1.1.1"
  owner               = "Mauro"
  project_name        = "mauro-data-mapper"
  azs                  = [
    data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1],
    data.aws_availability_zones.available.names[2]
  ]
  num_public_subnets  = 2
  num_private_subnets = 3
  enable_vpc_flow_logs  = true
}

resource "aws_security_group" "mdm_api_sg" {
  name        = "mdm_api_sg"
  description = "Security group for tutorial web servers"
  vpc_id      = module.vpc_subnet.vpc_id

  ingress {
    from_port   = var.http_server_port
    protocol    = var.network_protocol
    to_port     = var.http_server_port
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = var.ssh_server_port
    to_port     = var.ssh_server_port
    protocol    = var.network_protocol
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = var.https_server_port
    to_port     = var.https_server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = var.domain_http_server_port
    to_port     = var.domain_http_server_port
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

resource "aws_security_group" "ecs_service_sg" {
  name_prefix = "ecs_service_sg"
  vpc_id      = module.vpc_subnet.vpc_id

  ingress {
    description     = "Allow traffic to ecs only from the web sg"
    from_port       = var.container_internal_port
    to_port         = var.container_internal_port
    protocol        = "tcp"
    security_groups = [aws_security_group.mdm_api_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "mdm_db_sg" {
  name        = "mdm_db_sg"
  description = "Security group for database"

  vpc_id = module.vpc_subnet.vpc_id

  ingress {
    description     = "Allow DB traffic from only the web sg"
    from_port       = var.db_port
    protocol        = var.network_protocol
    to_port         = var.db_port
    security_groups = [aws_security_group.mdm_api_sg.id, aws_security_group.ecs_service_sg.id]
  }

  tags = {
    Name = "mdm_db_sg"
  }

}

resource "aws_db_subnet_group" "mdm_db_subnet_group" {
  name        = "mdm_db_subnet_group"
  description = "DB subnet group"
  subnet_ids  = [for subnet in module.vpc_subnet.private_subnet_ids : subnet]
}

