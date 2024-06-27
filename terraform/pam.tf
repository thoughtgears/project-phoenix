/*
  This still does not create the PAM, you will need to initialize the PAM manually or
  setting the required permissions to the service agent.
 */
resource "google_privileged_access_manager_entitlement" "dr_restoration" {
  provider             = google-beta
  entitlement_id       = "dr-restoration"
  location             = "global"
  max_request_duration = "43200s"
  parent               = "projects/${module.projects["target"].id}"
  requester_justification_config {
    unstructured {}
  }
  eligible_users {
    principals = ["group:${var.backup_admin_group}"]
  }
  privileged_access {
    gcp_iam_access {
      role_bindings {
        role = "roles/storage.objectUser"
      }
      resource      = "//cloudresourcemanager.googleapis.com/projects/${module.projects["target"].id}"
      resource_type = "cloudresourcemanager.googleapis.com/Project"
    }
  }
  additional_notification_targets {
    admin_email_recipients = concat([var.backup_approve_group], var.backup_approve_users)
  }
  approval_workflow {
    manual_approvals {
      require_approver_justification = true
      steps {
        approvals_needed          = 1
        approver_email_recipients = var.backup_approve_users
        approvers {
          principals = ["group:${var.backup_approve_group}", "user:${var.backup_approve_users[0]}"]
        }
      }
    }
  }
}