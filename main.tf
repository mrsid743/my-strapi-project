# main.tf - Defines the core AWS infrastructure for the Strapi deployment.

provider "aws" {
  region = var.aws_region
}

# This data source dynamically finds the most recent Amazon Linux 2 AMI
# in the specified region. This is more reliable than hardcoding an AMI ID.
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# This data source looks up the existing security group by its name.
data "aws_security_group" "strapi_sg" {
  name = "strapi-security-group"
}

# --- THIS SECTION WAS MISSING ---
# Creates an IAM instance profile to attach the role to the EC2 instance.
# The role "EC2-ECR-Pull-Role" must be created in the AWS Console first.
resource "aws_iam_instance_profile" "ecr_profile" {
  name = "EC2-ECR-Pull-Profile"
  role = "EC2-ECR-Pull-Role"
}
# --------------------------------

# Creates an EC2 instance to run the Strapi container
resource "aws_instance" "strapi_server" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  key_name      = var.ec2_key_name

  vpc_security_group_ids = [data.aws_security_group.strapi_sg.id]

  # --- THIS LINE WAS MISSING ---
  # This attaches the IAM role to the EC2 instance, granting it permissions.
  iam_instance_profile = aws_iam_instance_profile.ecr_profile.name
  # -----------------------------

  user_data = templatefile("user-data.sh", {
    strapi_image = var.strapi_image_tag,
    aws_region   = var.aws_region
  })

  tags = {
    Name = "StrapiInstance"
  }
}

# This output block will display the public IP address of the EC2 instance
# after terraform apply is complete.
output "instance_public_ip" {
  description = "The public IP address of the EC2 instance."
  value       = aws_instance.strapi_server.public_ip
}

