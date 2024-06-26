variable "project_id" {
  type        = string
  description = "The project id of the project to create the bucket in."
}

variable "location" {
  type        = string
  description = "The location of the bucket."
  default     = "EU"
}

variable "bucket_name" {
  type        = string
  description = "The name of the bucket."
}

variable "storage_class" {
  type        = string
  description = "The storage class of the bucket."
  default     = "STANDARD"
}

variable "target" {
  type        = bool
  description = "Whether to create a target bucket."
  default     = false
}