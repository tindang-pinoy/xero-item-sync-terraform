variable "default_values" {
  description = "Common project values and tags"
  type = object({
    project_name    = string
    project_owner   = string
    project_version = string
    tags            = map(string)
  })
}

variable "iam_role_arn" {
  description = "ARN of the IAM role for the Lambda function"
  type        = string
}

variable "lambda_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "lambda_version" {
  description = "Version of the Lambda function — used to tag the Docker image"
  type        = string
}

variable "lambda_environments" {
  description = "Environment variables to pass to the Lambda function"
  type        = map(string)
  default     = {}
}

variable "lambda_description" {
  description = "Description of the Lambda function"
  type        = string
  default     = ""
}

variable "subnet_ids" {
  description = "Subnet IDs to attach the Lambda to (required for VPC access)"
  type        = list(string)
  default     = []
}

variable "security_group_ids" {
  description = "Security group IDs to attach to the Lambda function"
  type        = list(string)
  default     = []
}

variable "image_tag" {
  description = "Docker image tag — required when building a new image"
  type        = string
  default     = null
}

variable "create_image" {
  description = "When true, builds a Docker image and pushes it to ECR. Set to false for secondary Lambdas that reuse an existing image via image_uri."
  type        = bool
  default     = true
}

variable "image_uri" {
  description = "Pre-built container image URI. Required when create_image is false."
  type        = string
  default     = null
}

variable "handler_command" {
  description = "Override the container CMD to select a different handler (e.g. ['lambda_db_writer.lambda_handler']). When null the image default is used."
  type        = list(string)
  default     = null
}
