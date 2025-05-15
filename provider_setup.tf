terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.10" // Using a recent AWS provider
    }
  }
}

provider "aws" {
  region = var.aws_deployment_region
}

data "aws_availability_zones" "available_zones" {}
