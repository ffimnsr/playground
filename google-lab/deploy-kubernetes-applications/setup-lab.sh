#!/usr/bin/env bash

set -euo pipefail

export PROJECT_ID=$(gcloud config get-value project)
export REGION=us-east1
export ZONE=us-east1-b

# Set the default region
gcloud config set compute/region $REGION

# Install marking scripts to check progress
source <(gsutil cat gs://cloud-training/gsp318/marking/setup_marking_v2.sh)

# Clone the source repository
gcloud source repos clone valkyrie-app

# Change to the source code directory
cd valkyrie-app

# Create a Dockerfile
cat << EOF > Dockerfile
FROM golang:1.10
WORKDIR /go/src/app
COPY source .
RUN go install -v
ENTRYPOINT ["app","-single=true","-port=8080"]
EOF

# Build the Docker image
IMAGE_NAME=valkyrie-prod
TAG_NAME=v0.0.1
docker build -t $IMAGE_NAME:$TAG_NAME .

# Check progress
bash ~/marking/step1_v2.sh

# Run the Docker image
docker run -p 8080:8080 $IMAGE_NAME:$TAG_NAME &

# Check progress
bash ~/marking/step2_v2.sh

# Create a new artifact repository
REPO_NAME=valkyrie-docker
gcloud artifacts repositories create $REPO_NAME \
  --repository-format=docker \
  --location=$REGION \
  --async

# Get docker repo authentication
gcloud auth configure-docker $REGION-docker.pkg.dev --quiet

# Push the Docker image to the artifact repository
IMAGE_ID=$(docker images --format='{{.ID}}')
docker push $IMAGE_ID $REGION-docker.pkg.dev/$PROJECT_ID/$REPO_NAME/$IMAGE_NAME:$TAG_NAME

# Replace the image in the deployment file
sed -i "s/IMAGE_HERE/$REGION-docker.pkg.dev\/$PROJECT_ID\/$REPO_NAME\/$IMAGE_NAME:$TAG_NAME/g" k8s/deployment.yaml

# Get kubectl credentials
gcloud container clusters get-credentials valkyrie-dev --zone=$ZONE

# Create a deployment and service
kubectl create -f k8s/deployment.yaml
kubectl create -f k8s/service.yaml
