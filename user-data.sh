#!/bin/bash
# Install Docker
yum update -y
amazon-linux-extras install docker -y
service docker start
usermod -a -G docker ec2-user

# Login to ECR
aws ecr get-login-password --region ${aws_region} | docker login --username AWS --password-stdin $(aws ecr describe-repositories --repository-names strapi-app --query "repositories[0].repositoryUri" --output text | cut -d/ -f1)

# Pull and run the Strapi container
docker pull ${strapi_image}
docker run -d -p 1337:1337 --name strapi-app ${strapi_image}
