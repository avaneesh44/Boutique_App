#!/bin/bash
# src/docker_image_buid_push.sh

set -e

AWS_REGION="ap-northeast-1"
AWS_ACCOUNT_ID="029767002935"
ECR_URI="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
TAG=$(git rev-parse --short HEAD 2>/dev/null || date +%s)

echo "🔹 Logging in to Amazon ECR..."
aws ecr get-login-password --region "$AWS_REGION" \
| docker login --username AWS --password-stdin "$ECR_URI"

echo "🔹 Searching for Dockerfiles in ./src/"
# Determine the base directory of the script
BASE_DIR="$(dirname "$0")"

# Find all Dockerfiles under BASE_DIR/src
# Find Dockerfiles inside src/<service>/Dockerfile
mapfile -t DOCKERFILES < <(find "$BASE_DIR/src" -mindepth 2 -maxdepth 2 -type f -name Dockerfile)

# Check if any Dockerfiles were found
if [ ${#DOCKERFILES[@]} -eq 0 ]; then
  echo "❌ No Dockerfiles found under $BASE_DIR/src. Expected: src/<service>/Dockerfile"
  exit 1
fi

echo "🔹 Found ${#DOCKERFILES[@]} services."
IMAGES=()

# Step 1: Build and tag each image
for dockerfile in "${DOCKERFILES[@]}"; do

  service=$(basename "$(dirname "$dockerfile")")
  image="${ECR_URI}/${service}:${TAG}"
  latest="${ECR_URI}/${service}:latest"
  IMAGES+=("$service")

  echo "🔹 Ensuring ECR repository exists for ${service}"

  aws ecr describe-repositories \
    --repository-names "$service" \
    --region "$AWS_REGION" >/dev/null 2>&1 \
  || aws ecr create-repository \
    --repository-name "$service" \
    --region "$AWS_REGION"

  echo "🚀 Building image for ${service}"
  docker build -t "$image" "$(dirname "$dockerfile")"

  docker tag "$image" "$latest"

done

# Step 2: Push commit tags
echo "🔹 Pushing all images with tag ${TAG}"

for service in "${IMAGES[@]}"; do
  image="${ECR_URI}/${service}:${TAG}"
  echo "⬆️  Pushing ${image}"
  docker push "$image"
done

# Step 3: Push latest tags
echo "🔹 Pushing all :latest tags"

for service in "${IMAGES[@]}"; do
  latest="${ECR_URI}/${service}:latest"
  echo "⬆️  Pushing ${latest}"
  docker push "$latest"
done

echo "🎉 All ${#IMAGES[@]} services pushed successfully to ${ECR_URI}"
echo "Tags pushed: ${TAG} and latest"