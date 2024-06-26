locals {
  tmp_project_id = "${var.project_name}-${random_integer.this.result}"

  tmp_service_apis = concat([
    "storage.googleapis.com",
    "run.googleapis.com",
    "eventarc.googleapis.com",
    "pubsub.googleapis.com",
    "storagetransfer.googleapis.com",
    "cloudscheduler.googleapis.com"
  ], var.service_apis)
}

resource "random_integer" "this" {
  max = 99999
  min = 10000
}

resource "google_project" "this" {
  name            = local.tmp_project_id
  project_id      = local.tmp_project_id
  folder_id       = var.folder_id
  billing_account = var.billing_account
}

resource "google_project_service" "this" {
  for_each = toset(local.tmp_service_apis)
  project  = google_project.this.project_id
  service  = each.value
}
