# Defines the AWS provider and required version.
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configures the AWS provider with the specified region.
provider "aws" {
  region = var.aws_region
}

# --- THIS IS THE FIX ---
# Data source to dynamically find the latest Amazon Linux 2 AMI in the current region.
# This avoids hardcoding a region-specific AMI ID.
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Creates a security group to control traffic to the Strapi instance.
resource "aws_security_group" "strapi_sg" {
  name        = "strapi-security-group"
  description = "Allow inbound traffic for Strapi and SSH"

  # Allows SSH access from anywhere.
  # For better security, you can restrict this to your IP address: cidr_blocks = ["YOUR_IP/32"]
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allows access to the Strapi application from anywhere.
  ingress {
    from_port   = 1337
    to_port     = 1337
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allows all outbound traffic.
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

# Creates the EC2 instance.
resource "aws_instance" "strapi_server" {
  # --- USE THE DYNAMIC AMI ID ---
  ami           = data.aws_ami.amazon_linux_2.id # Uses the ID found by the data source.
  instance_type = "t2.micro"                     # Free-tier eligible instance type.

  # Associates the security group with the instance.
  vpc_security_group_ids = [aws_security_group.strapi_sg.id]

  # The user_data script is rendered using variables from the workflow.
  user_data = templatefile("${path.module}/user_data.sh", {
    strapi_image_tag   = var.strapi_image_tag
    dockerhub_username = var.dockerhub_username
  })

  tags = {
    Name = "Strapi-Server"
  }
}

