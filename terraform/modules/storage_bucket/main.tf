resource "google_storage_bucket" "this" {
  project       = var.project_id
  location      = var.location
  name          = var.bucket_name
  storage_class = var.storage_class

  versioning {
    enabled = false
  }

  dynamic "lifecycle_rule" {
    for_each = var.target ? [] : [1]
    content {
      condition {
        age = 2
      }
      action {
        type = "Delete"
      }
    }
  }

  dynamic "retention_policy" {
    for_each = var.target ? [1] : []
    content {
      is_locked        = true
      retention_period = 31536000
    }
  }

  dynamic "lifecycle_rule" {
    for_each = var.target ? [1] : []
    content {
      condition {
        age = 366
      }
      action {
        type = "Delete"
      }
    }
  }
}
