provider "aws" {
  region = var.aws_region
}

resource "aws_instance" "strapi_ec2" {
  ami           = "ami-0c322300a1dd5dc79"  # Mumbai Ubuntu 22.04 LTS
  instance_type = "t2.micro"
  key_name      = var.ec2_key_name
  security_groups = [aws_security_group.strapi_sg.name]

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install -y docker.io
              sudo systemctl start docker
              sudo docker pull your-dockerhub-username/strapi-app:${var.image_tag}
              sudo docker run -d -p 1337:1337 your-dockerhub-username/strapi-app:${var.image_tag}
              EOF

  tags = {
    Name = "Strapi-EC2"
  }
}

resource "aws_security_group" "strapi_sg" {
  name        = "strapi_sg"
  description = "Allow HTTP & SSH"

  ingress {
    from_port   = 22
    to_port     = 22
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
}
