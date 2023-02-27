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
  azs                 = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1]]
  num_public_subnets  = 2
  num_private_subnets = 3
  enable_vpc_flow_logs  = true
}

resource "aws_lb_target_group" "mdm_target_group" {
  name = "mdm-app-front"
  port = var.http_server_port
  protocol = var.http_protocol
  vpc_id = module.vpc_subnet.vpc_id

  stickiness {
    enabled = true
    type = "lb_cookie"
    cookie_name = "mdm_cookie"
  }

  health_check {
    enabled = true
    healthy_threshold = 3
    interval = 10
    matcher = 200
    path  = "/"
    port  = "traffic-port"
    protocol = var.http_protocol
    timeout = 3
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group_attachment" "attach-app1" {
  target_group_arn = aws_lb_target_group.mdm_target_group.arn
  target_id        = aws_instance.mdm_app1[0].id
  port  = var.http_server_port
}

resource "aws_lb_target_group_attachment" "attach-app2" {
  target_group_arn = aws_lb_target_group.mdm_target_group.arn
  target_id        = aws_instance.mdm_app2[0].id
  port  = var.http_server_port
}

resource "aws_lb" "mdm_lb" {
  name = "mdm-app-lb"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.mdm_api_sg.id]
  subnets = [module.vpc_subnet.public_subnet_ids[0], module.vpc_subnet.public_subnet_ids[1]]

  enable_deletion_protection = true

  tags = {
    Name = "mdm-app-lb"
  }
}

resource "aws_lb_listener" "mdm_lb_listener" {
  load_balancer_arn = aws_lb.mdm_lb.arn
  port  = var.http_server_port
  protocol = var.http_protocol

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"

    }
  }
}

resource "aws_lb_listener" "mdm_lb_listener3" {
  load_balancer_arn = aws_lb.mdm_lb.arn
  port  = 80
  protocol = var.http_protocol

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"

    }
  }
}

resource "aws_lb_listener" "mdm_lb_listener2" {
  load_balancer_arn = aws_lb.mdm_lb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mdm_target_group.arn
  }
}

resource "aws_instance" "mdm_app1" {
  count                  = 1
  ami                    = "ami-084e8c05825742534"
  instance_type          = "t2.large"
  subnet_id              = module.vpc_subnet.public_subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.mdm_api_sg.id]
  key_name               = var.ssh_key
  associate_public_ip_address = true

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
                git clone -b develop https://github.com/MauroDataMapper/mdm-docker.git

                cd mdm-docker
                # clears postgres image, volume and dependancy on mauro-data-mapper image
                sed -i '3,11d;28d;29d;39d;40d' docker-compose.yml

                # install docker compose
                curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
                sudo chmod +x /usr/local/bin/docker-compose

                # run docker containers based on the built docker compose images
                docker network create -d bridge mdm-network
                docker-compose build --no-cache --progress=plain --build-arg MDM_APPLICATION_COMMIT=develop --build-arg MDM_UI_COMMIT=develop --build-arg MDM_UI_THEME_NAME="nhs-digital" --build-arg ADDITIONAL_PLUGINS="${var.mdm_plugins_dev-test}"
                docker run -d --network mdm-network -p ${var.http_server_port}:8080 -e maurodatamapper.authority.name="${var.mdm_authority_name}" -e maurodatamapper.authority.url="${var.mdm_domain_url}" -e DATABASE_PASSWORD=${var.db_password} -e DATABASE_USERNAME=${var.db_username} -e DATABASE_HOST=${aws_rds_cluster_instance.postgres_primary_instance[0].endpoint} -e database.host=${aws_rds_cluster_instance.postgres_primary_instance[0].endpoint} -e runtime.config.path=/usr/local/tomcat/conf/runtime.yml maurodatamapper/mauro-data-mapper:2023.1
              EOF

  depends_on = [
    # Aurora Postgres Instance must be created before endpoint name can be used
    aws_rds_cluster_instance.postgres_primary_instance[0]
  ]

  user_data_replace_on_change = true

  tags = {
    Name = "mdm-app1"
  }
}

resource "aws_instance" "mdm_app2" {
  count                  = 1
  ami                    = "ami-084e8c05825742534"
  instance_type          = "t2.large"
  subnet_id              = module.vpc_subnet.public_subnet_ids[1]
  vpc_security_group_ids = [aws_security_group.mdm_api_sg.id]
  key_name               = var.ssh_key
  associate_public_ip_address = true

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
                git clone -b develop https://github.com/MauroDataMapper/mdm-docker.git

                cd mdm-docker
                # clears postgres image, volume and dependancy on mauro-data-mapper image
                sed -i '3,11d;28d;29d;39d;40d' docker-compose.yml

                # install docker compose
                curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
                sudo chmod +x /usr/local/bin/docker-compose

                # run docker containers based on the built docker compose images
                docker network create -d bridge mdm-network
                docker-compose build --no-cache --progress=plain --build-arg MDM_APPLICATION_COMMIT=develop --build-arg MDM_UI_COMMIT=develop --build-arg MDM_UI_THEME_NAME="nhs-digital"
                docker run -d --network mdm-network -p ${var.http_server_port}:8080 -e maurodatamapper.authority.name="${var.mdm_authority_name}" -e maurodatamapper.authority.url="${var.mdm_domain_url}" -e DATABASE_PASSWORD=${var.db_password} -e DATABASE_USERNAME=${var.db_username} -e DATABASE_HOST=${aws_rds_cluster_instance.postgres_primary_instance[0].endpoint} -e database.host=${aws_rds_cluster_instance.postgres_primary_instance[0].endpoint} -e runtime.config.path=/usr/local/tomcat/conf/runtime.yml maurodatamapper/mauro-data-mapper:2023.1
          EOF

  depends_on = [
    # Aurora Postgres Instance must be created before endpoint name can be used
    aws_rds_cluster_instance.postgres_primary_instance[0]
  ]

  user_data_replace_on_change = true
  tags = {
    Name = "mdm-app2"
  }
}

resource "aws_rds_cluster" "postgres_cluster" {
  cluster_identifier      = "aurora-cluster-mdm"
  engine                  = "aurora-postgresql"
  engine_mode             = "provisioned"
  availability_zones      = [var.az_west_a, var.az_west_b,  var.az_west_c]
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

resource "aws_security_group" "mdm_api_sg" {
  name        = "mdm_api_sg"
  description = "Security group for tutorial web servers"
  vpc_id      = module.vpc_subnet.vpc_id

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

  ingress {
    from_port   = var.https_server_port
    to_port     = var.https_server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
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

  vpc_id = module.vpc_subnet.vpc_id

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
  subnet_ids  = [for subnet in module.vpc_subnet.private_subnet_ids : subnet]
}

