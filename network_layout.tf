locals {
  project_tag_prefix = "${var.application_name}-${var.environment_name}"
}

resource "aws_vpc" "app_vpc" {
  cidr_block           = var.vpc_network_range
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "${local.project_tag_prefix}-vpc"
    Application = var.application_name
    Environment = var.environment_name
  }
}

resource "aws_subnet" "public_subnet_a" {
  vpc_id                  = aws_vpc.app_vpc.id
  cidr_block              = var.public_subnet_one_range
  availability_zone       = data.aws_availability_zones.available_zones.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name        = "${local.project_tag_prefix}-public-subnet-a"
    Application = var.application_name
    Environment = var.environment_name
  }
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id                  = aws_vpc.app_vpc.id
  cidr_block              = var.public_subnet_two_range
  availability_zone       = data.aws_availability_zones.available_zones.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name        = "${local.project_tag_prefix}-public-subnet-b"
    Application = var.application_name
    Environment = var.environment_name
  }
}

resource "aws_internet_gateway" "app_igw" {
  vpc_id = aws_vpc.app_vpc.id

  tags = {
    Name        = "${local.project_tag_prefix}-igw"
    Application = var.application_name
    Environment = var.environment_name
  }
}

resource "aws_route_table" "public_routes" {
  vpc_id = aws_vpc.app_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.app_igw.id
  }

  tags = {
    Name        = "${local.project_tag_prefix}-public-rt"
    Application = var.application_name
    Environment = var.environment_name
  }
}

resource "aws_route_table_association" "public_assoc_a" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public_routes.id
}

resource "aws_route_table_association" "public_assoc_b" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.public_routes.id
}
