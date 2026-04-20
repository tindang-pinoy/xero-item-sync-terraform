variable "default_values" {
  description = "A map of default values for the infrastructure"
  type = object({
    project_name    = string
    project_owner   = string
    project_version = string
    tags            = map(string)
  })
}

variable "queue_name" {
  description = "The name of the SQS FIFO queue (without the .fifo suffix)"
  type        = string
}

variable "lambda_function_arn" {
  description = "The ARN of the Lambda function to trigger from the SQS queue"
  type        = string
}
