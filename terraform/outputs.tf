output "api_endpoint" {
  value       = "https://${aws_api_gateway_rest_api.notes_api.id}.execute-api.${var.region}.amazonaws.com/${aws_api_gateway_stage.prod_stage.stage_name}/notes"
  description = "Base URL for the Notes API"
}

output "api_key" {
  value       = aws_api_gateway_api_key.notes_api_key.value
  description = "API Key required to access the Notes API"
  sensitive   = true
}

output "lambda_arn" {
  value       = aws_lambda_function.notes_lambda.arn
  description = "ARN of the Notes Lambda function"
}

output "dynamodb_table_name" {
  value       = aws_dynamodb_table.notes.name
  description = "DynamoDB table for Notes"
}