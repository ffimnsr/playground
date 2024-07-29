#!/usr/bin/env bash

set -euo pipefail

export GCP_PROJECT=qwiklabs-gcp-02-86e07374ace6
export GCP_REGION=us-central1

python3 -m venv .venv
source .venv/bin/activate
python3 -m pip install -r requirements.txt

streamlit run chef.py \
  --browser.serverAddress=localhost \
  --server.enableCORS=false \
  --server.enableXsrfProtection=false \
  --server.port 8080

export AR_REPO=chef-repo
export SERVICE_NAME=chef-streamlit-app

gcloud artifacts repositories create "$AR_REPO" \
  --location=$GCP_REGION \
  --repository-format=Docker

gcloud builds submit --tag "$GCP_REGION-docker.pkg.dev/$GCP_PROJECT/$AR_REPO/$SERVICE_NAME"

gcloud run deploy "$SERVICE_NAME" \
  --port=8080 \
  --image="$GCP_REGION-docker.pkg.dev/$GCP_PROJECT/$AR_REPO/$SERVICE_NAME" \
  --allow-unauthenticated \
  --region=$GCP_REGION \
  --platform=managed  \
  --project=$GCP_PROJECT \
  --set-env-vars=GCP_PROJECT=$GCP_PROJECT,GCP_REGION=$GCP_REGION
