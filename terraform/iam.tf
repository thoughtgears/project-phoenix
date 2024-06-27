/*
    This file creates a Cloud Scheduler job that triggers a Cloud Function every day at midnight.
    The Cloud Function is responsible for backing up Firestore data.
    The Cloud Scheduler job uses an OIDC token to authenticate the request.
    The Build service account is granted permissions to deploy the Cloud Function.

    You will need to add the Cloud Functions service account to your project as a roles/datastore.importExportAdmin (Cloud Datastore Import Export Admin)
 */
resource "google_service_account" "phoenix_cloud_function" {
  project      = module.projects["source"].id
  account_id   = "cf-phoenix"
  display_name = "[Cloud Function] Phoenix"
  description  = "Service account for the Phoenix Cloud Function"
}

resource "google_project_iam_member" "phoenix_service_agent" {
  project = module.projects["source"].id
  member  = "serviceAccount:${google_service_account.phoenix_cloud_function.email}"
  role    = "roles/cloudfunctions.serviceAgent"
}

resource "google_storage_bucket_iam_member" "phoenix_bucket_owner" {
  bucket = module.storage_buckets["source"].name
  member = "serviceAccount:${google_service_account.phoenix_cloud_function.email}"
  role   = "roles/storage.legacyBucketOwner"
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
resource "google_project_iam_member" "build_object_viewer" {
  project = module.projects["source"].id
  member  = "serviceAccount:${module.projects["source"].number}-compute@developer.gserviceaccount.com"
  role    = "roles/storage.objectViewer"
}

resource "google_project_iam_member" "build_log_writer" {
  project = module.projects["source"].id
  member  = "serviceAccount:${module.projects["source"].number}-compute@developer.gserviceaccount.com"
  role    = "roles/logging.logWriter"
}

resource "google_project_iam_member" "build_cloud_functions_developer" {
  project = module.projects["source"].id
  member  = "serviceAccount:${module.projects["source"].number}-compute@developer.gserviceaccount.com"
  role    = "roles/cloudfunctions.developer"
}

resource "google_project_iam_member" "build_service_account_user" {
  project = module.projects["source"].id
  member  = "serviceAccount:${module.projects["source"].number}-compute@developer.gserviceaccount.com"
  role    = "roles/iam.serviceAccountUser"
}

resource "google_project_iam_member" "build_artifact_registry_writer" {
  project = module.projects["source"].id
  member  = "serviceAccount:${module.projects["source"].number}-compute@developer.gserviceaccount.com"
  role    = "roles/artifactregistry.writer"
}
