#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status.

# --- Install Docker ---
sudo yum update -y
sudo yum install -y docker
sudo service docker start
sudo usermod -a -G docker ec2-user

# --- Docker Hub Login ---
# For production, it's more secure to retrieve credentials from AWS Secrets Manager.
# This is a placeholder for basic setup.
# docker login -u YOUR_DOCKERHUB_USERNAME -p YOUR_DOCKERHUB_PASSWORD

# --- Pull the latest Strapi image ---
# The values for 'dockerhub_username' and 'strapi_image_tag' are injected by Terraform.
docker pull ${dockerhub_username}/strapi-app:${strapi_image_tag}

# --- Stop and remove any existing container named 'strapi' to avoid conflicts ---
docker stop strapi || true
docker rm strapi || true

# --- Run the new Strapi container ---
# IMPORTANT: Replace the placeholder values below with your actual database credentials and secrets.
# For a production setup, these should be managed securely (e.g., AWS Secrets Manager)
# and passed into the container.

docker run -d \
  -p 1337:1337 \
  --name strapi \
  --restart unless-stopped \
  -e DATABASE_CLIENT="postgres" \
  -e DATABASE_HOST="postgres_db.rds.amazonaws.com" \
  -e DATABASE_PORT="5432" \
  -e DATABASE_NAME="POSTGRES_DB:-strapidb" \
  -e DATABASE_USERNAME="strapiuser" \
  -e DATABASE_PASSWORD="strapipassword" \
  -e JWT_SECRET="9OpxjM4Wgoip7uYn88oGgn+VTZBhd4z0G5fezNiUP34=" \
  -e ADMIN_JWT_SECRET="randomAdminJwtSecret123456" \
  -e API_TOKEN_SALT="randomApiTokenSalt123456" \
  -e APP_KEYS="p1YOYRwenx6LMvJaAimF6LQdsp9h3WfGo0j9bNNVS7g=,jRn6KPGe4nxCsaIgA5npcoYK5+jvPCQ4sxeg7rQqp7k=,zLJ+q1U3ncxZV/21VRb/UVgL53bl0RYp0f75LQDJItc=,kPUv12KNE5gtrxPcO11phoMXkIWD2CYa1PHlsFDo2K4=" \
  ${dockerhub_username}/strapi-app:${strapi_image_tag}

