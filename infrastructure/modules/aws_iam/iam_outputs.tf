output "lambda_iam_role_arn" {
  value       = aws_iam_role.lambda_execution_role.arn
  description = "The ARN of the IAM role for the Lambda function"
}

output "lambda_iam_role_name" {
  value       = aws_iam_role.lambda_execution_role.name
  description = "The name of the IAM role for the Lambda function"
}