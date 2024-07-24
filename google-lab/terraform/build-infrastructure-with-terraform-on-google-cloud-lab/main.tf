terraform {
  backend "gcs" {
    bucket  = "tf-bucket-121012"
    prefix  = "terraform/state"
  }

  required_providers {
    google = {
      source = "hashicorp/google"
      version = "5.38.0"
    }
  }
}

provider "google" {
  project     = var.project_id
  region      = var.region
  zone        = var.zone
}

module "instances" {
  source     = "./modules/instances"
}

module "storage" {
  source     = "./modules/storage"
}

module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "9.1.0"

  project_id = var.project_id
  network_name = var.vpc_network_name
  routing_mode = "GLOBAL"

  subnets = [
    {
        subnet_name   = "subnet-01"
        subnet_ip     = "10.10.10.0/24"
        subnet_region = var.region
    },
    {
        subnet_name   = "subnet-02"
        subnet_ip     = "10.10.20.0/24"
        subnet_region = var.region
    }
  ]
}

resource "google_compute_firewall" "tf-firewall"{
  name    = "tf-firewall"
  network = "projects/qwiklabs-gcp-01-5724d7b7bf03/global/networks/tf-vpc-014773"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_tags = ["web"]
  source_ranges = ["0.0.0.0/0"]
}
