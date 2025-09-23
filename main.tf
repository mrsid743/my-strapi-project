# main.tf - Defines the core AWS infrastructure for the Strapi deployment.

provider "aws" {
  region = var.aws_region
}

# --- CHANGE START ---
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
# --- CHANGE END ---

# This data source looks up the existing security group by its name.
data "aws_security_group" "strapi_sg" {
  name = "strapi-security-group"
}

# Creates an EC2 instance to run the Strapi container
resource "aws_instance" "strapi_server" {
  # This now refers to the ID of the AMI we looked up dynamically.
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  key_name      = var.ec2_key_name # Make sure you have this key pair in your AWS account
  
  # This refers to the ID of the data source we looked up.
  vpc_security_group_ids = [data.aws_security_group.strapi_sg.id]

  user_data = templatefile("user-data.sh", {
    strapi_image = var.strapi_image_tag,
    aws_region   = var.aws_region
  })

  tags = {
    Name = "StrapiInstance"
  }
}

