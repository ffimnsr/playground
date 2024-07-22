
This cheatsheet only contains minimal but my most used commands in the Google Cloud Platform.

Environment variables that I usually use:

```
export PROJECT_ID=$(gcloud config get-value project)
export ZONE=$(gcloud config get-value compute/zone)
```

Set region:

```
gcloud config set compute/region europe-west1
```

Get region:

```
gcloud config get-value compute/region
```

Set compute zone:

```
gcloud config set compute/zone europe-west1-d
```

Get compute zone:

```
gcloud config get-value compute/zone
```

Get project ID:

```
gcloud config get-value project
```

View details of the project:

```
gcloud compute project-info describe --project $(gcloud config get-value project)
```

Create a VM:

```
gcloud compute instances create <VM_NAME> --machine-type e2-medium --zone $ZONE
```

List VMs:

```
gcloud compute instances list
```

List firewall rules in the project:

```
gcloud compute firewall-rules list
```

Viewing system logs:

```
gcloud logging logs list
```
