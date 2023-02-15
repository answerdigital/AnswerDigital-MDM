resource "aws_ecs_cluster" "mdm_docker" {
  name = "mdm_docker"
}

resource "aws_ecs_service" "mdm_docker" {
  depends_on = [
    aws_rds_cluster_instance.postgres_primary_instance[0]
  ]
  name                = "mdm_docker"
  cluster             = aws_ecs_cluster.mdm_docker.id
  task_definition     = aws_ecs_task_definition.task_definition.arn
  desired_count       = 1
  launch_type         = var.service_launch_type
  scheduling_strategy = var.scheduling_strategy

  load_balancer {
    target_group_arn = aws_lb_target_group.eip_target.arn
    container_name   = "${var.project_name}-container"
    container_port   = 8082
  }
  network_configuration {
    security_groups  = [aws_security_group.mdm_api_sg.id]
    subnets          = [aws_subnet.mdm_public_subnet[0].id]
    assign_public_ip = true
  }
}

resource "aws_ecs_task_definition" "task_definition" {
  family                   = "${var.project_name}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = [var.service_launch_type]
  cpu                      = 4096
  memory                   = 8192
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  container_definitions    = jsonencode([
    {
      name         = "${var.project_name}-container"
      image        = "public.ecr.aws/r5f6k8o3/mdm-docker:latest"
      cpu          = 2048
      memory       = 4096
      essential    = true
      networkMode  = "awsvpc"
      portMappings = [
        {
          containerPort = 8082
          hostPort      = 8082
        }
      ]
      logConfiguration = {
        logDriver = "awslogs",
        options   = {
          "awslogs-group" : "${var.project_name}-log-group",
          "awslogs-region" : "eu-west-2",
          "awslogs-stream-prefix" : "${var.project_name}-log-stream"
        }
      }
      environment = [
        {
          "name" : "DATABASE_PASSWORD",
          "value" : var.db_password
        },
        {
          "name" : "DATABASE_USERNAME",
          "value" : var.db_username
        },
        {
          "name" : "DATABASE_HOST",
          "value" : "${aws_rds_cluster_instance.postgres_primary_instance[0].endpoint}"
        },
        {
          "name" : "database.host",
          "value" : "mdm-postgresdb-primary.ce5zstiyqlhf.eu-west-2.rds.amazonaws.com"
        },
        {
          "name" : "runtime.config.path",
          "value" : "/usr/local/tomcat/conf/runtime.yml"
        }
      ]
    }
  ])

  tags = {
    Name = "${var.project_name}-task-definition"
  }
}
