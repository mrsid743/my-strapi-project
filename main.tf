# This file defines all the AWS resources for the project, including
# the IAM Role for secure ECR access, the ECR repository, and the EC2 instance.

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS provider to use the region defined in variables.tf.
provider "aws" {
  region = var.aws_region
}


# --- IAM Role for EC2 to Access ECR ---
# Creates an IAM role that the EC2 instance will assume.
resource "aws_iam_role" "ec2_ecr_role" {
  name = "${var.project_name}-ec2-role"

  # The assume_role_policy allows EC2 instances to assume this role.
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Project = var.project_name
  }
}

# Attaches the AWS-managed policy that grants read-only access to ECR.
resource "aws_iam_role_policy_attachment" "ecr_read_only" {
  role       = aws_iam_role.ec2_ecr_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Creates an instance profile to pass the IAM role to the EC2 instance.
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-ec2-profile"
  role = aws_iam_role.ec2_ecr_role.name
}


# --- AWS ECR Repository ---
# Creates a private ECR repository to store the Strapi Docker images.
resource "aws_ecr_repository" "strapi_repo" {
  name                 = var.ecr_repo_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Project = var.project_name
  }
}


# --- AWS EC2 Instance ---
# Fetches the latest Amazon Linux 2 AMI for the instance.
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Provisions the EC2 instance.
resource "aws_instance" "strapi_server" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type
  key_name      = var.key_name
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  vpc_security_group_ids = [var.sg_id]

  # The user_data script is rendered from the user_data.sh file.
  user_data = templatefile("${path.module}/user_data.sh", {
    ecr_repository_url = aws_ecr_repository.strapi_repo.repository_url,
    image_tag          = var.image_tag
  })

  tags = {
    Name    = "${var.project_name}-server"
    Project = var.project_name
  }
}

