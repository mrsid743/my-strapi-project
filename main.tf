# main.tf - Defines the core AWS infrastructure for the Strapi deployment.

provider "aws" {
  region = var.aws_region
}

# --- CHANGE START ---
# This block is now a "data" source instead of a "resource".
# It looks up the existing security group by its name instead of creating a new one.
data "aws_security_group" "strapi_sg" {
  name = "strapi-security-group"
}
# --- CHANGE END ---

# Creates an EC2 instance to run the Strapi container
resource "aws_instance" "strapi_server" {
  ami           = "ami-02eb7a4783e1ae545" # Amazon Linux 2 AMI for ap-south-1 (Mumbai)
  instance_type = var.instance_type
  key_name      = var.ec2_key_name # Make sure you have this key pair in your AWS account
  
  # This now refers to the ID of the data source we looked up.
  vpc_security_group_ids = [data.aws_security_group.strapi_sg.id]

  user_data = templatefile("user-data.sh", {
    strapi_image = var.strapi_image_tag,
    aws_region   = var.aws_region
  })

  tags = {
    Name = "StrapiInstance"
  }
}

