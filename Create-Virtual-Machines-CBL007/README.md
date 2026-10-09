# Lab: Create Virtual Machines (CBL007)

**Course**: Essential Google Cloud Infrastructure: Foundation  
**Path**: Google Cloud Engineering Certificate  

---

## Overview

In this lab, you explore the Compute Engine virtual machine instance options and create several VMs with different characteristics:
1. **Utility VM**: A standard Linux `e2-medium` VM with no external IP.
2. **Windows VM**: An `e2-standard-2` running Windows Server 2025 Core on a 64GB SSD, allowing HTTP/HTTPS traffic.
3. **Custom VM**: A Linux VM with custom resource allocations (2 vCPUs, 4GB RAM).

---

## Quick Automated Execution in Google Cloud Shell

Open Cloud Shell and run:

```bash
git clone https://github.com/25dhillongk-cpu/googlecloud.git
cd googlecloud/Create-Virtual-Machines-CBL007
bash run-lab.sh
```

Once the script completes, return to the lab page and click **Check my progress** on all tasks.
