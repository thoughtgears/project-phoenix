variable "source_project_id" {
  type        = string
  description = "The project ID where the backup sources are located"
}

variable "target_project_id" {
  type        = string
  description = "The project ID where the backup target are located"
}

variable "folder_id" {
  type        = string
  description = "The folder ID where the projects are located"
}

variable "billing_account_id" {
  type        = string
  description = "The billing account ID to associate with the projects"
}

variable "region" {
  type        = string
  description = "The region to create the resources in"
  default     = "europe-west1"
}

variable "data_project" {
  type        = string
  description = "The project ID where the data is located"
  default     = ""
}

variable "backup_admin_group" {
  type        = string
  description = "The group to grant permissions for DR restore"
}

variable "backup_approve_group" {
  type        = string
  description = "The group to grant permissions for DR restore"
}

variable "backup_approve_users" {
  type = list(string)
}