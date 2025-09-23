# .github/workflows/terraform.yml
# This file contains the corrected syntax for the terraform apply command.

name: CD - Deploy to EC2 with Terraform

on:
  # Allows you to run this workflow manually from the Actions tab
  workflow_dispatch:

jobs:
  deploy:
    name: Deploy to AWS
    runs-on: ubuntu-latest
    
    permissions:
      contents: read
      actions: read

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Download image tag artifact
        uses: actions/download-artifact@v4
        with:
          name: image_tag
          path: .

      - name: Read image tag
        id: image_tag
        run: echo "TAG=$(cat image_tag.txt)" >> $GITHUB_OUTPUT

      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ap-south-1

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: 1.7.5

      - name: Terraform Init
        working-directory: ./terraform
        run: terraform init

      - name: Terraform Apply
        working-directory: ./terraform
        # FIX: The command is now on a single line to prevent shell syntax errors.
        run: terraform apply -auto-approve -var="strapi_image_tag=${{ steps.image_tag.outputs.TAG }}" -var="dockerhub_username=${{ secrets.DOCKERHUB_USERNAME }}" -var="aws_region=ap-south-1"

