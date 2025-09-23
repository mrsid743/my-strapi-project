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

# Data source to dynamically find the latest Amazon Linux 2 AMI in the current region.
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

# --- THIS IS THE FIX ---
# Data source to find the existing security group instead of creating a new one.
# This prevents the "Duplicate" error on subsequent runs.
data "aws_security_group" "strapi_sg" {
  name = "strapi-security-group"
}

# Creates the EC2 instance.
resource "aws_instance" "strapi_server" {
  # Uses the ID found by the AMI data source.
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t2.micro" # Free-tier eligible instance type.

  # --- USE THE EXISTING SG ID ---
  # Associates the security group found by the data source with the instance.
  vpc_security_group_ids = [data.aws_security_group.strapi_sg.id]

  # The user_data script is rendered using variables from the workflow.
  user_data = templatefile("${path.module}/user_data.sh", {
    strapi_image_tag   = var.strapi_image_tag
    dockerhub_username = var.dockerhub_username
  })

  tags = {
    Name = "Strapi-Server"
  }
}

