# main.tf - Defines the core AWS infrastructure for the Strapi deployment.

provider "aws" {
  region = var.aws_region
}

# Creates a security group to allow HTTP and SSH traffic
resource "aws_security_group" "strapi_sg" {
  name        = "strapi-security-group"
  description = "Allow HTTP and SSH inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 1337
    to_port     = 1337
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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

# Creates an EC2 instance to run the Strapi container
resource "aws_instance" "strapi_server" {
  ami           = "ami-02eb7a4783e1ae545" # Amazon Linux 2 AMI for ap-south-1 (Mumbai)
  instance_type = var.instance_type
  key_name      = var.ec2_key_name # Make sure you have this key pair in your AWS account
  vpc_security_group_ids = [aws_security_group.strapi_sg.id]
  user_data = templatefile("user-data.sh", {
    strapi_image = var.strapi_image_tag,
    aws_region   = var.aws_region
  })

  tags = {
    Name = "StrapiInstance"
  }
}

