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
}

#####################################
# IAM Role & Policies
#####################################

resource "aws_iam_role" "ec2_ecr_full_access_role" {
  name = "ec2_ecr_full_access_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "ec2.amazonaws.com" },
      Action   = "sts:AssumeRole"
    }]
  })
}

# Attach AWS-managed policies
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

# IAM Instance Profile
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

  # Use existing IAM profile if provided, else use the one created above
  iam_instance_profile = var.existing_iam_instance_profile_name != "" ? var.existing_iam_instance_profile_name : aws_iam_instance_profile.strapi_ec2_profile.name

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y docker unzip
              service docker start
              usermod -a -G docker ec2-user

              # Install AWS CLI v2
              curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
              unzip awscliv2.zip
              ./aws/install

              # Authenticate with ECR
              aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${aws_ecr_repository.strapi_ecr_repo.repository_url}

              # Prepare Strapi container
              docker volume create strapi_data
              docker stop strapi || true
              docker rm strapi || true

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

  lifecycle {
    create_before_destroy = true
  }
}
