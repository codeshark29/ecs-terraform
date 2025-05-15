resource "aws_ecs_cluster" "app_cluster" {
  name = "${local.project_tag_prefix}-cluster"

  tags = {
    Name        = "${local.project_tag_prefix}-cluster"
    Application = var.application_name
    Environment = var.environment_name
  }
}

resource "aws_iam_role" "ecs_task_exec_role" {
  name = "${local.project_tag_prefix}-ecs-task-exec-role"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${local.project_tag_prefix}-ecs-task-exec-role"
    Application = var.application_name
    Environment = var.environment_name
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_exec_policy_attach" {
  role       = aws_iam_role.ecs_task_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_lb" "app_alb" {
  name               = "${local.project_tag_prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.load_balancer_sg.id]
  subnets            = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id]

  enable_deletion_protection = false

  tags = {
    Name        = "${local.project_tag_prefix}-alb"
    Application = var.application_name
    Environment = var.environment_name
  }
}

resource "aws_lb_target_group" "app_tg" {
  name        = "${local.project_tag_prefix}-tg"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = aws_vpc.app_vpc.id
  target_type = "ip"

  health_check {
    enabled             = true
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200" // Nginx default page returns 200
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name        = "${local.project_tag_prefix}-tg"
    Application = var.application_name
    Environment = var.environment_name
  }
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }

  tags = {
    Name        = "${local.project_tag_prefix}-http-listener"
    Application = var.application_name
    Environment = var.environment_name
  }
}

resource "aws_ecs_task_definition" "app_task_def" {
  family                   = "${local.project_tag_prefix}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu_units
  memory                   = var.fargate_memory_mb
  execution_role_arn       = aws_iam_role.ecs_task_exec_role.arn

  container_definitions = jsonencode([
    {
      name      = "${var.application_name}-container"
      image     = var.container_image_tag
      cpu       = var.fargate_cpu_units
      memory    = var.fargate_memory_mb
      essential = true
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/${local.project_tag_prefix}-logs"
          "awslogs-region"        = var.aws_deployment_region
          "awslogs-stream-prefix" = "app"
        }
      }
    }
  ])

  tags = {
    Name        = "${local.project_tag_prefix}-task-def"
    Application = var.application_name
    Environment = var.environment_name
  }
}

resource "aws_cloudwatch_log_group" "app_container_logs" {
  name              = "/ecs/${local.project_tag_prefix}-logs"
  retention_in_days = 7 // Keep staging logs for a week

  tags = {
    Name        = "${local.project_tag_prefix}-log-group"
    Application = var.application_name
    Environment = var.environment_name
  }
}

resource "aws_ecs_service" "app_service" {
  name            = "${local.project_tag_prefix}-service"
  cluster         = aws_ecs_cluster.app_cluster.id
  task_definition = aws_ecs_task_definition.app_task_def.arn
  desired_count   = var.service_task_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id]
    security_groups = [aws_security_group.app_container_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app_tg.arn
    container_name   = "${var.application_name}-container"
    container_port   = var.container_port
  }

  depends_on = [
    aws_lb_listener.http_listener,
    aws_iam_role_policy_attachment.ecs_task_exec_policy_attach,
    aws_cloudwatch_log_group.app_container_logs
  ]

  health_check_grace_period_seconds = 60
  deployment_minimum_healthy_percent = 50

  tags = {
    Name        = "${local.project_tag_prefix}-service"
    Application = var.application_name
    Environment = var.environment_name
  }
}
