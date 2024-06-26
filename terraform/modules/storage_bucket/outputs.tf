output "id" {
  value       = google_storage_bucket.this.id
  description = "The id of the created bucket."
}

output "uri" {
  value       = google_storage_bucket.this.url
  description = "The URI of the created bucket."
}

output "self_link" {
  value       = google_storage_bucket.this.self_link
  description = "The self_link of the created bucket."
}

output "name" {
  value       = google_storage_bucket.this.name
  description = "The name of the created bucket."
}
