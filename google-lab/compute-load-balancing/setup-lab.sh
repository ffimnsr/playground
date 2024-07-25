#!/usr/bin/env bash

set -euo pipefail

export REGION=us-west4
export ZONE=us-west4-c
export PROJECT_ID=$(gcloud config get-value project)
export FW_NAME=accept-tcp-rule-563
export JUMPHOST_INSTANCE=nucleus-jumphost-813

gcloud config set compute/region $REGION
gcloud config set compute/zone $ZONE

gcloud compute instances create $JUMPHOST_INSTANCE \
  --zone=$ZONE \
  --tags=maintainer-tag \
  --machine-type=e2-micro \
  --image-family=debian-12 \
  --image-project=debian-cloud

cat << EOF > startup.sh
#! /bin/bash
apt-get update
apt-get install -y nginx
service nginx start
sed -i -- 's/nginx/Google Cloud Platform - '"\$HOSTNAME"'/' /var/www/html/index.nginx-debian.html
EOF

# Create an LB template.
gcloud compute instance-templates create nucleus-lb-backend-template \
  --region=$REGION \
  --network=default \
  --subnet=default \
  --tags=allow-health-check \
  --machine-type=e2-medium \
  --image-family=debian-12 \
  --image-project=debian-cloud \
  --metadata-from-file=startup-script=startup.sh

# Create a managed instance group based on the template.
gcloud compute instance-groups managed create nucleus-lb-backend-group \
  --base-instance-name=nucleus-lb-backend \
  --template=nucleus-lb-backend-template \
  --region=$REGION \
  --size=2

# Set named ports for the instance group.
gcloud compute instance-groups managed set-named-ports nucleus-lb-backend-group \
  --named-ports=http:80 \
  --region=$REGION

# Create a firewall rule to allow traffic (80/tcp)
gcloud compute firewall-rules create $FW_NAME \
  --target-tags=allow-health-check \
  --network=default \
  --action=allow \
  --direction=ingress \
  --rules=tcp:80

# Create a static external IP address for the load balancer.
gcloud compute addresses create nucleus-lb-ipv4-1 \
  --ip-version=IPV4 \
  --global

# Get the address.
gcloud compute addresses describe nucleus-lb-ipv4-1 \
  --format="get(address)" \
  --global

# Create a health check for LB.
gcloud compute health-checks create http nucleus-http-basic-check \
  --port 80

# Create LB backend service.
gcloud compute backend-services create nucleus-web-backend-service \
  --protocol=HTTP \
  --port-name=http \
  --health-checks=nucleus-http-basic-check \
  --global

# Add the instance group to the backend service.
gcloud compute backend-services add-backend nucleus-web-backend-service \
  --instance-group=nucleus-lb-backend-group \
  --instance-group-region=$REGION \
  --global

# Create a URL map to route requests to the backend service.
gcloud compute url-maps create nucleus-web-map-http \
    --default-service nucleus-web-backend-service

# Create a target HTTP proxy to route requests to the URL map.
gcloud compute target-http-proxies create nucleus-http-lb-proxy \
    --url-map nucleus-web-map-http

# Create a global forwarding rule to route incoming requests to the proxy.
gcloud compute forwarding-rules create nucleus-http-content-rule \
   --address=nucleus-lb-ipv4-1\
   --global \
   --target-http-proxy=nucleus-http-lb-proxy \
   --ports=80

# List the forwarding rules.
gcloud compute forwarding-rules list

echo http://$(gcloud compute addresses describe nucleus-lb-ipv4-1 --format="get(address)" --global)
