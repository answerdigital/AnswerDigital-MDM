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
    target_group_arn = aws_lb_target_group.mdm_target_group.arn
    container_name   = "${var.project_name}-container"
    container_port   = var.container_internal_port
  }
  network_configuration {
    security_groups  = [aws_security_group.ecs_service_sg.id]
    subnets          = [module.vpc_subnet.public_subnet_ids[0], module.vpc_subnet.public_subnet_ids[1]]
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
      image        = var.docker_image_url
      cpu          = 2048
      memory       = 4096
      essential    = true
      portMappings = [
        {
          containerPort = var.container_internal_port
        }
      ]
      logConfiguration = {
        logDriver = "awslogs",
        options   = {
          "awslogs-group" : "${var.project_name}-log-group",
          "awslogs-region" : var.az_west_two,
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
          "value" : aws_rds_cluster_instance.postgres_primary_instance[0].endpoint
        },
        {
          "name" : "database.host",
          "value" : aws_rds_cluster_instance.postgres_primary_instance[0].endpoint
        },
        {
          "name" : "runtime.config.path",
          "value" : "/usr/local/tomcat/conf/runtime.yml"
        },
        {
          "name" : "ADDITIONAL_PLUGINS",
          "value" : var.mdm_plugins_dev-test
        },
        {
          "name" : "DATASOURCE_PASSWORD",
          "value" : var.db_password
        },
        {
          "name" : "database.name",
          "value" : var.db_name
        },
        {
          "name" : "dataSource.username",
          "value" : var.db_username
        },
        {
          "name" : "dataSource.password",
          "value" : var.db_password
        }
      ]
    }
  ])

  tags = {
    Name = "${var.project_name}-task-definition"
  }
}

resource "aws_appautoscaling_target" "mdm_docker_target" {
  max_capacity       = 10
  min_capacity       = 1
  resource_id        = "service/mdm_docker/${aws_ecs_service.mdm_docker.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "memory_scaling_policy" {
  name               = "memory-scaling-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.mdm_docker_target.resource_id
  scalable_dimension = aws_appautoscaling_target.mdm_docker_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.mdm_docker_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    scale_out_cooldown = 300
    scale_in_cooldown  = 300
    target_value = 50.0
  }
}


