output "base_api_url" {
  value = module.api_gateway.api_url
}

output "frontend_url" {
  value = module.s3_frontend.website_endpoint
}

output "cloudfront_frontend_url" {
  value = module.s3_frontend.cloudfront_url
}