resource "google_compute_instance" "terraform" {
  project      = "qwiklabs-gcp-03-c8a2d4e623e1"
  name         = "terraform"
  machine_type = "e2-medium"
  zone         = "us-central1-c"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = "default"
    access_config {
    }
  }
}
