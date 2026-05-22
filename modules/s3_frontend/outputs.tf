output "website_endpoint" {
  value       = aws_s3_bucket_website_configuration.website.website_endpoint
  description = "Публічне посилання на наш вебсайт"
}

output "cloudfront_url" {
  value       = aws_cloudfront_distribution.s3_distribution.domain_name
  description = "Посилання на CloudFront"
}