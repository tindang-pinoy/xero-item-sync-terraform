output "security_group_id" {
  value       = aws_security_group.lambda_sg.id
  description = "The ID of the Lambda security group"
}

output "security_group_arn" {
  value       = aws_security_group.lambda_sg.arn
  description = "The ARN of the Lambda security group"
}
