# outputs.tf - Defines the output values from our Terraform configuration.

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance."
  value       = aws_instance.strapi_server.public_ip
}
