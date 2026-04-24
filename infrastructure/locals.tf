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

  lambda_fetcher_environments = {
      XERO_SECRET_NAME        = var.xero_secret_name
      DB_WRITER_FUNCTION_NAME = var.lambda_name_uploader
  }

  lambda_uploader_environments = {
    DB_HOST = data.aws_ssm_parameter.db_endpoint.value
    DB_PORT = "5432"
    DB_NAME = data.aws_ssm_parameter.db_name.value
    DB_USER = var.rds_iam_db_username
  }
}