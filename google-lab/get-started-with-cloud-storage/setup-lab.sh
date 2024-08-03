#!/usr/bin/env bash

set -euo pipefail

export PROJECT_ID=$(gcloud config get-value project)

# Create a Cloud Storage bucket
gsutil mb gs://$PROJECT_ID-bucket

# Create a retention policy for the bucket
gsutil retention set 30s gs://$PROJECT_ID-gcs-bucket

# Copy file to the bucket
touch final-task.txt
gsutil cp final-task.txt gs://$PROJECT_ID-bucket-ops
