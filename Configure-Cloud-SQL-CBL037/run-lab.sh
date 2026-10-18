#!/bin/bash
# ==============================================================================
# Script: run-lab.sh
# Lab: Configure Cloud SQL (CBL037)
# Course: Essential Google Cloud Infrastructure: Core Services
# ==============================================================================

set -euo pipefail

echo "=========================================================="
echo " Starting Automation for Configure Cloud SQL (CBL037)"
echo "=========================================================="

ROOT_PASSWORD="password123"

# 1. Enable Required APIs
echo "[*] Enabling Service Networking API..."
gcloud services enable servicenetworking.googleapis.com

# 2. Identify target region and zone from existing VMs
PROXY_ZONE=$(gcloud compute instances list --filter="name=wordpress-proxy" --format="value(zone)" | head -n1)
if [ -z "$PROXY_ZONE" ]; then
    REGION="us-east4"
    ZONE="us-east4-c"
    echo "[!] Existing VM wordpress-proxy not found, using default: ${REGION} / ${ZONE}"
else
    ZONE="$PROXY_ZONE"
    REGION=$(echo "$ZONE" | sed 's/-[a-z]$//')
    echo "[*] Detected VM region/zone: ${REGION} / ${ZONE}"
fi

# 3. Create Private Services Access (PSA) IP Allocation & VPC Peering
echo "[*] Creating VPC Peering IP reservation..."
if ! gcloud compute addresses describe google-managed-services-default --global &>/dev/null; then
    gcloud compute addresses create google-managed-services-default \
        --global \
        --purpose=VPC_PEERING \
        --prefix-length=16 \
        --description="peering range for Cloud SQL" \
        --network=default
else
    echo "[+] IP range google-managed-services-default already exists."
fi

echo "[*] Connecting VPC peering with Service Networking..."
gcloud services vpc-peerings connect \
    --service=servicenetworking.googleapis.com \
    --ranges=google-managed-services-default \
    --network=default || true

# 4. Create Cloud SQL Instance: wordpress-db
echo "[*] Creating Cloud SQL instance wordpress-db (this may take 3-5 minutes)..."
if ! gcloud sql instances describe wordpress-db &>/dev/null; then
    gcloud sql instances create wordpress-db \
        --database-version=MYSQL_8_0 \
        --tier=db-custom-1-3840 \
        --region="${REGION}" \
        --zone="${ZONE}" \
        --storage-size=10GB \
        --storage-type=SSD \
        --network=default \
        --assign-ip \
        --root-password="${ROOT_PASSWORD}"
else
    echo "[+] Cloud SQL instance wordpress-db already exists."
fi

# 5. Create database 'wordpress'
echo "[*] Creating database 'wordpress'..."
if ! gcloud sql databases describe wordpress --instance=wordpress-db &>/dev/null; then
    gcloud sql databases create wordpress --instance=wordpress-db
else
    echo "[+] Database wordpress already exists."
fi

# 6. Retrieve Connection Details
SQL_CONNECTION=$(gcloud sql instances describe wordpress-db --format="value(connectionName)")
SQL_PRIVATE_IP=$(gcloud sql instances describe wordpress-db --format="value(ipAddresses.filter(type:PRIVATE).ipAddress)")
echo "[*] SQL Connection Name: ${SQL_CONNECTION}"
echo "[*] SQL Private IP: ${SQL_PRIVATE_IP}"

# 7. Configure Cloud SQL Proxy on wordpress-proxy VM
if [ -n "$PROXY_ZONE" ]; then
    echo "[*] Configuring and starting Cloud SQL Proxy on wordpress-proxy VM..."
    gcloud compute ssh wordpress-proxy --zone="${PROXY_ZONE}" --tunnel-through-iap --quiet --command="
        wget -q https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64 -O cloud_sql_proxy && chmod +x cloud_sql_proxy
        pkill cloud_sql_proxy 2>/dev/null || true
        nohup ./cloud_sql_proxy -instances=${SQL_CONNECTION}=tcp:3306 > proxy.log 2>&1 &
        sleep 3
        ps aux | grep cloud_sql_proxy
    "
fi

echo "=========================================================="
echo " Task 1, 2, and 3 Complete!"
echo " Click 'Check my progress' on the lab page now:"
echo "   1. Create a Cloud SQL instance"
echo "   2. Create a database and configure a proxy on a Virtual Machine"
echo "=========================================================="

# Display external IPs for manual verification (Task 4 & Task 5)
PROXY_EXT_IP=$(gcloud compute instances describe wordpress-proxy --zone="${PROXY_ZONE}" --format="value(networkInterfaces[0].accessConfigs[0].natIP)" 2>/dev/null || echo "N/A")
PRIVATE_VM_ZONE=$(gcloud compute instances list --filter="name=wordpress-private-ip" --format="value(zone)" | head -n1)
PRIVATE_VM_EXT_IP=""
if [ -n "$PRIVATE_VM_ZONE" ]; then
    PRIVATE_VM_EXT_IP=$(gcloud compute instances describe wordpress-private-ip --zone="${PRIVATE_VM_ZONE}" --format="value(networkInterfaces[0].accessConfigs[0].natIP)" 2>/dev/null || echo "N/A")
fi

echo ""
echo "=== Details for Task 4 (Wordpress via Proxy) ==="
echo "URL: http://${PROXY_EXT_IP}"
echo "Database Name: wordpress"
echo "Username: root"
echo "Password: ${ROOT_PASSWORD}"
echo "Database Host: 127.0.0.1"
echo ""
echo "=== Details for Task 5 (Wordpress via Private IP) ==="
echo "URL: http://${PRIVATE_VM_EXT_IP}"
echo "Database Name: wordpress"
echo "Username: root"
echo "Password: ${ROOT_PASSWORD}"
echo "Database Host: ${SQL_PRIVATE_IP}"
echo "=========================================================="
