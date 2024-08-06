#!/usr/bin/env bash

set -euo pipefail

export PROJECT_ID=$(gcloud config get-value project)
export PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')
export REGION=us-east1
gcloud config set compute/region $REGION

# Enable the required services
gcloud services enable \
  container.googleapis.com \
  clouddeploy.googleapis.com \
  artifactregistry.googleapis.com \
  cloudbuild.googleapis.com

# Grant the required roles to the Cloud Build service account
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member=serviceAccount:$(gcloud projects describe $PROJECT_ID \
  --format="value(projectNumber)")-compute@developer.gserviceaccount.com \
  --role="roles/clouddeploy.jobRunner"

# Grant the Cloud Build service account the necessary permissions
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member=serviceAccount:$(gcloud projects describe $PROJECT_ID \
  --format="value(projectNumber)")-compute@developer.gserviceaccount.com \
  --role="roles/container.developer"

# Create the Artifact Registry repository
gcloud artifacts repositories create cicd-challenge \
  --description="Image registry for tutorial web app" \
  --repository-format=docker \
  --location=$REGION

# Create the Kubernetes clusters
gcloud container clusters create cd-staging --node-locations=us-east1-c --num-nodes=1 --async
gcloud container clusters create cd-production --node-locations=us-east1-c --num-nodes=1 --async

# Clone the repository
cd ~/
git clone https://github.com/GoogleCloudPlatform/cloud-deploy-tutorials.git
cd cloud-deploy-tutorials
git checkout c3cae80 --quiet
cd tutorials/base

# Create the Skaffold configuration
envsubst < clouddeploy-config/skaffold.yaml.template > web/skaffold.yaml
cat web/skaffold.yaml

# Build the container images
cd web
skaffold build --interactive=false \
  --default-repo $REGION-docker.pkg.dev/$PROJECT_ID/cicd-challenge \
  --file-output artifacts.json
cd ..

# Create the delivery pipeline configuration
cp clouddeploy-config/delivery-pipeline.yaml.template clouddeploy-config/delivery-pipeline.yaml
sed -i "s/targetId: staging/targetId: cd-staging/" clouddeploy-config/delivery-pipeline.yaml
sed -i "s/targetId: prod/targetId: cd-production/" clouddeploy-config/delivery-pipeline.yaml
sed -i "/targetId: test/d" clouddeploy-config/delivery-pipeline.yaml

# Set the deployment region
gcloud config set deploy/region $REGION

# Apply the delivery pipeline configuration
gcloud beta deploy apply --file=clouddeploy-config/delivery-pipeline.yaml

# Verify the Kubernetes clusters
gcloud container clusters list --format="csv(name,status)"

# Rename the Kubernetes contexts
CONTEXTS=("cd-production" "cd-staging")
for CONTEXT in ${CONTEXTS[@]}
do
  gcloud container clusters get-credentials ${CONTEXT} --region ${REGION}
  kubectl config rename-context gke_${PROJECT_ID}_${REGION}_${CONTEXT} ${CONTEXT}
done

# Create the Kubernetes namespace
for CONTEXT in ${CONTEXTS[@]}
do
  kubectl --context ${CONTEXT} apply -f kubernetes-config/web-app-namespace.yaml
done

# Create delivery pipeline target configurations
envsubst < clouddeploy-config/target-staging.yaml.template > clouddeploy-config/target-cd-staging.yaml
envsubst < clouddeploy-config/target-prod.yaml.template > clouddeploy-config/target-cd-production.yaml

sed -i "s/staging/cd-staging/" clouddeploy-config/target-cd-staging.yaml
sed -i "s/prod/cd-production/" clouddeploy-config/target-cd-production.yaml

# Apply the delivery pipeline target configurations
for CONTEXT in ${CONTEXTS[@]}
do
    envsubst < clouddeploy-config/target-$CONTEXT.yaml.template > clouddeploy-config/target-$CONTEXT.yaml
    gcloud beta deploy apply --file clouddeploy-config/target-$CONTEXT.yaml
done

# Create a release
gcloud beta deploy releases create web-app-001 \
  --delivery-pipeline web-app \
  --build-artifacts web/artifacts.json \
  --source web/

# Check release status
gcloud beta deploy rollouts list \
--delivery-pipeline web-app \
--release web-app-001

# Promote the release
gcloud beta deploy releases promote \
  --delivery-pipeline web-app \
  --release web-app-001

# Approve the release
gcloud beta deploy rollouts approve web-app-001-to-cd-production-0001 \
--delivery-pipeline web-app \
--release web-app-001 \
--quiet

# Create a second build with modified content
cd web
skaffold build --interactive=false \
  --default-repo $REGION-docker.pkg.dev/$DEVSHELL_PROJECT_ID/cicd-challenge \
  --file-output artifacts.json
cd ..

# Create a second release
gcloud beta deploy releases create web-app-002 \
  --delivery-pipeline web-app \
  --build-artifacts web/artifacts.json \
  --source web/

# Check the status of the second release
gcloud beta deploy rollouts list \
  --delivery-pipeline web-app \
  --release web-app-002

# Roll back the release
gcloud deploy targets rollback cd-staging \
  --delivery-pipeline=web-app \
  --quiet
