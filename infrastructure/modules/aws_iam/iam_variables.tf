variable "default_values" {
  description = "Common project values and tags"
  type = object({
    project_name    = string
    project_owner   = string
    project_version = string
    tags            = map(string)
  })
}

variable "iam_role_name" {
  description = "Base name for the IAM roles"
  type        = string
}

variable "lambda_name" {
  description = "Name of the fetcher Lambda function"
  type        = string
}

variable "aws_region" {
  description = "AWS region — used to construct rds-db:connect policy ARNs"
  type        = string
}

variable "db_writer_lambda_name" {
  description = "Name of the DB writer Lambda function — grants the fetcher role permission to invoke it"
  type        = string
}

variable "rds_iam_db_username" {
  description = "PostgreSQL username that maps to the IAM role for rds-db:connect"
  type        = string
  default     = "lambda_db_user"
}

variable "rds_resource_id" {
  description = "RDS instance resource ID (e.g. db-ABCDEFGH) — used to scope the rds-db:connect policy"
  type        = string
}

variable "secret_arns" {
  description = "Secrets Manager ARNs the fetcher Lambda is permitted to read (e.g. Xero credentials)"
  type        = list(string)
  default     = []
}
