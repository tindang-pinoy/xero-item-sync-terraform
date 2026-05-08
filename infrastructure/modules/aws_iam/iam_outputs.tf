output "lambda_fetcher_role_arn" {
  value       = aws_iam_role.lambda_fetcher_role.arn
  description = "ARN of the fetcher Lambda IAM role"
}

output "lambda_fetcher_role_name" {
  value       = aws_iam_role.lambda_fetcher_role.name
  description = "Name of the fetcher Lambda IAM role"
}

output "lambda_uploader_role_arn" {
  value       = aws_iam_role.lambda_uploader_role.arn
  description = "ARN of the Uploader Lambda IAM role"
}

output "lambda_uploader_role_name" {
  value       = aws_iam_role.lambda_uploader_role.name
  description = "Name of the Uploader Lambda IAM role"
}

output "lambda_db_api_role_arn" {
  value       = aws_iam_role.lambda_db_api_role.arn
  description = "ARN of the DB API Lambda IAM role"
}

output "lambda_db_api_role_name" {
  value       = aws_iam_role.lambda_db_api_role.name
  description = "Name of the DB API Lambda IAM role"
}