#!/usr/bin/env bash

set -euo pipefail

export REGION=us-east1
export PROJECT_ID=$(gcloud config get-value project)
export PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')
export BUCKET_NAME=$PROJECT_ID-marking

export DATASET_NAME=lab_836
export TABLE_NAME=customers_851

gcloud config set compute/region $REGION

# Add the required roles to the compute service account.
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member=serviceAccount:$PROJECT_NUMBER-compute@developer.gserviceaccount.com \
  --role=roles/storage.admin

# Create a bucket.
gsutil mb -c standard gs://$BUCKET_NAME

# Copy required files to local.
gsutil cp gs://cloud-training/gsp323/lab.csv  .
gsutil cp gs://cloud-training/gsp323/lab.schema .

# Create a BigQuery dataset.
bq mk $DATASET_NAME

# Create a BigQuery table.
bq mk --table $DATASET_NAME.$TABLE_NAME lab.schema

# Create a Dataflow job.
gcloud dataflow jobs run simple-df-job \
  --gcs-location=gs://dataflow-templates-$REGION/latest/GCS_Text_to_BigQuery \
  --region=$REGION \
  --worker-machine-type=e2-standard-2 \
  --staging-location=gs://$BUCKET_NAME/temp \
  --parameters=inputFilePattern=gs://cloud-training/gsp323/lab.csv,JSONPath=gs://cloud-training/gsp323/lab.schema,outputTable=$PROJECT_ID:$DATASET_NAME.$TABLE_NAME,bigQueryLoadingTemporaryDirectory=gs://$BUCKET_NAME/bigquery_temp,javascriptTextTransformGcsPath=gs://cloud-training/gsp323/lab.js,javascriptTextTransformFunctionName=transform

# Export Dataproc cluster name.
export DATAPROC_CLUSTER_NAME=cluster-7778

# Copy argument file to one of the cluster node.
# This should be run inside the one of the dataproc cluster node..
gcloud compute ssh $DATAPROC_CLUSTER_NAME-m \
  --region $REGION
hdfs dfs -cp gs://cloud-training/gsp323/data.txt /data.
hdfs dfs -ls /

# Create a Dataproc job.
gcloud dataproc jobs submit spark \
  --region=$REGION \
  --cluster=$DATAPROC_CLUSTER_NAME \
  --max-failures-per-hour=1 \
  --class=org.apache.spark.examples.SparkPageRank \
  --jars=file:///usr/lib/spark/examples/jars/spark-examples.jar -- /data.txt

# Create a Cloud Speech-to-Text request.
cat << EOF > request.json
{
  "config": {
    "encoding":"FLAC",
    "languageCode": "en-US"
  },
  "audio": {
    "uri":"gs://cloud-training/gsp323/task3.flac"
  }
}
EOF

# Analyze using the Cloud Speech-to-Text API.
curl -s -X POST -H "Content-Type: application/json" \
  --data-binary @request.json \
  "https://speech.googleapis.com/v1/speech:recognize?key=${API_KEY}" > result.json

gsutil cp result.json gs://$BUCKET_NAME/task3-gcs-504.result

# # Create a Cloud Video Intelligence API request.
# cat << EOF > request.json
# {
#   "inputUri":"gs://spls/gsp154/video/train.mp4",
#   "features": [
#     "TEXT_DETECTION"
#   ]
# }
# EOF

# # Analyze using the Cloud Video Intelligence API.
# curl -s -H "Content-Type: application/json" \
#   -H "Authorization: Bearer '$(gcloud auth print-access-token)'" \
#   --data-binary @request.json \
#   "https://videointelligence.googleapis.com/v1/videos:annotate"

# CVI_BUCKET_NAME=
# gsutil cp request.json gs://$CVI_BUCKET_NAME/

# Analyze using the Cloud Natural Language API.
CNL_CONTENT="Old Norse texts portray Odin as one-eyed and long-bearded, frequently wielding a spear named Gungnir and wearing a cloak and a broad hat."
gcloud ml language analyze-entities \
  --content="$CNL_CONTENT" > result.json

gsutil cp result.json gs://$BUCKET_NAME/task4-cnl-560.result
