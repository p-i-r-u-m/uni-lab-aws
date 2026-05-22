output "api_url" {
  value       = aws_apigatewayv2_api.this.api_endpoint
  description = "Головне посилання на наш API"
}