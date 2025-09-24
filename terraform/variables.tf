variable "aws_region" {
  description = "The AWS region to deploy the resources in."
  type        = string
  default     = "ap-south-1"
}

variable "ecr_repository_name" {
  description = "The name for the Amazon ECR repository."
  type        = string
  default     = "siddhant-strapi"
}

variable "ec2_instance_type" {
  description = "The instance type for the EC2 server."
  type        = string
  default     = "t2.micro"
}

variable "aws_key_pair_name" {
  description = "Name of the AWS EC2 Key Pair to use for SSH access. IMPORTANT: You must create this in the AWS console first."
  type        = string
  # IMPORTANT: Change this default value to your actual key pair name!
  default     = "strapi-mumbai-key"
}

variable "image_tag" {
  description = "The Docker image tag (commit SHA) to pull from ECR."
  type        = string
  default     = "latest" # This default is a fallback, the workflow will override it.
}

# --- Strapi Application Secrets ---
# For a production setup, it's highly recommended to manage these secrets using
# AWS Secrets Manager or Parameter Store instead of plain text variables.

variable "strapi_app_keys" {
  description = "Comma-separated list of application keys for Strapi."
  type        = string
  sensitive   = true
  # Generate strong random keys for your actual application
  default = "changeThisKey1,andThisKey2AsWell"
}

variable "strapi_api_token_salt" {
  description = "API token salt for Strapi."
  type        = string
  sensitive   = true
  default     = "aStrongAndRandomApiTokenSalt"
}

variable "strapi_admin_jwt_secret" {
  description = "Admin JWT secret for Strapi."
  type        = string
  sensitive   = true
  default     = "aStrongAndRandomAdminJwtSecret"
}

variable "strapi_jwt_secret" {
  description = "JWT secret for Strapi."
  type        = string
  sensitive   = true
  default     = "aStrongAndRandomJwtSecret"
}

