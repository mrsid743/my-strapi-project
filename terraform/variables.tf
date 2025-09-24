variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "ap-south-1"
}

variable "instance_type" {
  description = "The EC2 instance type."
  type        = string
  default     = "t2.micro"
}

variable "ecr_repo_name" {
  description = "The name of the ECR repository."
  type        = string
  default     = "siddhant-strapi"
}

variable "image_tag" {
  description = "The Docker image tag to deploy (typically the git SHA)."
  type        = string
}

variable "security_group_id" {
  description = "The ID of the security group to attach to the EC2 instance."
  type        = string
  sensitive   = true
}

variable "ssh_key_name" {
  description = "The name of the EC2 key pair for SSH access."
  type        = string
}

