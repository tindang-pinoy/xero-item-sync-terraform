locals {
  default_values = {
    project_name    = var.project_name
    project_owner   = var.project_owner
    project_version = var.project_version

    tags = {
      projectId     = var.project_name
      applicationId = var.project_name
      owner         = var.project_owner
    }
  }
  application_name  = var.project_name
  handler_image_tag = "${local.application_name}-${var.lambda_version}"

  handler_environments = {

  }
}