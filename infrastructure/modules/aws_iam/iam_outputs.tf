output "lambda_fetcher_role_arn" {
  value       = aws_iam_role.lambda_fetcher_role.arn
  description = "ARN of the fetcher Lambda IAM role"
}

output "lambda_fetcher_role_name" {
  value       = aws_iam_role.lambda_fetcher_role.name
  description = "Name of the fetcher Lambda IAM role"
}

output "lambda_db_writer_role_arn" {
  value       = aws_iam_role.lambda_db_writer_role.arn
  description = "ARN of the DB writer Lambda IAM role"
}

output "lambda_db_writer_role_name" {
  value       = aws_iam_role.lambda_db_writer_role.name
  description = "Name of the DB writer Lambda IAM role"
}
