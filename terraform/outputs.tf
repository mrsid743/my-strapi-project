output "ec2_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.strapi.public_ip
}

output "ssh_command" {
  description = "SSH command to connect"
  value       = "ssh -i \"~/.ssh/${var.ssh_key_name}.pem\" ec2-user@${aws_instance.strapi.public_ip}"
}

output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = aws_ecr_repository.strapi.repository_url
}
