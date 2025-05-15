output "AlphaWebApp_Staging_URL" {
  description = "Access URL for the Alpha WebApp (Staging Environment)"
  value       = "http://${aws_lb.app_alb.dns_name}" // ALB only has HTTP listener for now
}

output "Deployed_Container_Image" {
  description = "The Nginx image tag used for this deployment."
  value       = var.container_image_tag
}

output "CloudWatch_Log_Group" {
  description = "Log group name for the Alpha WebApp container logs."
  value       = aws_cloudwatch_log_group.app_container_logs.name
}
