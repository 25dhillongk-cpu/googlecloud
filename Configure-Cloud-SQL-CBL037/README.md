# Lab: Configure Cloud SQL (CBL037)

**Course**: Essential Google Cloud Infrastructure: Core Services  
**Path**: Google Cloud Engineering Certificate  

---

## Overview

In this lab, you configure a Cloud SQL server and learn how to connect an application to it via a proxy over an external connection. You also configure a connection over a Private IP link that offers performance and security benefits.

### Objectives:
1. Enable the **Service Networking API**.
2. Create a **Cloud SQL (MySQL 8.0)** database instance (`wordpress-db`) configured with both Private IP (Private Services Access on default VPC) and Public IP.
3. Create a database named `wordpress`.
4. Configure and run the **Cloud SQL Auth Proxy** on `wordpress-proxy` virtual machine.
5. Connect WordPress to Cloud SQL using the local proxy (`127.0.0.1:3306`).
6. Connect WordPress to Cloud SQL using direct **Private IP** (`wordpress-private-ip` VM).

---

## Quick Automated Execution in Google Cloud Shell

Open Cloud Shell and run:

```bash
git clone https://github.com/25dhillongk-cpu/googlecloud.git
cd googlecloud/Configure-Cloud-SQL-CBL037
bash run-lab.sh
```

*(Note: Creating a Cloud SQL instance typically takes 3 to 5 minutes to provision).*

Once the script completes, return to the lab page and click **Check my progress** on:
- **Task 2**: Create a Cloud SQL instance
- **Task 3**: Create a database and configure a proxy on a Virtual Machine

---

## Manual Step-by-Step Instructions

### Task 1: Enable APIs
```bash
gcloud services enable servicenetworking.googleapis.com
```

### Task 2: Configure Private IP Peering & Cloud SQL Instance
```bash
# Reserve global IP range for Private Services Access
gcloud compute addresses create google-managed-services-default \
    --global \
    --purpose=VPC_PEERING \
    --prefix-length=16 \
    --description="peering range for Cloud SQL" \
    --network=default

# Create VPC peering connection
gcloud services vpc-peerings connect \
    --service=servicenetworking.googleapis.com \
    --ranges=google-managed-services-default \
    --network=default

# Create Cloud SQL instance
gcloud sql instances create wordpress-db \
    --database-version=MYSQL_8_0 \
    --tier=db-custom-1-3840 \
    --region=us-east4 \
    --zone=us-east4-c \
    --storage-size=10GB \
    --storage-type=SSD \
    --network=default \
    --assign-ip \
    --root-password=password123
```

### Task 3: Create Database & Start Cloud SQL Proxy
```bash
# Create the database
gcloud sql databases create wordpress --instance=wordpress-db

# Get the connection name
SQL_CONNECTION=$(gcloud sql instances describe wordpress-db --format="value(connectionName)")

# SSH into wordpress-proxy and start Cloud SQL Proxy
wget https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64 -O cloud_sql_proxy && chmod +x cloud_sql_proxy
./cloud_sql_proxy -instances=$SQL_CONNECTION=tcp:3306 &
```

### Task 4: Connect Application via Proxy
1. Find external IP of `wordpress-proxy`.
2. Navigate to `http://<PROXY_EXTERNAL_IP>` in browser.
3. Fill in connection details:
   - **Database Name**: `wordpress`
   - **Username**: `root`
   - **Password**: `password123`
   - **Database Host**: `127.0.0.1`
4. Click **Submit** -> **Run the installation**.

### Task 5: Connect Application via Private IP
1. Find private IP of `wordpress-db` (`gcloud sql instances describe wordpress-db --format="value(ipAddresses.filter(type:PRIVATE).ipAddress)"`).
2. Find external IP of `wordpress-private-ip` VM.
3. Navigate to `http://<PRIVATE_VM_EXTERNAL_IP>` in browser.
4. Fill in connection details:
   - **Database Name**: `wordpress`
   - **Username**: `root`
   - **Password**: `password123`
   - **Database Host**: `<SQL_PRIVATE_IP>`
5. Click **Submit** -> **Run the installation** ("Already Installed!" confirms successful private connection).
