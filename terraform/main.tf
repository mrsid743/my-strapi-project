# terraform/main.tf
# Configures the AWS provider and defines all the necessary infrastructure.

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider with the specified region
provider "aws" {
  region = var.aws_region
}

# Create a security group to allow SSH and Strapi traffic
resource "aws_security_group" "strapi_sg" {
  name        = "strapi-security-group"
  description = "Allow SSH and Strapi inbound traffic"

  # Allow incoming traffic on port 1337 (Strapi) from any IP
  ingress {
    from_port   = 1337
    to_port     = 1337
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow incoming traffic on port 22 (SSH) from any IP
  # For better security, you could restrict this to your own IP address
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "strapi-sg"
  }
}

# Define the EC2 instance
resource "aws_instance" "strapi_server" {
  # Using Amazon Linux 2 AMI for ap-south-1 region. Find the latest for your region.
  ami           = "ami-0da59f1205226a751" 
  instance_type = "t2.micro" # Free-tier eligible

  # Associate the security group created above
  vpc_security_group_ids = [aws_security_group.strapi_sg.id]

  # The setup script to run on instance launch
  # It uses the templatefile function to inject variables
  user_data = templatefile("${path.module}/user_data.sh", {
    strapi_image_tag   = var.strapi_image_tag
    dockerhub_username = var.dockerhub_username
  })

  tags = {
    Name = "Strapi-Server-Deployed"
  }
}

