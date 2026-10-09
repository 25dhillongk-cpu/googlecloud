# Lab: Hello Cloud Run (CBL333)

**Course**: Google Cloud Fundamentals: Core Infrastructure  
**Path**: Google Cloud Engineering Certificate  

---

## Overview

In this lab, you learn how to:
1. Enable the **Cloud Run** and **Artifact Registry** APIs.
2. Build a serverless, stateless Node.js / Express application.
3. Create an **Artifact Registry** repository.
4. Containerize the application and build it with **Cloud Build**.
5. Deploy the containerized application to **Cloud Run** with public HTTP access.
6. Clean up resources to prevent ongoing charges.

---

## Quick Automated Execution in Google Cloud Shell

Open Cloud Shell and run:

```bash
git clone https://github.com/25dhillongk-cpu/googlecloud.git
cd googlecloud/Hello-Cloud-Run
bash run-lab.sh
```

Once the script completes, return to the lab page and click **Check my progress** on all tasks.

---

## Step-by-Step Commands

### Task 1: Enable APIs & Configure Shell Environment
```bash
gcloud services enable run.googleapis.com artifactregistry.googleapis.com
gcloud config set compute/region us-central1
export LOCATION="us-central1"
```

### Task 2: Write the Sample Application
Create the app directory and files:
```bash
mkdir -p helloworld && cd helloworld
```
- `package.json`: Defines the Express app dependency and start script (`node index.js`).
- `index.js`: Express web server that reads `PORT` (defaults to 8080) and `NAME` environment variables and responds with `Hello World!`.

### Task 3: Create an Artifact Registry Repository
```bash
gcloud artifacts repositories create my-repository \
  --repository-format=docker \
  --location=$LOCATION \
  --description="Docker repository"

gcloud auth configure-docker $LOCATION-docker.pkg.dev --quiet
```
*(Verify: Check my progress - Create an Artifact Registry repository)*

### Task 4: Containerize and Build with Cloud Build
Create `Dockerfile`:
```dockerfile
FROM node:20-slim
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm install --only=production
COPY . ./
CMD [ "npm", "start" ]
```

Submit to Cloud Build:
```bash
gcloud builds submit --tag $LOCATION-docker.pkg.dev/$GOOGLE_CLOUD_PROJECT/my-repository/helloworld
```
*(Verify: Check my progress - Containerize your app and upload it to Artifact Registry)*

### Task 5: Deploy to Cloud Run
```bash
gcloud run deploy helloworld \
  --image $LOCATION-docker.pkg.dev/$GOOGLE_CLOUD_PROJECT/my-repository/helloworld \
  --allow-unauthenticated \
  --region=$LOCATION \
  --quiet
```
*(Verify: Check my progress - Deploy a containerized application on Cloud Run)*

---

### Task 6: Cleanup (After receiving 100/100 points)
```bash
gcloud artifacts docker images delete $LOCATION-docker.pkg.dev/$GOOGLE_CLOUD_PROJECT/my-repository/helloworld --quiet
gcloud run services delete helloworld --region=us-central1 --quiet
```
