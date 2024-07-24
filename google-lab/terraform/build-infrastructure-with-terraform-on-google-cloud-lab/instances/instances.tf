
# Created using terraform import
#
#   terraform import module.instances.google_compute_instance.tf-instance-1 $IN1
#   terraform show -no-color > modules/instances/instances.tf

# module.instances.google_compute_instance.tf-instance-1:
resource "google_compute_instance" "tf-instance-1" {
    name         = "tf-instance-1"
    machine_type = "e2-standard-2"
    zone         = "us-east4-c"
    boot_disk {
        initialize_params {
            image = "https://www.googleapis.com/compute/v1/projects/debian-cloud/global/images/debian-11-bullseye-v20240709"
        }
    }

    network_interface {
        network    = "tf-vpc-014773"
        subnetwork = "subnet-01"
    }
    metadata_startup_script = <<-EOT
            #!/bin/bash
        EOT
    allow_stopping_for_update = true
}

# module.instances.google_compute_instance.tf-instance-2:
resource "google_compute_instance" "tf-instance-2" {
    name         = "tf-instance-2"
    machine_type = "e2-standard-2"
    zone         = "us-east4-c"
    boot_disk {
        initialize_params {
            image = "https://www.googleapis.com/compute/v1/projects/debian-cloud/global/images/debian-11-bullseye-v20240709"
        }
    }

    network_interface {
        network    = "tf-vpc-014773"
        subnetwork = "subnet-02"
    }
    metadata_startup_script = <<-EOT
            #!/bin/bash
        EOT
    allow_stopping_for_update = true
}
