
This cheatsheet only contains minimal but my most used commands in the Google Cloud Platform.

Environment variables that I usually use:

```
export PROJECT_ID=$(gcloud config get-value project)
export ZONE=$(gcloud config get-value compute/zone)
export REGION="${ZONE%-*}"
```

Alternative:

```
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
