# ── Lambda 1 — Fetcher ────────────────────────────────────────────────────────
output "lambda_fetcher_arn" {
  value       = module.lambda_fetcher.lambda_function_arn
  description = "ARN of the fetcher Lambda (Lambda 1 — outside VPC, calls Xero API)"
}

# ── Lambda 2 — DB Writer ──────────────────────────────────────────────────────
output "lambda_uploader_arn" {
  value       = module.lambda_uploader.lambda_function_arn
  description = "ARN of the DB writer Lambda (Lambda 2 — inside VPC, writes to RDS via IAM auth)"
}

# ── SQS ───────────────────────────────────────────────────────────────────────
output "sqs_queue_url" {
  value       = module.sqs_queue.queue_url
  description = "URL of the SQS queue that triggers the fetcher Lambda"
}

output "sqs_queue_arn" {
  value       = module.sqs_queue.queue_arn
  description = "ARN of the SQS queue that triggers the fetcher Lambda"
}

output "sqs_dlq_arn" {
  value       = module.sqs_queue.dlq_arn
  description = "ARN of the dead-letter queue"
}
