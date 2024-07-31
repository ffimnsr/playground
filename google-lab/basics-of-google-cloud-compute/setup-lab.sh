#!/usr/bin/env bash

set -euo pipefail

export REGION=us-central1
export ZONE=us-central1-c
export PROJECT_ID=$(gcloud config get-value project)

# Create a bucket
gsutil mb -l $REGION gs://$PROJECT_ID-bucket

# Create a VM instance
gcloud compute instances create my-instance \
  --project=$PROJECT_ID \
  --zone=$ZONE \
  --machine-type=e2-medium \
  --boot-disk-size=10GB \
  --subnet=default \
  --tags=http-server

# Create a disk
gcloud compute disks create mydisk \
  --size=200GB \
  --zone=$ZONE

# Attach the disk to the VM instance
gcloud compute instances attach-disk my-instance \
  --disk=mydisk \
  --zone=$ZONE

# SSH into the VM instance
gcloud compute ssh my-instance --zone=$ZONE

# Install nginx on the VM instance
sudo apt-get update && sudo apt-get install -y nginx
ps auwx | grep nginx
