# Створюємо сам бакет
resource "aws_s3_bucket" "frontend" {
  bucket = var.bucket_name
}

# Вимикаємо блокування публічного доступу (бо це ж вебсайт)
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket                  = aws_s3_bucket.frontend.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Вмикаємо режим хостингу статики
resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.frontend.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html" # Змінено для React
  }
}

# Додаємо політику, яка дозволяє будь-кому в інтернеті читати файли
resource "aws_s3_bucket_policy" "public_read" {
  bucket     = aws_s3_bucket.frontend.id
  depends_on = [aws_s3_bucket_public_access_block.public_access]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.frontend.arn}/*"
      }
    ]
  })
}

# Словник типів файлів, щоб браузер розумів, де стилі, а де скрипти
variable "mime_types" {
  default = {
    html = "text/html"
    css  = "text/css"
    js   = "application/javascript"
    ico  = "image/x-icon"
    png  = "image/png"
    json = "application/json"
  }
}

# Автоматично завантажуємо ВСІ файли з папки build у S3 бакет
resource "aws_s3_object" "files" {
  for_each = fileset("${path.module}/../../frontend_code/build", "**/*")

  bucket       = aws_s3_bucket.frontend.id
  key          = each.value
  source       = "${path.module}/../../frontend_code/build/${each.value}"
  content_type = lookup(var.mime_types, split(".", each.value)[length(split(".", each.value)) - 1], "application/octet-stream")
}

# Створюємо CloudFront Distribution для роздачі сайту
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    # Вказуємо CloudFront дивитися на наш бакет як на веб-сайт
    domain_name = aws_s3_bucket_website_configuration.website.website_endpoint
    origin_id   = "S3-${var.bucket_name}"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${var.bucket_name}"

    forwarded_values {
      query_string = false
      cookies { forward = "none" }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}