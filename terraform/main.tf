# Configure the AWS provider
provider "aws" {
  region = var.aws_region
}

# Get the AWS Account ID to construct the ECR URL
data "aws_caller_identity" "current" {}

# Get the latest Ubuntu 22.04 AMI for the specified region
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical's owner ID
}

# Create an IAM role for the EC2 instance to allow ECR access
resource "aws_iam_role" "ec2_role" {
  name = "ec2-strapi-role"
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
}

# Attach the AmazonEC2ContainerRegistryReadOnly policy to the role
resource "aws_iam_role_policy_attachment" "ecr_readonly_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Create an instance profile to attach the role to the EC2 instance
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2-strapi-instance-profile"
  role = aws_iam_role.ec2_role.name
}

# Define the EC2 instance
resource "aws_instance" "strapi_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.ssh_key_name
  vpc_security_group_ids = [var.security_group_id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name

  # The user data script is rendered from a template file
  user_data = templatefile("${path.module}/user_data.tftpl", {
    aws_region     = var.aws_region,
    ecr_repo_url   = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.ecr_repo_name}",
    image_tag      = var.image_tag
  })

  tags = {
    Name = "Strapi-Server-Instance"
  }

  # Wait for the IAM profile to be ready before launching the instance
  depends_on = [aws_iam_instance_profile.ec2_instance_profile]
}

