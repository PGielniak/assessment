#!/bin/bash
set -e

ENVIRONMENT=$1
IMAGE_TAG=$2
PATH_TO_TERRAFORM="../../terraform"
PATH_TO_DB="../../terraform-database-init"

PATH_TO_TERRAFORM_ENVIRONMENT="${PATH_TO_TERRAFORM}/environments"
PATH_TO_DB_ENVIRONMENT="${PATH_TO_DB}/environments"

cd $PATH_TO_TERRAFORM
terraform init -backend-config="${PATH_TO_TERRAFORM_ENVIRONMENT}/${ENVIRONMENT}/backend.tfbackend"
terraform apply -var-file="${PATH_TO_TERRAFORM_ENVIRONMENT}/${ENVIRONMENT}/terraform.tfvars" -auto-approve -var="docker_tag=${IMAGE_TAG}"

