
This cheatsheet only contains minimal but my most used commands in the Google Cloud Platform.

Environment variables that I usually use:

```
export PROJECT_ID=$(gcloud config get-value project)
export ZONE=$(gcloud config get-value compute/zone)
export REGION="${ZONE%-*}"
export PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')

...

export PROJECT_ID=$DEVSHELL_PROJECT_ID
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

Connect to VM using SSH:

```
gcloud compute ssh <VM_NAME> --zone $ZONE
```

Connect to VM using SSH on their internal IP:

```
gcloud compute ssh <VM_NAME> --zone $ZONE --internal-ip
```

Create GKE cluster:

```
gcloud container clusters create <CLUSTER_NAME> --zone $ZONE
```

Get credentials for the cluster:

```
gcloud container clusters get-credentials <CLUSTER_NAME> --zone $ZONE
```

Delete GKE cluster:

```
gcloud container clusters delete <CLUSTER_NAME> --zone $ZONE
```

Create a bucket:

```
gsutil mb gs://<BUCKET_NAME>
```

List bucket contents:

```
gsutil ls gs://<BUCKET_NAME>
```

Make object publicly accessible:

```
gsutil acl ch -u AllUsers:R gs://<BUCKET_NAME>/<OBJECT_NAME>
```

Remove public access:

```
gsutil acl ch -d AllUsers gs://<BUCKET_NAME>/<OBJECT_NAME>
```

Delete object in a bucket:

```
gsutil rm gs://<BUCKET_NAME>/<OBJECT_NAME>
```

Connect to Cloud SQL instance:

```
gcloud sql connect <INSTANCE_NAME> --user=root
```

Create dataproc cluster:

```
gcloud dataproc clusters create <CLUSTER_NAME> \
  --region $REGION \
  --worker-boot-disk-size 500 \
  --worker-machine-type=e2-standard-4 \
  --master-machine-type=e2-standard-4
```

Create dataproc job:

```
gcloud dataproc jobs submit pyspark --cluster <CLUSTER_NAME> \
  --region $REGION \
  --py-files gs://<BUCKET_NAME>/<FILE>.py gs://<BUCKET_NAME>/<FILE>.py

...

gcloud dataproc jobs submit spark --cluster <CLUSTER_NAME> \
  --region $REGION \
  --class org.apache.spark.examples.SparkPi \
  --jars file:///<FILE>.jar -- 1000
```

Enable services in the project:

```
gcloud services enable <SERVICE_NAME>
```

Services needed to Vertex AI with Jupyter Notebooks:

```
gcloud services enable \
  compute.googleapis.com \
  iam.googleapis.com \
  iamcredentials.googleapis.com \
  monitoring.googleapis.com \
  logging.googleapis.com \
  notebooks.googleapis.com \
  aiplatform.googleapis.com \
  bigquery.googleapis.com \
  artifactregistry.googleapis.com \
  cloudbuild.googleapis.com \
  container.googleapis.com
```

Create a specific VM in gcloud for labs:

```
gcloud compute instances create www1 \
    --zone=$ZONE \
    --tags=network-lb-tag \
    --machine-type=e2-small \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
      apt-get update
      apt-get install apache2 -y
      service apache2 restart
      echo "
<h3>Web Server: www1</h3>" | tee /var/www/html/index.html'

gcloud compute firewall-rules create www-firewall-network-lb \
    --target-tags network-lb-tag --allow tcp:80
```

Create new persistent disk:

```
gcloud compute disks create <DISK_NAME> --size=<SIZE_IN_GB_EG_200GB> --zone=$ZONE
```

Attach disk to VM:

```
gcloud compute instances attach-disk <VM_NAME> --disk=<DISK_NAME> --zone=$ZONE
```

Sample creating clusters for different stages:

```
gcloud container clusters create test --node-locations=us-east4-b --num-nodes=1  --async
gcloud container clusters create staging --node-locations=us-east4-b --num-nodes=1  --async
gcloud container clusters create prod --node-locations=us-east4-b --num-nodes=1  --async
```
