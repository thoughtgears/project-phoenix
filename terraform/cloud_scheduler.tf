/*
  We get the data project to ensure we can have the right permissions to access the Firestore database.
  Since we will need the number and the project_id, we will use the data source to get the information.
 */
data "google_project" "data_project" {
  project_id = var.data_project
}

/*
  This will create the Cloud scheduler job that will run the backup function every day at midnight.
  It will use the OIDC token to authenticate the request.
  The body can contain data = {"database": "my-db", "collections": ["users", "posts"]}, defaults to [] and (database) if not provided.
 */
resource "google_cloud_scheduler_job" "phoenix_backup_scheduler" {
  project   = module.projects["source"].id
  name      = "phoenix-backup-scheduler"
  region    = var.region
  schedule  = "0 0 * * *" # Run every day at midnight
  time_zone = "Etc/UTC"

  retry_config {
    retry_count        = 1
    max_retry_duration = "60s"
  }

  http_target {
    uri         = "https://${var.region}-${module.projects["source"].id}.cloudfunctions.net/phoenix-backup"
    http_method = "POST"
    headers = {
      "Content-Type" = "application/json",
      "User-Agent"   = "Google-Cloud-Scheduler"
    }
    body = base64encode(jsonencode({
      type           = "firestore"
      project_id     = data.google_project.data_project.project_id,
      project_number = data.google_project.data_project.number
    }))

    oidc_token {
      service_account_email = google_service_account.cloud_scheduler_phoenix_backup.email
      audience              = "https://${var.region}-${module.projects["source"].id}.cloudfunctions.net/phoenix-backup"
    }
  }
}