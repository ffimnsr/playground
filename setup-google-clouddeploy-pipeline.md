
Export variables:

```bash
export PROJECT_ID=$(gcloud config get-value project)
export REGION=<REGION>
gcloud config set compute/region $REGION
```

Create clusters:

```bash
gcloud container clusters create test --node-locations=$REGION --num-nodes=1  --async
gcloud container clusters create staging --node-locations=$REGION --num-nodes=1  --async
gcloud container clusters create prod --node-locations=$REGION --num-nodes=1  --async
```

Clone demo repo:

```bash
git clone https://github.com/GoogleCloudPlatform/cloud-deploy-tutorials.git
cd cloud-deploy-tutorials
```

Setup pipeline:

```bash
gcloud services enable clouddeploy.googleapis.com

gcloud config set deploy/region $REGION
cp clouddeploy-config/delivery-pipeline.yaml.template clouddeploy-config/delivery-pipeline.yaml
gcloud beta deploy apply --file=clouddeploy-config/delivery-pipeline.yaml
```

Verify delivery pipeline:

```bash
gcloud beta deploy delivery-pipelines describe web-app
```

Create first release for test:

```bash
gcloud beta deploy releases create web-app-001 \
--delivery-pipeline web-app \
--build-artifacts web/artifacts.json \
--source web/
```

Confirm test target application deployed:

```bash
gcloud beta deploy rollouts list \
--delivery-pipeline web-app \
--release web-app-001
```

Promote the application to staging:

```bash
gcloud beta deploy releases promote \
--delivery-pipeline web-app \
--release web-app-001
```

Promote the application to prod:

```bash
gcloud beta deploy releases promote \
--delivery-pipeline web-app \
--release web-app-001
```

Approve the rollout to prod:

```bash
gcloud beta deploy rollouts approve web-app-001-to-prod-0001 \
--delivery-pipeline web-app \
--release web-app-001
```
