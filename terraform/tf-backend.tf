# Foundation Layer - GCP Ops - Gitlab Offline Server Desired State - Terraform Backend
terraform {
  backend "gcs" {
    bucket = "iq9-terraform-shared-state-bucket"
    prefix = "foundation/gce/org-ops/gitlab-offline"
  }
}