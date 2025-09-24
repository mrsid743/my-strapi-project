terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.aws_region
}

# ECR repository
resource "aws_ecr_repository" "strapi" {
  name                 = "siddhant-strapi"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}

# IAM role and instance profile so the EC2 instance can pull from ECR
data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2_ecr_role" {
  name               = "ec2-ecr-pull-role-strapi"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy" "ec2_ecr_policy" {
  name = "ec2-ecr-pull-policy-strapi"
  role = aws_iam_role.ec2_ecr_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:DescribeImages"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-ecr-profile-strapi"
  role = aws_iam_role.ec2_ecr_role.name
}

# Optional: create key pair if ssh_public_key provided
resource "aws_key_pair" "strapi_key" {
  count       = var.ssh_public_key != "" ? 1 : 0
  key_name    = var.ssh_key_name
  public_key  = var.ssh_public_key
}

# Security group: allow SSH and Strapi port (1337)
resource "aws_security_group" "strapi_sg" {
  name        = "strapi-sg"
  description = "Allow SSH and Strapi port"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH"
  }

  ingress {
    from_port   = 1337
    to_port     = 1337
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Strapi HTTP"
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

# Get default VPC and subnet (assumes default VPC exists in account)
data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default_subnets" {
  vpc_id = data.aws_vpc.default.id
}

# Get latest Amazon Linux 2 AMI if not provided
data "aws_ami" "amazon_linux" {
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  owners = ["137112412989","amazon"]
}

resource "aws_instance" "strapi" {
  ami                         = var.ami != "" ? var.ami : data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  subnet_id                   = element(data.aws_subnet_ids.default_subnets.ids, 0)
  vpc_security_group_ids      = [aws_security_group.strapi_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
  key_name                    = var.ssh_key_name
  associate_public_ip_address = true

  user_data = templatefile("${path.module}/user_data.tpl", {
    repository_url = aws_ecr_repository.strapi.repository_url
    image_tag      = var.image_tag
    region         = var.aws_region
  })

  tags = {
    Name = "strapi-ec2-instance"
  }
}

output "public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.strapi.public_ip
}

output "ecr_repo_url" {
  description = "ECR repository URI"
  value       = aws_ecr_repository.strapi.repository_url
}

output "instance_id" {
  value = aws_instance.strapi.id
}
