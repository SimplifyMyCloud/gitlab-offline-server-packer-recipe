# Foundation Layer - GCP Ops - Gitlab Offline Server Desired State - GCE Mangaged Instance Group
# Infrastructure base name = gitlab-tf-org-ops-{asset}
resource "google_compute_instance_group_manager" "gitlab-mig" {
  name = "gitlab-tf-org-ops"
  description = "Gitlab offline instance to host GCP Org Ops Terraform code"
  project = ""
  zone = "us-west1-c"
  network = 
  base_instance_name = "gitlab-tf-org-ops-tf-server"

  version {
    name              = "gitlab-tf-org-ops-template"
    instance_template = google_compute_instance_template.gitlab-tf-org-ops-template.id

    target_size {
      fixed = 1
    }
  }
}
