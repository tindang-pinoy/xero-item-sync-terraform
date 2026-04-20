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

variable "lambda_version" {
  description = "The version of the Lambda function"
  type        = string
}

variable "lambda_name" {
  description = "The name of the API Handler Lambda Function"
  type        = string
}

variable "lambda_environments" {
  description = "Environment variables to pass to the Lambda function"
  type        = map(string)
  default     = {}
}