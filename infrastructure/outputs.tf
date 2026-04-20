output "lambda_security_group_id" {
  value       = module.lambda_security_group.security_group_id
  description = "The ID of the Lambda security group — add this to lambda_security_group_ids in tdp-database-terraform/prod.tfvars"
}

output "lambda_function_arn" {
  value       = module.lambda_function.lambda_function_arn
  description = "The ARN of the Lambda function"
}

output "sqs_queue_url" {
  value       = module.sqs_queue.queue_url
  description = "The URL of the SQS queue that triggers the Lambda"
}

output "sqs_queue_arn" {
  value       = module.sqs_queue.queue_arn
  description = "The ARN of the SQS queue that triggers the Lambda"
}
