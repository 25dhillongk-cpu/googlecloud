# Lab: Implement Private Google Access and Cloud NAT (CBL188)

**Course**: Essential Google Cloud Infrastructure: Foundation  
**Path**: Google Cloud Engineering Certificate  

---

## Overview

In this lab, you learn how to perform the following tasks:
- Configure a VM instance that doesn't have an external IP address.
- Connect to a VM instance securely using an Identity-Aware Proxy (IAP) tunnel.
- Enable Private Google Access on a subnet to allow internal VMs to reach Google APIs (like Cloud Storage).
- Configure a Cloud NAT gateway and Cloud Router to allow internal VMs to fetch updates from the internet.
- Verify connectivity and configure Cloud NAT logging.

---

## Quick Automated Execution in Google Cloud Shell

Open Cloud Shell and run:

```bash
git clone https://github.com/25dhillongk-cpu/googlecloud.git
cd googlecloud/Implement-Private-Google-Access-Cloud-NAT-CBL188
bash run-lab.sh
```

Once the script completes, return to the lab page and click **Check my progress** on all tasks.
