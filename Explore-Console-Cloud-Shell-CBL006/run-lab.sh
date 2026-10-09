#!/bin/bash
# ==============================================================================
# Script: run-lab.sh
# Lab: Explore the Google Cloud Console and Cloud Shell (CBL006)
# Course: Essential Google Cloud Infrastructure: Foundation
# ==============================================================================

set -euo pipefail

echo "=========================================================="
echo " Starting Automation for CBL006"
echo "=========================================================="

# Task 1 & 3: Create buckets using Cloud Shell
# Using PROJECT_ID to ensure globally unique bucket names
BUCKET1="gs://${GOOGLE_CLOUD_PROJECT}-bucket-1"
BUCKET2="gs://${GOOGLE_CLOUD_PROJECT}-bucket-2"

echo "[*] Creating buckets..."
gcloud storage buckets create "${BUCKET1}" --location=us-central1 || true
gcloud storage buckets create "${BUCKET2}" --location=us-central1 || true

# Task 4: Upload a file to the bucket
echo "[*] Creating and uploading a sample file..."
echo "This is a sample file for Cloud Storage" > sample_file.txt
gcloud storage cp sample_file.txt "${BUCKET1}/"

# Task 5: Create a persistent state in Cloud Shell
echo "[*] Configuring persistent environment variables..."
cd ~
mkdir -p infraclass
touch infraclass/config

echo "INFRACLASS_REGION=us-central1" > infraclass/config
echo "INFRACLASS_PROJECT_ID=${GOOGLE_CLOUD_PROJECT}" >> infraclass/config

# Append to .profile if it doesn't already exist
if ! grep -q "source infraclass/config" .profile 2>/dev/null; then
    echo "source infraclass/config" >> .profile
    echo "[+] Added persistent source config to ~/.profile"
else
    echo "[+] ~/.profile already contains the source config."
fi

echo "=========================================================="
echo " Lab Tasks 1 to 6 Completed Successfully!"
echo "=========================================================="
echo "Go to the Google Cloud Skills Boost lab page and click"
echo "'Check my progress' on all tasks to get your 100/100 score."
echo "=========================================================="
