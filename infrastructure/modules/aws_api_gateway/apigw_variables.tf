variable "default_values" {
  description = "Common project values and tags"
  type = object({
    project_name    = string
    project_owner   = string
    project_version = string
    tags            = map(string)
  })
}

variable "api_name" {
  description = "Name of the HTTP API Gateway"
  type        = string
}

variable "api_description" {
  description = "Description of the HTTP API Gateway"
  type        = string
  default     = ""
}

variable "lambda_function_arn" {
  description = "ARN of the Lambda function to integrate with"
  type        = string
}

variable "cors_allow_origins" {
  description = "List of allowed CORS origins"
  type        = list(string)
  default     = ["*"]
}
