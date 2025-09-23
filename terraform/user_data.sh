#!/bin/bash
# This script is executed by the EC2 instance upon launch.
# It installs Docker and runs the Strapi container.

# Exit immediately if a command exits with a non-zero status.
set -euxo pipefail

# Update all installed packages
yum update -y

# Install Docker
yum install docker -y

# Start the Docker service
service docker start

# Add the ec2-user to the docker group so you can execute Docker commands without sudo.
usermod -a -G docker ec2-user

# --- Run Strapi Docker Container ---

# Pull the Strapi image from Docker Hub.
# Note: Login is not required for public repositories.
docker pull ${dockerhub_username}/strapi-app:${strapi_image_tag}

# Run the Docker container
# It maps port 1337 of the container to port 1337 on the host EC2 machine.
# --restart always ensures the container restarts if it stops or the server reboots.
docker run -d -p 1337:1337 --name strapi-app --restart always ${dockerhub_username}/strapi-app:${strapi_image_tag}
