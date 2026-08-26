output "vpc_id" {
  description = "ID of the Cloud Task Manager VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = [aws_subnet.public_a.id, aws_subnet.public_b.id]
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = [aws_subnet.private_a.id, aws_subnet.private_b.id]
}

output "alb_dns_name" {
  description = "Public DNS name of the Application Load Balancer — open this in a browser to reach the app"
  value       = aws_lb.app.dns_name
}

output "target_group_arn" {
  description = "ARN of the ALB target group"
  value       = aws_lb_target_group.app.arn
}

output "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.app.name
}

output "launch_template_id" {
  description = "ID of the Launch Template used by the ASG"
  value       = aws_launch_template.app.id
}

output "db_endpoint" {
  description = "RDS PostgreSQL connection endpoint (host:port)"
  value       = aws_db_instance.main.endpoint
}

output "db_address" {
  description = "RDS PostgreSQL host address"
  value       = aws_db_instance.main.address
}

output "app_security_group_id" {
  description = "Security group ID attached to application instances"
  value       = aws_security_group.app.id
}

output "github_actions_role_arn" {
  description = "IAM role ARN GitHub Actions assumes via OIDC. Set this as the AWS_ROLE_ARN secret in your GitHub repo."
  value       = aws_iam_role.github_actions_deploy.arn
}

output "db_security_group_id" {
  description = "Security group ID attached to the RDS instance"
  value       = aws_security_group.db.id
}