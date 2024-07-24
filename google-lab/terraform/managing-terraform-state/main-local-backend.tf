provider "google" {
  project     = "qwiklabs-gcp-01-877afa92c950"
  region      = "us-west1"
}

resource "google_storage_bucket" "test-bucket-for-state" {
  name        = "qwiklabs-gcp-01-877afa92c950"
  location    = "US"
  uniform_bucket_level_access = true
}

terraform {
  backend "local" {
    path = "terraform/state/terraform.tfstate"
  }
}
