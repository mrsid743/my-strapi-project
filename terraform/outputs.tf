output "instance_public_ip" {
  description = "The public IP address of the EC2 instance."
  value       = aws_instance.strapi_server.public_ip
}

output "instance_public_dns" {
  description = "The public DNS of the EC2 instance."
  value       = aws_instance.strapi_server.public_dns
}

