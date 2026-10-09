#!/bin/bash
# ==============================================================================
# Script: run-lab.sh
# Lab: Create Virtual Machines (CBL007)
# Course: Essential Google Cloud Infrastructure: Foundation
# ==============================================================================

set -euo pipefail

echo "=========================================================="
echo " Starting Automation for CBL007"
echo "=========================================================="

# Ensure zone is set, grabbing from gcloud config or falling back
ZONE=$(gcloud config get-value compute/zone 2>/dev/null || true)
if [ -z "$ZONE" ]; then
    # In some Qwiklabs, it's not set automatically in config, so we fall back
    ZONE="us-central1-f"
    echo "[*] No default zone found, setting to $ZONE"
    gcloud config set compute/zone $ZONE
else
    echo "[*] Using default zone: $ZONE"
fi

echo "=== Task 1: Create utility-vm ==="
gcloud compute instances create utility-vm \
    --zone=$ZONE \
    --machine-type=e2-medium \
    --no-address \
    --image-family=debian-12 \
    --image-project=debian-cloud || true

echo "=== Task 2: Create utility-wm (Windows VM) ==="
# Allow HTTP/HTTPS by adding network tags and making sure firewalls exist (though Qwiklabs usually pre-creates these)
gcloud compute instances create utility-wm \
    --zone=$ZONE \
    --machine-type=e2-standard-2 \
    --image-family=windows-2025-core \
    --image-project=windows-cloud \
    --boot-disk-size=64GB \
    --boot-disk-type=pd-ssd \
    --tags=http-server,https-server || true

echo "=== Task 3: Create utility-cm (Custom VM) ==="
gcloud compute instances create utility-cm \
    --zone=$ZONE \
    --custom-cpu=2 \
    --custom-memory=4GB \
    --image-family=debian-12 \
    --image-project=debian-cloud || true

echo "=========================================================="
echo " Lab Configuration Complete!"
echo " Go to the Google Cloud Skills Boost lab page and click"
echo " 'Check my progress' on all tasks to get your score."
echo "=========================================================="
