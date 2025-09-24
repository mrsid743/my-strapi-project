#
# --- AWS Configuration ---
#

variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "ap-south-1"
}

variable "aws_key_pair_name" {
  description = "The name of the EC2 key pair to use for SSH access."
  type        = string
  default     = "strapi-mumbai-key"
}

#
# --- Docker & Strapi Configuration ---
#

variable "image_tag" {
  description = "The Docker image tag to deploy (provided by GitHub Actions)."
  type        = string
}

#
# --- Strapi Environment Variables (Secrets) ---
# NOTE: These are placeholders. You should override these with secure values.
#

variable "strapi_app_keys" {
  description = "Strapi application keys for security."
  type        = string
  sensitive   = true
  default     = "changeThisKey1,andThisKey2AsWell" # Replace with generated keys
}

variable "strapi_api_token_salt" {
  description = "Salt for API tokens."
  type        = string
  sensitive   = true
  default     = "changeThisSalt" # Replace with generated salt
}

variable "strapi_admin_jwt_secret" {
  description = "JWT secret for the admin panel."
  type        = string
  sensitive   = true
  default     = "changeThisAdminSecret" # Replace with generated secret
}

variable "strapi_jwt_secret" {
  description = "JWT secret for user sessions."
  type        = string
  sensitive   = true
  default     = "changeThisJwtSecret" # Replace with generated secret
}


#
# --- Strapi Database Configuration ---
# NOTE: Using placeholder values for a simple SQLite setup.
# For production, you would connect to a managed database like RDS.
#

variable "strapi_database_client" {
  description = "The database client for Strapi."
  type        = string
  default     = "sqlite"
}

variable "strapi_database_host" {
  description = "The database host."
  type        = string
  default     = "127.0.0.1" # Not used by SQLite
}

variable "strapi_database_port" {
  description = "The database port."
  type        = number
  default     = 5432 # Not used by SQLite
}

variable "strapi_database_name" {
  description = "The database name."
  type        = string
  default     = "strapi"
}

variable "strapi_database_username" {
  description = "The database username."
  type        = string
  default     = "strapi"
}

variable "strapi_database_password" {
  description = "The database password."
  type        = string
  sensitive   = true
  default     = "strapi"
}

