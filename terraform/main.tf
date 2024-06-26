locals {
  tmp_projects = {
    "source" = {
      name          = var.source_project_id
      folder_id     = var.folder_id
      bucket_suffix = "backups"
      service_apis = [
        "cloudscheduler.googleapis.com",
        "cloudbuild.googleapis.com",
        "cloudfunctions.googleapis.com",
      ]
    }
    "target" = {
      name          = var.target_project_id
      folder_id     = var.folder_id
      bucket_suffix = "dr-backups"
      target        = true
      storage_class = "NEARLINE"
    }
  }
}

module "projects" {
  for_each = local.tmp_projects

  source          = "./modules/project"
  folder_id       = each.value.folder_id
  project_name    = each.value.name
  billing_account = var.billing_account_id
  service_apis    = lookup(each.value, "service_apis", [])
}

module "storage_buckets" {
  for_each = local.tmp_projects

  source        = "./modules/storage_bucket"
  project_id    = module.projects[each.key].id
  bucket_name   = "${module.projects[each.key].id}-${each.value.bucket_suffix}"
  target        = lookup(each.value, "target", false)
  storage_class = lookup(each.value, "storage_class", "STANDARD")
}