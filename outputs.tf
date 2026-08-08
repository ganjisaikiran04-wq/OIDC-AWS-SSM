output "vpc_id" {
  value = aws_vpc.main.id
}

output "private_instance_id" {
  description = "Private application EC2 instance ID"

  value = aws_instance.application.id
}

output "private_ec2_ip" {
  description = "Private IP of application EC2"

  value = aws_instance.application.private_ip
}

output "alb_dns_name" {
  description = "Application Load Balancer DNS"

  value = aws_lb.application.dns_name
}

output "application_url" {
  description = "Application URL"

  value = "http://${aws_lb.application.dns_name}"
}

output "deployment_bucket" {
  description = "S3 bucket used for application deployment"

  value = aws_s3_bucket.deployment.bucket
}

output "target_group_arn" {
  value = aws_lb_target_group.application.arn
}

output "ssm_instance_profile" {
  value = aws_iam_instance_profile.ec2_ssm.name
}