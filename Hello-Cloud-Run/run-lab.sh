#!/bin/bash
# ==============================================================================
# Script: run-lab.sh
# Lab: Hello Cloud Run (CBL333)
# Course: Google Cloud Fundamentals: Core Infrastructure
# ==============================================================================

set -euo pipefail

echo "=========================================================="
echo " Starting Hello Cloud Run Lab Automation"
echo "=========================================================="

# 1. Set environment variables
export LOCATION="us-central1"
echo "[*] Setting compute region to ${LOCATION}..."
gcloud config set compute/region "${LOCATION}"

# 2. Enable Required APIs
echo "[*] Enabling Cloud Run and Artifact Registry APIs..."
gcloud services enable run.googleapis.com artifactregistry.googleapis.com

# 3. Create Artifact Registry Repository
echo "[*] Creating Artifact Registry repository 'my-repository'..."
if ! gcloud artifacts repositories describe my-repository --location="${LOCATION}" &>/dev/null; then
  gcloud artifacts repositories create my-repository \
    --repository-format=docker \
    --location="${LOCATION}" \
    --description="Docker repository"
else
  echo "[+] Repository 'my-repository' already exists."
fi

# Configure Docker credentials
echo "[*] Configuring Docker authentication for Artifact Registry..."
gcloud auth configure-docker "${LOCATION}-docker.pkg.dev" --quiet

# 4. Build and Push Container using Cloud Build
echo "[*] Submitting build to Cloud Build..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}/helloworld"

IMAGE_TAG="${LOCATION}-docker.pkg.dev/${GOOGLE_CLOUD_PROJECT}/my-repository/helloworld"
echo "[*] Building and tagging image: ${IMAGE_TAG}..."
gcloud builds submit --tag "${IMAGE_TAG}"

# 5. Deploy to Cloud Run
echo "[*] Deploying container image to Cloud Run service 'helloworld'..."
gcloud run deploy helloworld \
  --image "${IMAGE_TAG}" \
  --allow-unauthenticated \
  --region="${LOCATION}" \
  --quiet

echo "=========================================================="
echo " Lab Tasks 1 to 5 Completed Successfully!"
echo "=========================================================="
echo "Go to the Google Cloud Skills Boost lab page and click"
echo "'Check my progress' on all tasks to get your 100/100 score."
echo ""
echo "After receiving 100/100, you can optionally run:"
echo "  bash cleanup.sh"
echo "=========================================================="
