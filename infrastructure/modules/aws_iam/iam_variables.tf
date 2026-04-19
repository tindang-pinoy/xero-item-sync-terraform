variable "default_values" {
    description = "A map of tags to apply to resources"
    type = object({
      project_name = string
      project_owner = string
      project_version = string
      tags = map(string)
    })
}

variable "iam_role_name" {
    description = "The name of the IAM role to create"
    type = string
}

variable "lambda_name" {
    description = "The name of the Lambda function to create"
    type = string
}