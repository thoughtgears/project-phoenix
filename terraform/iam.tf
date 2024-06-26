resource "google_service_account" "phoenix_cloud_function" {
  project      = module.projects["source"].id
  account_id   = "cf-phoenix"
  display_name = "[Cloud Function] Phoenix"
  description  = "Service account for the Phoenix Cloud Function"
}

resource "google_project_iam_member" "cloud_function_artifact_registry_reader" {
  project = module.projects["source"].id
  member  = "serviceAccount:${google_service_account.phoenix_cloud_function.email}"
  role    = "roles/artifactregistry.reader"
}

resource "google_service_account" "cloud_scheduler_phoenix_backup" {
  project      = module.projects["source"].id
  account_id   = "cs-phoenix-backup"
  display_name = "[Cloud Scheduler] Phoenix Backup"
  description  = "Service account for the Phoenix Backup Cloud Scheduler job"
}

resource "google_project_iam_member" "cloud_scheduler_function_invoker" {
  project = module.projects["source"].id
  member  = "serviceAccount:${google_service_account.phoenix_cloud_function.email}"
  role    = "roles/cloudfunctions.invoker"
}

// Grant access for the build to pull the source for cloud function on deploy
resource "google_project_iam_member" "cloud_function_object_viewer" {
  project = module.projects["source"].id
  member  = "serviceAccount:${module.projects["source"].number}-compute@developer.gserviceaccount.com"
  role    = "roles/storage.objectViewer"
}