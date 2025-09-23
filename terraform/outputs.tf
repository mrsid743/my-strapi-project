# terraform/outputs.tf
# Defines the output values from the Terraform configuration.

output "instance_public_ip" {
  description = "The public IP address of the EC2 instance."
  value       = aws_instance.strapi_server.public_ip
}
