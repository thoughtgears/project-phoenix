output "project_info" {
  value = {
    for key, project in module.projects :
    key => {
      id     = project.id
      number = project.number
    }
  }
  description = "A map of project names to their respective IDs and numbers"
}

output "phoenix_backup_bucket" {
  value       = module.storage_buckets["source"].name
  description = "The name of the bucket to store backups in before they are moved to the final destination"
}

output "phoenix_cloud_function_service_account_email" {
  value       = google_service_account.phoenix_cloud_function.email
  description = "The email address of the service account used by the Phoenix Cloud Function"
}