#####################################
# Provider
#####################################
provider "aws" {
  region = var.aws_region
}

#####################################
# Data Sources
#####################################
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

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

#####################################
# ECR Repository
#####################################
resource "aws_ecr_repository" "strapi_ecr_repo" {
  name                 = var.ecr_repository_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name    = "${var.ecr_repository_name}-repo"
    Project = "StrapiDeployment"
  }
}

#####################################
# IAM Role & Policies
#####################################
resource "aws_iam_role" "ec2_ecr_full_access_role" {
  name = "ec2_ecr_full_access_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "ec2.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecr_full" {
  role       = aws_iam_role.ec2_ecr_full_access_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}

resource "aws_iam_role_policy_attachment" "ec2_full" {
  role       = aws_iam_role.ec2_ecr_full_access_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ec2_ecr_full_access_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "strapi_ec2_profile" {
  name = "ec2_ecr_full_access_role_profile"
  role = aws_iam_role.ec2_ecr_full_access_role.name
}

#####################################
# Security Group
#####################################
resource "aws_security_group" "strapi_sg" {
  name        = "strapi-sg"
  description = "Allow inbound HTTP and Strapi traffic"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow Strapi"
    from_port   = 1337
    to_port     = 1337
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
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

  iam_instance_profile = var.existing_iam_instance_profile_name != "" ? var.existing_iam_instance_profile_name : aws_iam_instance_profile.strapi_ec2_profile.name

  user_data = templatefile("${path.module}/user_data.tpl", {
    aws_region             = var.aws_region
    ecr_repo_url           = aws_ecr_repository.strapi_ecr_repo.repository_url
    image_tag              = var.image_tag
    strapi_app_keys        = var.strapi_app_keys
    strapi_api_token_salt  = var.strapi_api_token_salt
    strapi_admin_jwt_secret= var.strapi_admin_jwt_secret
    strapi_jwt_secret      = var.strapi_jwt_secret
  })

  tags = {
    Name = "Strapi-EC2-Server"
  }

  lifecycle {
    create_before_destroy = true
  }
}
