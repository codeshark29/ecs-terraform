variable "aws_deployment_region" {
  type    = string
  default = "ap-south-1"
}

variable "application_name" {
  type    = string
  default = "alpha-webapp"
}

variable "environment_name" {
  type    = string
  default = "staging"
}

variable "vpc_network_range" {
  type    = string
  default = "10.30.0.0/16"
}

variable "public_subnet_one_range" {
  type    = string
  default = "10.30.10.0/24"
}

variable "public_subnet_two_range" {
  type    = string
  default = "10.30.20.0/24"
}

variable "container_port" {
  type    = number
  default = 80
}

variable "container_image_tag" {
  type    = string
  default = "nginx:1.25-alpine"
}

variable "fargate_cpu_units" {
  type    = number
  default = 256
}

variable "fargate_memory_mb" {
  type    = number
  default = 512
}

variable "service_task_count" {
  type    = number
  default = 1
}
