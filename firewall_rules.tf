resource "aws_security_group" "load_balancer_sg" {
  name        = "${local.project_tag_prefix}-lb-sg"
  description = "Controls access to the ALB for ${local.project_tag_prefix}"
  vpc_id      = aws_vpc.app_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] // HTTP access from anywhere
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] // HTTPS access from anywhere
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${local.project_tag_prefix}-lb-sg"
    Application = var.application_name
    Environment = var.environment_name
  }
}

resource "aws_security_group" "app_container_sg" {
  name        = "${local.project_tag_prefix}-app-sg"
  description = "Controls access to the ${local.project_tag_prefix} app containers"
  vpc_id      = aws_vpc.app_vpc.id

  ingress {
    from_port       = var.container_port
    to_port         = var.container_port
    protocol        = "tcp"
    security_groups = [aws_security_group.load_balancer_sg.id] // Only from our ALB
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${local.project_tag_prefix}-app-sg"
    Application = var.application_name
    Environment = var.environment_name
  }
}
