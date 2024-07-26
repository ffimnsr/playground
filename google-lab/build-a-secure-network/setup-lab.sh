#!/usr/bin/env bash

set -euo pipefail


export SSH_IAP_NETWORK_TAG=grant-ssh-iap-ingress-ql-138
export SSH_INTERNAL_NETWORK_TAG=grant-ssh-internal-ingress-ql-138
export HTTP_NETWORK_TAG=grant-http-ingress-ql-138
export ZONE=us-central1-c

# Delete the overly permissive firewall rule.
gcloud compute firewall-rules delete open-access

# Create a firewall rule to allow SSH access from the IAP (Identity-Aware Proxy) service.
# The source range comes from this doc:
#   https://cloud.google.com/iap/docs/using-tcp-forwarding
gcloud compute firewall-rules create ssh-ingress --allow=tcp:22 --source-ranges 35.235.240.0/20 --target-tags $SSH_IAP_NETWORK_TAG --network acme-vpc

# Add tags to the bastion host.
gcloud compute instances add-tags bastion --tags=$SSH_IAP_NETWORK_TAG --zone=$ZONE

# Create a firewall rule to allow HTTP traffic from any external addresses.
gcloud compute firewall-rules create http-ingress --allow=tcp:80 --source-ranges 0.0.0.0/0 --target-tags $HTTP_NETWORK_TAG --network acme-vpc

# Add tags to the juice-shop instance.
gcloud compute instances add-tags juice-shop --tags=$HTTP_NETWORK_TAG --zone=$ZONE
gcloud compute instances add-tags juice-shop --tags=$SSH_INTERNAL_NETWORK_TAG --zone=$ZONE

# Create a firewall rule to allow SSH access from the internal network.
# The source range comes from the acme-mgmt-subnet in the acme-vpc network.
#   gcloud compute networks describe acme-vpc
#   gcloud compute networks subnets describe acme-mgmt-subnet --region=${ZONE%-*}
gcloud compute firewall-rules create internal-ssh-ingress --allow=tcp:22 --source-ranges 192.168.10.0/24 --target-tags $SSH_INTERNAL_NETWORK_TAG --network acme-vpc

# Connect to the bastion host.
gcloud compute ssh bastion --zone=$ZONE

# Then inside the bastion host, run the following command to SSH into the juice-shop instance.
gcloud compute ssh juice-shop --internal-ip
