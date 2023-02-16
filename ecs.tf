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
    container_port   = var.http_server_port
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
      portMappings = [
        {
          containerPort = var.http_server_port
          hostPort      = var.http_server_port
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
          "value" : aws_rds_cluster_instance.postgres_primary_instance[0].endpoint
        },
        {
          "name" : "database.host",
          "value" : aws_rds_cluster_instance.postgres_primary_instance[0].endpoint
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

resource "aws_appautoscaling_policy" "memory_scaling_policy" {
  name               = "memory-scaling-policy"
  policy_type        = "StepScaling"
  resource_id        = "service/${aws_ecs_service.mdm_docker.name}"
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "PercentChangeInCapacity"
    cooldown                = 300
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = "0"
      scaling_adjustment          = "1"
    }

    step_adjustment {
      metric_interval_upper_bound = "50"
      metric_interval_lower_bound = "0"
      scaling_adjustment          = "1"
    }

    step_adjustment {
      metric_interval_upper_bound = "70"
      metric_interval_lower_bound = "50"
      scaling_adjustment          = "2"
    }

    step_adjustment {
      metric_interval_upper_bound = "-1"
      metric_interval_lower_bound = "70"
      scaling_adjustment          = "3"
    }
  }
  service_namespace = ""
}

resource "aws_cloudwatch_metric_alarm" "memory_utilization_alarm" {
  alarm_name          = "ecs-memory-utilization-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = 70
  alarm_description   = "This metric monitors the memory utilization of the ECS service."
  alarm_actions       = [aws_appautoscaling_policy.memory_scaling_policy.arn]

  dimensions = {
    ServiceName = aws_ecs_service.mdm_docker.name
    ClusterName = aws_ecs_cluster.mdm_docker.name
  }
}

resource "aws_iam_role_policy_attachment" "ecs_cloudwatch_policy" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"
  role       = aws_iam_role.ecs_task_execution_role.name
}
