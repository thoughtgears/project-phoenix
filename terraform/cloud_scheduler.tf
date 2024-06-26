resource "google_cloud_scheduler_job" "phoenix_backup_scheduler" {
  project   = module.projects["source"].id
  name      = "phoenix-backup-scheduler"
  region    = var.region
  schedule  = "0 0 * * *" # Run every day at midnight
  time_zone = "Etc/UTC"

  http_target {
    uri         = "https://${var.region}-${module.projects["source"].id}.cloudfunctions.net/phoenix-backup"
    http_method = "POST"
    body = base64encode(jsonencode({
      type       = "firestore"
      project_id = var.data_project,
      data = {
        collections = []
      }
    }))

    oidc_token {
      service_account_email = google_service_account.cloud_scheduler_phoenix_backup.email
      audience              = "https://${var.region}-${module.projects["source"].id}.cloudfunctions.net/phoenix-backup"
    }
  }
}