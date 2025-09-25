# This output will display the public IP address of the EC2 instance after it's created.
output "ec2_public_ip" {
  description = "Public IP address of the Strapi EC2 instance."
  value       = aws_instance.strapi_server.public_ip
}

# This output provides the full command needed to SSH into the server.
output "ssh_command" {
  description = "Command to SSH into the EC2 instance."
  value       = "ssh -i \"~/.ssh/${var.aws_key_pair_name}.pem\" ec2-user@${aws_instance.strapi_server.public_ip}"
}

# This output displays the full URL of the ECR repository.
output "ecr_repository_url" {
  description = "URL of the ECR repository."
  value       = aws_ecr_repository.strapi_ecr_repo.repository_url
}

