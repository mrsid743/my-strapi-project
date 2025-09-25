provider "aws" {
  region = var.aws_region
}

#####################################
# Data Sources
#####################################
data "aws_caller_identity" "current" {}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default_public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
  filter {
    name   = "map-public-ip-on-launch"
    values = ["true"]
  }
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# --- Look up existing resources ---
# Find the pre-existing ECR repository
data "aws_ecr_repository" "existing_repo" {
  name = var.ecr_repository_name
}

#####################################
# Security Group
#####################################
# This is still created by the script
resource "aws_security_group" "strapi_sg" {
  name        = "strapi-sg"
  description = "Allow SSH, HTTP, and Strapi traffic"
  vpc_id      = data.aws_vpc.default.id

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
    Name = "strapi-security-group"
  }
}

#####################################
# EC2 Instance
#####################################
resource "aws_instance" "strapi_server" {
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = var.ec2_instance_type
  key_name                    = var.aws_key_pair_name
  vpc_security_group_ids      = [aws_security_group.strapi_sg.id]
  subnet_id                   = element(data.aws_subnets.default_public.ids, 0)
  associate_public_ip_address = true
  # Use the pre-existing IAM Instance Profile
  iam_instance_profile        = var.existing_iam_instance_profile_name

  user_data = templatefile("${path.module}/user_data.tpl", {
    aws_region                = var.aws_region
    aws_account_id            = data.aws_caller_identity.current.account_id
    ecr_repository_name       = var.ecr_repository_name
    image_tag                 = var.image_tag
    strapi_app_keys           = var.strapi_app_keys
    strapi_api_token_salt     = var.strapi_api_token_salt
    strapi_admin_jwt_secret   = var.strapi_admin_jwt_secret
    strapi_jwt_secret         = var.strapi_jwt_secret
  })

  tags = {
    Name = "Strapi-EC2-Server"
  }

  lifecycle {
    create_before_destroy = true
  }
}

