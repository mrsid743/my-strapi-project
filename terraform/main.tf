provider "aws" {
  region = var.aws_region
}

# --- ECR ---
# Create a private ECR repository to store the Strapi Docker images
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

# --- Networking ---
# Use the default VPC for simplicity
data "aws_vpc" "default" {
  default = true
}

# Get a list of public subnets in the default VPC
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

# Create a security group to control traffic to the EC2 instance
resource "aws_security_group" "strapi_sg" {
  name        = "${var.ecr_repository_name}-sg"
  description = "Allow SSH, HTTP, and Strapi traffic"
  vpc_id      = data.aws_vpc.default.id

  # Allow inbound SSH traffic from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow inbound HTTP traffic from anywhere (for a load balancer or proxy later)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow inbound Strapi traffic from anywhere
  ingress {
    from_port   = 1337
    to_port     = 1337
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.ecr_repository_name}-security-group"
  }
}

# --- EC2 Instance ---
# Find the latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Create the EC2 instance
resource "aws_instance" "strapi_server" {
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = var.ec2_instance_type
  key_name                    = var.aws_key_pair_name
  # Use the pre-existing IAM instance profile provided via a variable
  iam_instance_profile        = var.existing_iam_instance_profile_name
  vpc_security_group_ids      = [aws_security_group.strapi_sg.id]
  # Launch in the first available public subnet
  subnet_id                   = element(data.aws_subnets.default_public.ids, 0)
  associate_public_ip_address = true

  # Startup script to install Docker and run our Strapi container
  user_data = <<-EOF
              #!/bin/bash
              # Update system packages
              yum update -y
              
              # Install Docker
              yum install -y docker
              service docker start
              usermod -a -G docker ec2-user
              
              # Get ECR login token and login
              # The EC2 instance role provides the necessary permissions
              aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${aws_ecr_repository.strapi_ecr_repo.repository_url}
              
              # Stop and remove any existing container named 'strapi'
              docker stop strapi || true
              docker rm strapi || true
              
              # Pull the specified image from ECR and run it
              docker run -d -p 1337:1337 \
                --name strapi \
                --restart always \
                -e HOST="0.0.0.0" \
                -e PORT="1337" \
                -e NODE_ENV="production" \
                -e APP_KEYS="${var.strapi_app_keys}" \
                -e API_TOKEN_SALT="${var.strapi_api_token_salt}" \
                -e ADMIN_JWT_SECRET="${var.strapi_admin_jwt_secret}" \
                -e JWT_SECRET="${var.strapi_jwt_secret}" \
                -e DATABASE_CLIENT="sqlite" \
                -e DATABASE_FILENAME="/opt/app/data/data.db" \
                -v strapi_data:/opt/app/data \
                ${aws_ecr_repository.strapi_ecr_repo.repository_url}:${var.image_tag}
              EOF

  tags = {
    Name = "Strapi-EC2-Server"
  }

  # This lifecycle rule helps prevent issues if the user_data script changes.
  # It forces a replacement of the instance, ensuring the new script runs.
  lifecycle {
    create_before_destroy = true
  }
}

