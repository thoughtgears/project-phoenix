variable "project_name" {
  type        = string
  description = "The name of the project ID to create."

  validation {
    condition     = length(var.project_name) <= 20
    error_message = "The project_name must be up to 20 characters long."
  }

  validation {
    condition     = can(regex("^[a-zA-Z0-9'\\-\\s!]{4,24}$", var.project_name))
    error_message = "The project_name must start with a lowercase letter, and end with a lowercase letter or number."
  }
}

variable "billing_account" {
  type        = string
  description = "The billing account ID."

  validation {
    condition     = can(regex("^[a-zA-Z0-9]{6}-[a-zA-Z0-9]{6}-[a-zA-Z0-9]{6}$", var.billing_account))
    error_message = "The custom_id must be in the format 'XXXXXX-XXXXXX-XXXXXX' where each X is a letter or a digit."
  }
}

variable "folder_id" {
  type        = string
  description = "The parent folder name with the format of folders/{number}."

  validation {
    condition     = can(regex("^[0-9]+$", var.folder_id))
    error_message = "The folder_id must be the numeric id of the parent folder."
  }
}

variable "service_apis" {
  type        = list(string)
  description = "A list of google service APIs to active for the project."
  default     = []
}
