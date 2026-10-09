#!/bin/bash
# ==============================================================================
# Script: run-lab.sh
# Lab: Create and Configure VPC Networks (CBL057)
# Course: Essential Google Cloud Infrastructure: Foundation
# ==============================================================================

set -euo pipefail

echo "=========================================================="
echo " Starting Automation for CBL057"
echo "=========================================================="

echo "[*] Enabling Required APIs..."
gcloud services enable iap.googleapis.com networkmanagement.googleapis.com

echo "=== Task 1: Delete default network and firewall rules ==="
echo "[*] Removing default firewall rules..."
gcloud compute firewall-rules list --filter="network:default" --format="value(name)" > fw_rules.txt
if [ -s fw_rules.txt ]; then
    xargs gcloud compute firewall-rules delete -q < fw_rules.txt
fi
rm -f fw_rules.txt

echo "[*] Removing default VPC network..."
gcloud compute networks delete default -q || true

echo "=== Task 2: Create auto mode network, firewall rules, and VMs ==="
echo "[*] Creating auto mode network 'mynetwork'..."
gcloud compute networks create mynetwork --subnet-mode=auto

# Replicating standard firewall rules created via console
echo "[*] Creating standard firewall rules for mynetwork..."
gcloud compute firewall-rules create mynetwork-allow-icmp --network=mynetwork --allow=icmp --source-ranges=0.0.0.0/0 || true
gcloud compute firewall-rules create mynetwork-allow-ssh --network=mynetwork --allow=tcp:22 --source-ranges=0.0.0.0/0 || true
gcloud compute firewall-rules create mynetwork-allow-rdp --network=mynetwork --allow=tcp:3389 --source-ranges=0.0.0.0/0 || true
gcloud compute firewall-rules create mynetwork-allow-custom --network=mynetwork --allow=all --source-ranges=10.128.0.0/9 || true

echo "[*] Creating IAP SSH firewall rule..."
gcloud compute firewall-rules create allow-iap-ssh \
    --network=mynetwork \
    --priority=1000 \
    --direction=INGRESS \
    --action=ALLOW \
    --target-tags=iap-gce \
    --source-ranges=35.235.240.0/20 \
    --rules=tcp:22

echo "[*] Creating VM 'mynet-us-vm' in us-east1-d..."
gcloud compute instances create mynet-us-vm \
    --zone=us-east1-d \
    --machine-type=e2-medium \
    --network=mynetwork \
    --image-family=debian-12 \
    --image-project=debian-cloud \
    --tags=iap-gce

echo "[*] Creating VM 'mynet-notus-vm' in asia-south1-b..."
gcloud compute instances create mynet-notus-vm \
    --zone=asia-south1-b \
    --machine-type=e2-medium \
    --network=mynetwork \
    --image-family=debian-12 \
    --image-project=debian-cloud \
    --tags=iap-gce

echo "[*] Converting mynetwork to custom mode..."
gcloud compute networks update mynetwork --switch-to-custom-subnet-mode

echo "=== Task 3: Create custom mode networks ==="
echo "[*] Creating 'managementnet' and subnets..."
gcloud compute networks create managementnet --subnet-mode=custom
gcloud compute networks subnets create managementsubnet-us \
    --network=managementnet \
    --region=us-east1 \
    --range=10.240.0.0/20

echo "[*] Creating 'privatenet' and subnets..."
gcloud compute networks create privatenet --subnet-mode=custom
gcloud compute networks subnets create privatesubnet-us \
    --network=privatenet \
    --region=us-east1 \
    --range=172.16.0.0/24
gcloud compute networks subnets create privatesubnet-notus \
    --network=privatenet \
    --region=asia-south1 \
    --range=172.20.0.0/20

echo "[*] Creating firewall rules for custom networks..."
gcloud compute firewall-rules create managementnet-allow-icmp-ssh-rdp \
    --network=managementnet \
    --direction=INGRESS \
    --priority=1000 \
    --action=ALLOW \
    --rules=icmp,tcp:22,tcp:3389 \
    --source-ranges=0.0.0.0/0

gcloud compute firewall-rules create privatenet-allow-icmp-ssh-rdp \
    --network=privatenet \
    --direction=INGRESS \
    --priority=1000 \
    --action=ALLOW \
    --rules=icmp,tcp:22,tcp:3389 \
    --source-ranges=0.0.0.0/0

echo "[*] Creating VM 'managementnet-us-vm'..."
gcloud compute instances create managementnet-us-vm \
    --zone=us-east1-d \
    --machine-type=e2-micro \
    --subnet=managementsubnet-us \
    --image-family=debian-12 \
    --image-project=debian-cloud

echo "[*] Creating VM 'privatenet-us-vm'..."
gcloud compute instances create privatenet-us-vm \
    --zone=us-east1-d \
    --machine-type=e2-micro \
    --subnet=privatesubnet-us \
    --image-family=debian-12 \
    --image-project=debian-cloud \
    --boot-disk-size=10GB \
    --boot-disk-type=pd-standard \
    --boot-disk-device-name=privatenet-us-vm

echo "=========================================================="
echo " Lab Configuration Complete!"
echo " Go to the Google Cloud Skills Boost lab page and click"
echo " 'Check my progress' on all tasks to get your score."
echo "=========================================================="
