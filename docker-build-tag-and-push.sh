#!/bin/bash

set -e

# optional
: "${AWS_REGION:=us-east-1}"
: "${DOCKER_COMPOSE_FILE:=./docker-compose.yml}"
: "${ENVIRONMENT:=dev}"

## required
: "${AWS_ACCOUNT_ID:-$AWS_ACCOUNT_ID}"
: "${IMAGE_TAG:-$IMAGE_TAG}"

ECR_REGISTRY_ENDPOINT="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"

echo "Account: $AWS_ACCOUNT_ID"

printf "\nECR Login...\n"
aws ecr get-login-password \
  --region $AWS_REGION \
  | docker login \
      --username AWS \
      --password-stdin $ECR_REGISTRY_ENDPOINT

printf "\nBuilding docker images...\n"
docker-compose -f $DOCKER_COMPOSE_FILE build

printf "\nTagging images...\n"
docker tag arc/dotnet-acm-cert-renewer-lambda:latest $ECR_REGISTRY_ENDPOINT/arc-${ENVIRONMENT}-dotnet-acm-cert-renewer-lambda:$IMAGE_TAG

printf "\nPushing images to ECR...\n"
docker push $ECR_REGISTRY_ENDPOINT/arc-${ENVIRONMENT}-dotnet-acm-cert-renewer-lambda:$IMAGE_TAG

echo "::set-output name=image::$IMAGE_NAME:$IMAGE_TAG"