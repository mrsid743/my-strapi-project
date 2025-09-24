# This file defines all the input variables for the Terraform configuration.
# Validation rules have been added to ensure required inputs are provided.

variable "project_name" {
  description = "A unique name for the project to tag all related resources."
  type        = string
  default     = "strapi-siddhant"
}

variable "aws_region" {
  description = "The AWS region where resources will be deployed."
  type        = string
  default     = "ap-south-1" # Default region is Mumbai
}

variable "ecr_repo_name" {
  description = "The name for the new AWS ECR repository."
  type        = string
  default     = "strappi-siddhant"
}

variable "image_tag" {
  description = "The Docker image tag to deploy on the EC2 instance."
  type        = string
  default     = "latest"
}

variable "key_name" {
  description = "Name of the existing EC2 KeyPair for SSH access to the instance."
  type        = string
  # This sensitive value should be set via the GitHub secret: TF_VAR_key_name

  validation {
    condition     = can(regex("^[\\w\\.-]+$", var.key_name)) && length(var.key_name) > 0
    error_message = "The key_name variable must be a valid name and cannot be empty."
  }
}

variable "sg_id" {
  description = "ID of the existing Security Group (e.g., sg-012345abcdef)."
  type        = string
  # This sensitive value should be set via the GitHub secret: TF_VAR_sg_id

  validation {
    condition     = can(regex("^sg-[0-9a-fA-F]+$", var.sg_id))
    error_message = "The sg_id variable must be a valid Security Group ID, starting with 'sg-'."
  }
}

variable "instance_type" {
  description = "The type of EC2 instance to launch (e.g., t2.micro)."
  type        = string
  default     = "t2.micro"
}