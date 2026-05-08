output "invoke_url" {
  value       = aws_apigatewayv2_stage.default.invoke_url
  description = "Invoke URL for the HTTP API Gateway"
}

output "api_id" {
  value       = aws_apigatewayv2_api.this.id
  description = "ID of the HTTP API Gateway"
}
