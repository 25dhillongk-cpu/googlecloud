# Lab: Deploy a LAMP Stack with Google Cloud Marketplace (CBL011)

**Course**: Essential Google Cloud Infrastructure: Foundation  
**Path**: Google Cloud Engineering Certificate  

---

## Overview

In this lab, you use **Google Cloud Marketplace** to quickly and easily deploy a **LAMP stack** on a Compute Engine instance. The Google Click to Deploy LAMP Stack provides a complete web development environment for Linux that can be launched in one click.

- **Linux**: Operating system
- **Apache HTTP Server**: Web server
- **MySQL**: Relational database
- **PHP**: Web application framework
- **phpMyAdmin**: PHP administration tool

---

## Deployment Steps (Console)

Because this lab specifically tests the Google Cloud Marketplace Deployment Manager integration, doing this directly in the Google Cloud Web Console is the most reliable way to pass the lab checks.

1. Open the **Navigation menu** and select **Marketplace**.
2. Search for `LAMP` and press Enter.
3. Select **LAMP Stack** (by Google Click to Deploy).
4. Click **Get Started**, accept the terms, and click **Deploy**.
5. Configure the deployment:
   - **Zone**: `europe-west1-d` (or your lab-provided zone).
   - **Series**: `E2`
   - **Machine Type**: `e2-medium`
6. Leave everything else as default and click **Deploy**.
7. Wait for the deployment to show as complete (`lamp-1 has been deployed`).

---

## Verify Deployment

1. Once deployment is complete, go to **Deployment Manager** (or click details on the post-deployment screen).
2. Look for the **Site Url** link.
3. Click the link to verify the Apache HTTP Server is running and displaying the congratulations message.
