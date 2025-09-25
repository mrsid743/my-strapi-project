variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "ap-south-1"
}

variable "ecr_repository_name" {
  description = "The name of the ECR repository."
  type        = string
  default     = "siddhant-strapi"
}

variable "aws_key_pair_name" {
  description = "The name of the EC2 key pair to use for SSH access."
  type        = string
  default     = "strapi-mumbai-key"
}

variable "ec2_instance_type" {
  description = "The instance type for the EC2 server."
  type        = string
  default     = "t2.micro"
}

variable "image_tag" {
  description = "The Docker image tag to deploy. This is passed from the CI workflow."
  type        = string
}

variable "existing_iam_instance_profile_name" {
  description = "Optional: Use an existing IAM Instance Profile for the EC2 instance instead of creating a new one."
  type        = string
  default     = ""
}

variable "strapi_app_keys" {
  description = "Comma-separated list of secret keys for Strapi."
  type        = string
  sensitive   = true
  default     = "changeThisKey1,andThisKey2AsWell"
}

variable "strapi_api_token_salt" {
  description = "Salt for API tokens."
  type        = string
  sensitive   = true
  default     = "changeThisSalt"
}

variable "strapi_admin_jwt_secret" {
  description = "JWT secret for the admin panel."
  type        = string
  sensitive   = true
  default     = "changeThisAdminSecret"
}

variable "strapi_jwt_secret" {
  description = "JWT secret for API users."
  type        = string
  sensitive   = true
  default     = "changeThisJwtSecret"
}
