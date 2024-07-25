#!/usr/bin/env bash

set -euo pipefail

export REGION=us-central1
export ZONE=us-central1-c
export PROJECT_ID=$(gcloud config get-value project)
export PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')
export BUCKET_NAME=$PROJECT_ID-bucket
export TOPIC_NAME=topic-memories-588
export FUNCTION_NAME=memories-thumbnail-generator
export SERVICE_ACCOUNT="$(gsutil kms serviceaccount -p $PROJECT_ID)"
# The top export is same as below, but the below is more readable.
# export SERVICE_ACCOUNT="$(gcloud storage service-agent --project=$PROJECT_ID)"
export USER2=student-00-595e5631affe@qwiklabs.net

gcloud config set compute/region $REGION
gcloud config set compute/zone $ZONE

# Enable the required services.
gcloud services enable \
  artifactregistry.googleapis.com \
  cloudfunctions.googleapis.com \
  cloudbuild.googleapis.com \
  eventarc.googleapis.com \
  run.googleapis.com \
  logging.googleapis.com \
  pubsub.googleapis.com

# https://cloud.google.com/eventarc/docs/run/create-trigger-storage-gcloud#before-you-begin
# Grant event receiver role to the Compute Engine default service account.
# So that eventarc trigger can receive events from event providers.
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member=serviceAccount:$PROJECT_NUMBER-compute@developer.gserviceaccount.com \
  --role=roles/eventarc.eventReceiver

# Grant pub/sub publisher role to the cloud storage service account.
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:${SERVICE_ACCOUNT}" \
  --role=roles/pubsub.publisher

# Grant service account token creator role to support authenticated pub/sub push request.
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member=serviceAccount:service-$PROJECT_NUMBER@gcp-sa-pubsub.iam.gserviceaccount.com \
  --role=roles/iam.serviceAccountTokenCreator

# gcloud projects add-iam-policy-binding $PROJECT_ID \
#   --member=serviceAccount:$PROJECT_ID@$PROJECT_ID.iam.gserviceaccount.com \
#   --role=roles/pubsub.publisher

# gcloud projects add-iam-policy-binding $PROJECT_ID \
#   --member=serviceAccount:$PROJECT_ID@appspot.gserviceaccount.com \
#   --role=roles/artifactregistry.reader

# Create a bucket.
gsutil mb -c standard -l $REGION gs://$BUCKET_NAME

# Create a pub/sub topic.
gcloud pubsub topics create $TOPIC_NAME

# Create a Cloud Function directory
mkdir -p gcf
cd gcf

# Create a Cloud Function.
cat << 'EOFE' > index.js
const functions = require('@google-cloud/functions-framework');
const crc32 = require("fast-crc32c");
const { Storage } = require('@google-cloud/storage');
const gcs = new Storage();
const { PubSub } = require('@google-cloud/pubsub');
const imagemagick = require("imagemagick-stream");

functions.cloudEvent('$TOPIC_NAME', cloudEvent => {
  const event = cloudEvent.data;

  console.log(`Event: ${event}`);
  console.log(`Hello ${event.bucket}`);

  const fileName = event.name;
  const bucketName = event.bucket;
  const size = "64x64"
  const bucket = gcs.bucket(bucketName);
  const topicName = "";
  const pubsub = new PubSub();
  if ( fileName.search("64x64_thumbnail") == -1 ){
    // doesn't have a thumbnail, get the filename extension
    var filename_split = fileName.split('.');
    var filename_ext = filename_split[filename_split.length - 1];
    var filename_without_ext = fileName.substring(0, fileName.length - filename_ext.length );
    if (filename_ext.toLowerCase() == 'png' || filename_ext.toLowerCase() == 'jpg'){
      // only support png and jpg at this point
      console.log(`Processing Original: gs://${bucketName}/${fileName}`);
      const gcsObject = bucket.file(fileName);
      let newFilename = filename_without_ext + size + '_thumbnail.' + filename_ext;
      let gcsNewObject = bucket.file(newFilename);
      let srcStream = gcsObject.createReadStream();
      let dstStream = gcsNewObject.createWriteStream();
      let resize = imagemagick().resize(size).quality(90);
      srcStream.pipe(resize).pipe(dstStream);
      return new Promise((resolve, reject) => {
        dstStream
          .on("error", (err) => {
            console.log(`Error: ${err}`);
            reject(err);
          })
          .on("finish", () => {
            console.log(`Success: ${fileName} → ${newFilename}`);
              // set the content-type
              gcsNewObject.setMetadata(
              {
                contentType: 'image/'+ filename_ext.toLowerCase()
              }, function(err, apiResponse) {});
              pubsub
                .topic(topicName)
                .publisher()
                .publish(Buffer.from(newFilename))
                .then(messageId => {
                  console.log(`Message ${messageId} published.`);
                })
                .catch(err => {
                  console.error('ERROR:', err);
                });
          });
      });
    }
    else {
      console.log(`gs://${bucketName}/${fileName} is not an image I can handle`);
    }
  }
  else {
    console.log(`gs://${bucketName}/${fileName} already has a thumbnail`);
  }
});
EOFE

sed -i "8c\functions.cloudEvent('$FUNCTION_NAME', cloudEvent => { " index.js
sed -i "18c\  const topicName = '$TOPIC_NAME';" index.js

# Create a package.json file.
cat << EOF > package.json
{
  "name": "thumbnails",
  "version": "1.0.0",
  "description": "Create Thumbnail of uploaded image",
  "scripts": {
    "start": "node index.js"
  },
  "dependencies": {
    "@google-cloud/functions-framework": "^3.0.0",
    "@google-cloud/pubsub": "^2.0.0",
    "@google-cloud/storage": "^5.0.0",
    "fast-crc32c": "1.0.4",
    "imagemagick-stream": "4.1.1"
  },
  "devDependencies": {},
  "engines": {
    "node": ">=4.3.2"
  }
}
EOF

# Deploy the Cloud Function.
gcloud functions deploy $FUNCTION_NAME \
  --gen2 \
  --runtime=nodejs20 \
  --trigger-resource=$BUCKET_NAME \
  --trigger-event=google.storage.object.finalize \
  --entry-point=$FUNCTION_NAME \
  --region=$REGION \
  --source .

# Download a file that will be uploaded to the bucket.
curl -LO https://storage.googleapis.com/cloud-training/gsp315/map.jpg

# Upload the file to the bucket.
gsutil cp map.jpg gs://$BUCKET_NAME/

# Remove previous user's access to the project.
gcloud projects remove-iam-policy-binding $PROJECT_ID \
  --member=user:$USER2 \
  --role=roles/viewer
