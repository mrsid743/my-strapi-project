# variables.tf - Defines variables used in the Terraform configuration.

variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "ap-south-1" # Changed to Mumbai region
}

variable "instance_type" {
  description = "The EC2 instance type."
  type        = string
  default     = "t2.micro"
}

variable "ec2_key_name" {
  description = "The name of the EC2 key pair for SSH access."
  type        = string
  default     = "strapi-key" # Replace with your key pair name
}

variable "strapi_image_tag" {
  description = "The Docker image tag for the Strapi application."
  type        = string
}

