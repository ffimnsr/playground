#!/usr/bin/env bash

set -euo pipefail

export PROJECT_ID=$(gcloud config get-value project)
export PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')
export REGION=us-east4

# Create pubsub schema
gcloud pubsub schemas create city-temp-schema \
  --type=avro \
  --definition='{
    "type": "record",
    "name": "Avro",
    "fields": [
      {
        "name": "city",
        "type": "string"
      },
      {
        "name": "temperature",
        "type": "double"
      },
      {
        "name": "pressure",
        "type": "int"
      },
      {
        "name": "time_position",
        "type": "string"
      }
    ]
  }'

# Create pubsub topic
gcloud pubsub topics create temp-topic \
  --message-encoding=JSON \
  --message-storage-policy-allowed-regions=$REGION \
  --schema=projects/$PROJECT_ID/schemas/temperature-schema

# Clone repo and deploy function
git clone https://github.com/GoogleCloudPlatform/nodejs-docs-samples.git
cd nodejs-docs-samples/functions/v2/helloPubSub/

# Add required permissions
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member=serviceAccount:$PROJECT_NUMBER-compute@developer.gserviceaccount.com \
  --role=roles/artifactregistry.reader

# Deploy function
gcloud functions deploy gcf-pubsub \
  --runtime=nodejs20 \
  --region=$REGION \
  --source=. \
  --entry-point=helloPubSub \
  --trigger-topic=gcf-topic
