variable "default_values" {
  description = "A map of default values for the infrastructure"
  type        = object({
    project_name = string
    project_owner = string
    project_version = string
    sf_environment = string
    tags = map(string)
  })
}

variable "iam_role_arn" {
  description = "The ARN of the IAM role for the Lambda function."
  type        = string
}

variable "lambda_version"{
    description = "The version of the Lambda function"
    type        = string
}

variable "lambda_name"{
  description = "The name of the API Handler Lambda Function"
  type        = string
}

variable "lambda_environments" {
  description = "A map of environment variables for the Lambda function"
  type        = map(string)
  default     = {}
}

variable "image_tag" {
  description = "The Docker image tag for the Lambda function"
  type        = string
}