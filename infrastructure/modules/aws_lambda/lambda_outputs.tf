output "lambda_function_arn" {
  value       = aws_lambda_function.lambda_api_function.arn
  description = "The ARN of the Lambda function"
}