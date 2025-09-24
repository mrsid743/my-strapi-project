# This file defines the output values from our Terraform configuration.
# These are displayed after a successful 'terraform apply' for easy access.

output "public_ip" {
  value       = aws_instance.strapi_server.public_ip
  description = "The public IP address of the EC2 instance running Strapi."
}

output "application_url" {
  value       = "http://${aws_instance.strapi_server.public_ip}:1337"
  description = "The full URL to access your deployed Strapi application."
}

output "ecr_repository_url" {
  value       = aws_ecr_repository.strapi_repo.repository_url
  description = "The URL of the ECR repository where Strapi images are stored."
}

output "ssh_command" {
  value       = "ssh -i \"~/.ssh/${var.key_name}.pem\" ec2-user@${aws_instance.strapi_server.public_ip}"
  description = "The command to SSH into the deployed EC2 instance."
}

