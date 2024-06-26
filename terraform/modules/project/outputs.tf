output "id" {
  value       = google_project.this.project_id
  description = "The project id of the created project."
}

output "number" {
  value       = google_project.this.number
  description = "The project number of the created project."
}
