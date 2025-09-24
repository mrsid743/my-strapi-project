output "ecr_repository_url" {
  description = "The URL of the ECR repository."
  value       = aws_ecr_repository.strapi_ecr_repo.repository_url
}

output "ec2_public_ip" {
  description = "The public IP address of the Strapi EC2 instance."
  value       = aws_instance.strapi_server.public_ip
}

output "ssh_command" {
  description = "Command to SSH into the EC2 instance."
  value       = "ssh -i \"~/.ssh/${var.aws_key_pair_name}.pem\" ec2-user@${aws_instance.strapi_server.public_ip}"
}