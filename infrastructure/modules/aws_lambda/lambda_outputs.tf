output "lambda_function_arn" {
  value       = aws_lambda_function.lambda_function.arn
  description = "ARN of the Lambda function"
}

output "image_uri" {
  value       = local.resolved_image_uri
  description = "Container image URI used by this Lambda function"
}
