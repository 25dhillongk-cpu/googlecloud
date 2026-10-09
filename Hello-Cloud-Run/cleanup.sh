#!/bin/bash
# ==============================================================================
# Script: cleanup.sh
# Lab: Hello Cloud Run (CBL333)
# ==============================================================================

set -euo pipefail

export LOCATION="us-central1"
IMAGE_TAG="${LOCATION}-docker.pkg.dev/${GOOGLE_CLOUD_PROJECT}/my-repository/helloworld"

echo "[*] Deleting Artifact Registry container image..."
gcloud artifacts docker images delete "${IMAGE_TAG}" --quiet || true

echo "[*] Deleting Cloud Run service 'helloworld'..."
gcloud run services delete helloworld --region="${LOCATION}" --quiet || true

echo "[+] Cleanup completed."
