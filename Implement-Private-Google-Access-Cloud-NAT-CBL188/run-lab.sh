#!/bin/bash
# ==============================================================================
# Script: run-lab.sh
# Lab: Implement Private Google Access and Cloud NAT (CBL188)
# Course: Essential Google Cloud Infrastructure: Foundation
# ==============================================================================

set -euo pipefail

export REGION="us-east1"
export ZONE="us-east1-b"

echo "=========================================================="
echo " Starting Automation for CBL188"
echo "=========================================================="

echo "=== Task 1: Create VPC network, firewall rules, and VM instance ==="
gcloud compute networks create privatenet --subnet-mode=custom
gcloud compute networks subnets create privatenet-us \
    --network=privatenet \
    --region=${REGION} \
    --range=10.130.0.0/20

gcloud compute firewall-rules create privatenet-allow-ssh \
    --network=privatenet \
    --direction=INGRESS \
    --action=ALLOW \
    --rules=tcp:22 \
    --source-ranges=35.235.240.0/20

gcloud compute instances create vm-internal \
    --zone=${ZONE} \
    --machine-type=e2-standard-2 \
    --network=privatenet \
    --subnet=privatenet-us \
    --no-address \
    --image-family=debian-12 \
    --image-project=debian-cloud

echo "=== Task 2: Create a Cloud Storage bucket and Enable Private Google Access ==="
export MY_BUCKET="${GOOGLE_CLOUD_PROJECT}-bucket-cbl188"
gcloud storage buckets create gs://$MY_BUCKET --location=US

# Copy public image to the bucket as instructed in the lab
gcloud storage cp gs://cloud-training/gcpnet/private/access.svg gs://$MY_BUCKET/ || true

# Enable Private Google Access on the subnet
gcloud compute networks subnets update privatenet-us \
    --region=${REGION} \
    --enable-private-ip-google-access

echo "=== Task 3 & 4: Configure a Cloud NAT gateway with Logging ==="
gcloud compute routers create nat-router \
    --network=privatenet \
    --region=${REGION}

gcloud compute routers nats create nat-config \
    --router=nat-router \
    --region=${REGION} \
    --auto-allocate-nat-external-ips \
    --nat-all-subnet-ip-ranges \
    --enable-logging \
    --log-filter=ALL

echo "=========================================================="
echo " Lab Configuration Complete!"
echo " Go to the Google Cloud Skills Boost lab page and click"
echo " 'Check my progress' on all tasks to get your score."
echo "=========================================================="
