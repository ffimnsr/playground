---
title: Install Google Cloud Monitoring Agents
created: 2024-07-24
updated: 2024-07-24
---

Download the installation script from the following URL. Then install the monitoring agent.

```
curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.
sudo bash add-google-cloud-ops-agent-repo.sh --also-install
```

Run the following command to start the monitoring agent:

```
sudo systemctl status google-cloud-ops-agent"*"
```
