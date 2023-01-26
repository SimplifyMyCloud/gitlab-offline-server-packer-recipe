# Foundation Layer - GCP Ops - Gitlab Offline Server Desired State - GCE Mangaged Instance Group
# Infrastructure base name = gitlab-tf-org-ops-{asset}
resource "google_compute_instance_template" "gce-template" {
  name                 = "gitlab-tf-org-ops-template"
  description          = "Gitlab offline GCE Image Template calling the Packer baked image"
  instance_description = "Gitlab offline GCE Image Template calling the Packer baked image"
  region               = "us-west1-c"

  labels = {
    environment = "org-ops"
    role        = "Terraform Server"
  }

  disk {
    source_image = "{project}/{image}"
  }

  network_interface {
    subnetwork = "subnet-name"
  }

  service_account {
    email  = "tf-sa@domain"
    scopes = [""]
  }
}