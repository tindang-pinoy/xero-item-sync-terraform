variable "default_values" {
  description = "A map of default values for the infrastructure"
  type = object({
    project_name    = string
    project_owner   = string
    project_version = string
    tags            = map(string)
  })
}

variable "lambda_name" {
  description = "The name of the Lambda function (used to name the security group)"
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID in which to create the security group"
  type        = string
}
