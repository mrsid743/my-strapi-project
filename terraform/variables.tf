variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "image_tag" {
  type    = string
  default = "latest"
  description = "Docker image tag to pull from ECR (e.g. short sha)"
}

variable "ssh_key_name" {
  type    = string
  default = "strapi-mumbai-key"
}

# Optional: if you want TF to create a key-pair, provide your public key here.
variable "ssh_public_key" {
  type    = string
  default = ""
  description = "Public SSH key material (if empty, TF will NOT create the keypair; use an existing keypair name instead)"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "ami" {
  type    = string
  description = "AMI to use (Amazon Linux 2) - default uses data resource to lookup latest"
  default = ""
}