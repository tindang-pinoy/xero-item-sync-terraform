output "queue_arn" {
  value       = aws_sqs_queue.lambda_trigger_queue.arn
  description = "The ARN of the SQS queue"
}

output "queue_url" {
  value       = aws_sqs_queue.lambda_trigger_queue.url
  description = "The URL of the SQS queue"
}

output "queue_name" {
  value       = aws_sqs_queue.lambda_trigger_queue.name
  description = "The name of the SQS queue"
}

output "dlq_arn" {
  value       = aws_sqs_queue.dead_letter_queue.arn
  description = "The ARN of the dead letter queue"
}

output "dlq_url" {
  value       = aws_sqs_queue.dead_letter_queue.url
  description = "The URL of the dead letter queue"
}
