/*
  This will setup the correct permissions for the storage service to read and write data.
  The permissions are set on the source and target buckets, the target project.
  The service account is given the necessary permissions to read from the source bucket and write to the target bucket.
 */
resource "google_storage_bucket_iam_member" "target_bucket" {
  bucket = module.storage_buckets["target"].name
  member = "serviceAccount:project-${module.projects["target"].number}@storage-transfer-service.iam.gserviceaccount.com"
  role   = "roles/storage.admin"
}

resource "google_project_iam_member" "target_service_agent" {
  project = module.projects["target"].id
  member  = "serviceAccount:project-${module.projects["target"].number}@storage-transfer-service.iam.gserviceaccount.com"
  role    = "roles/storagetransfer.serviceAgent"
}

resource "google_project_iam_member" "source_bucket_object_viewer" {
  project = module.projects["source"].id
  member  = "serviceAccount:project-${module.projects["target"].number}@storage-transfer-service.iam.gserviceaccount.com"
  role    = "roles/storage.objectViewer"
}

resource "google_storage_bucket_iam_member" "source_bucket_legacy_bucket_reader" {
  bucket = module.storage_buckets["source"].name
  member = "serviceAccount:project-${module.projects["target"].number}@storage-transfer-service.iam.gserviceaccount.com"
  role   = "roles/storage.legacyBucketReader"
}

/*
  This will setup the Pub/Sub service topic and subscription for storage events.
  The storage transfer job will be triggered by the subscription.
  The storage service agent will be get the permissions to subscribe to the topic.
 */
resource "google_project_iam_member" "target_pubsub_subscriber" {
  project = module.projects["target"].id
  member  = "serviceAccount:project-${module.projects["target"].number}@storage-transfer-service.iam.gserviceaccount.com"
  role    = "roles/pubsub.subscriber"
}

resource "google_pubsub_topic" "transfer" {
  project = module.projects["target"].id
  name    = "transfer-topic"
}

resource "google_pubsub_subscription" "transfer" {
  project              = module.projects["target"].id
  name                 = "transfer-subscription"
  topic                = google_pubsub_topic.transfer.id
  ack_deadline_seconds = 300
}

/*
  This will setup the storage transfer job.
  The job will transfer the backups from the source bucket to the target bucket.
  The job will be triggered by the Pub/Sub subscription.
 */
resource "google_storage_transfer_job" "dr_backup" {
  project     = module.projects["target"].id
  description = "Transfers backups from Phoenix project for disaster recovery"
  name        = "transferJobs/dr-backup-job"

  event_stream {
    name = google_pubsub_subscription.transfer.id
  }

  transfer_spec {
    gcs_data_source {
      bucket_name = module.storage_buckets["source"].name
    }

    gcs_data_sink {
      bucket_name = module.storage_buckets["target"].name
    }
  }
}

/*
  This will setup the storage notification for the source bucket.
  The notification will be sent to the Pub/Sub topic.
  The notification will be triggered by the OBJECT_FINALIZE and OBJECT_METADATA_UPDATE events.
 */
resource "google_storage_notification" "target" {
  bucket         = module.storage_buckets["source"].name
  payload_format = "JSON_API_V1"
  topic          = google_pubsub_topic.transfer.id
  event_types    = ["OBJECT_FINALIZE"]
  depends_on     = [google_pubsub_topic_iam_binding.binding]
}

// Enable notifications by giving the correct IAM permission to the unique service account.
data "google_storage_project_service_account" "gcs_account" {
  project = module.projects["source"].id
}

resource "google_pubsub_topic_iam_binding" "binding" {
  topic   = google_pubsub_topic.transfer.id
  role    = "roles/pubsub.publisher"
  members = ["serviceAccount:${data.google_storage_project_service_account.gcs_account.email_address}"]
}
