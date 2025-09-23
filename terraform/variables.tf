# terraform/variables.tf
# Defines the input variables for the Terraform configuration.

variable "aws_region" {
  description = "The AWS region where resources will be created."
  type        = string
  default     = "ap-south-1"
}

variable "strapi_image_tag" {
  description = "The tag of the Strapi Docker image to deploy (e.g., 'latest' or a git SHA)."
  type        = string
}

variable "dockerhub_username" {
  description = "Your Docker Hub username."
  type        = string
}
