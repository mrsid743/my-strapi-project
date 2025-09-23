# variables.tf - Defines input variables for the Terraform configuration.

variable "aws_region" {
  description = "The AWS region to deploy the resources in."
  type        = string
  default     = "ap-south-1" # Mumbai
}

variable "instance_type" {
  description = "The EC2 instance type."
  type        = string
  default     = "t2.micro"
}

# --- ENSURE THIS VALUE IS CORRECT ---
variable "ec2_key_name" {
  description = "The name of the EC2 key pair to use for SSH access."
  type        = string
  # This MUST match the name of the key pair in AWS that corresponds to your .pem file.
  default     = "strapi-mumbai-key" 
}
# ------------------------------------

variable "strapi_image_tag" {
  description = "The full Docker image tag for the Strapi application from ECR."
  type        = string
}

