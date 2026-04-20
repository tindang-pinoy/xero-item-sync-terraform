variable "default_values" {
  description = "A map of default values for the infrastructure"
  type = object({
    project_name    = string
    project_owner   = string
    project_version = string
    tags            = map(string)
  })
}

variable "iam_role_arn" {
  description = "The ARN of the IAM role for the Lambda function."
  type        = string
}

variable "lambda_name" {
  description = "The name of the Lambda function"
  type        = string
}

variable "lambda_version" {
  description = "The version of the Lambda function"
  type        = string
}

variable "lambda_environments" {
  description = "A map of environment variables for the Lambda function"
  type        = map(string)
  default     = {}
}

variable "subnet_ids" {
  description = "Subnet IDs to attach the Lambda function to (required for VPC access)"
  type        = list(string)
  default     = []
}

variable "security_group_ids" {
  description = "Security group IDs to attach to the Lambda function"
  type        = list(string)
  default     = []
}

variable "image_tag" {
  description = "The Docker image tag for the Lambda function"
  type        = string
}
