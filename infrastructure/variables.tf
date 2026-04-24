variable "aws_account_id" {
  description = "The AWS Account ID where resources will be created"
  type        = string
}

variable "aws_region" {
  description = "The AWS Region where resources will be created"
  type        = string
}

variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "project_owner" {
  description = "The owner of the project"
  type        = string
}

variable "project_version" {
  description = "The version of the project"
  type        = string
}

# ── Dependencies ──────────────────────────────────────────────────────────────

variable "core_infrastructure_project_name" {
  description = "project_name of the core-infrastructure deployment — used to resolve SSM paths"
  type        = string
  default     = "tdp-core-infrastructure"
}

variable "database_project_name" {
  description = "project_name of the database deployment — used to resolve SSM paths"
  type        = string
  default     = "tdp-database"
}

# ── Lambda ────────────────────────────────────────────────────────────────────

variable "lambda_version" {
  description = "Version of the Lambda functions — used to tag the Docker image"
  type        = string
}

variable "lambda_name_fetcher" {
  description = "Name of the fetcher Lambda function (Lambda 1)"
  type        = string
}

variable "lambda_fetcher_description" {
  description = "Description of the fetcher Lambda function (Lambda 1)"
  type        = string
}

variable "lambda_name_uploader" {
  description = "Name of the uploader Lambda function (Lambda 2)"
  type        = string
}

variable "lambda_uploader_description" {
  description = "Description of the uploader Lambda function (Lambda 2)"
  type        = string
}

variable "rds_iam_db_username" {
  description = "PostgreSQL username mapped to IAM for rds-db:connect auth"
  type        = string
  default     = "lambda_db_user"
}

# ── Secrets Manager ───────────────────────────────────────────────────────────

variable "xero_secret_name" {
  description = "AWS Secrets Manager secret name holding the Xero API credentials"
  type        = string
  default     = "xero"
}

variable "secret_arns" {
  description = "Secrets Manager ARNs the fetcher Lambda is permitted to read"
  type        = list(string)
  default     = []
}
