resource "aws_apigatewayv2_api" "this" {
  name          = "${var.name_prefix}-api"
  protocol_type = "HTTP"

  # Додаємо CORS
  cors_configuration {
    allow_headers = ["Content-Type", "Authorization", "X-Amz-Date", "X-Api-Key", "X-Amz-Security-Token"]
    allow_methods = ["OPTIONS", "GET", "POST", "PUT", "DELETE"]
    allow_origins = ["*"] 
  }
}

# Створюємо stage (середовище), щоб API автоматично розгорталося
resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.this.id
  name        = "$default"
  auto_deploy = true
}

# --- ІНТЕГРАЦІЇ (Зв'язок API з нашими Лямбдами) ---
resource "aws_apigatewayv2_integration" "get_all_authors" {
  api_id           = aws_apigatewayv2_api.this.id
  integration_type = "AWS_PROXY"
  integration_uri  = var.lambda_get_all_authors_arn
}
resource "aws_apigatewayv2_integration" "get_all_courses" {
  api_id           = aws_apigatewayv2_api.this.id
  integration_type = "AWS_PROXY"
  integration_uri  = var.lambda_get_all_courses_arn
}
resource "aws_apigatewayv2_integration" "get_course" {
  api_id           = aws_apigatewayv2_api.this.id
  integration_type = "AWS_PROXY"
  integration_uri  = var.lambda_get_course_arn
}
resource "aws_apigatewayv2_integration" "save_course" {
  api_id           = aws_apigatewayv2_api.this.id
  integration_type = "AWS_PROXY"
  integration_uri  = var.lambda_save_course_arn
}
resource "aws_apigatewayv2_integration" "update_course" {
  api_id           = aws_apigatewayv2_api.this.id
  integration_type = "AWS_PROXY"
  integration_uri  = var.lambda_update_course_arn
}
resource "aws_apigatewayv2_integration" "delete_course" {
  api_id           = aws_apigatewayv2_api.this.id
  integration_type = "AWS_PROXY"
  integration_uri  = var.lambda_delete_course_arn
}

# --- МАРШРУТИ (Що вводити в браузері) ---
resource "aws_apigatewayv2_route" "get_all_authors" {
  api_id    = aws_apigatewayv2_api.this.id
  route_key = "GET /authors"
  target    = "integrations/${aws_apigatewayv2_integration.get_all_authors.id}"
}
resource "aws_apigatewayv2_route" "get_all_courses" {
  api_id    = aws_apigatewayv2_api.this.id
  route_key = "GET /courses"
  target    = "integrations/${aws_apigatewayv2_integration.get_all_courses.id}"
}
resource "aws_apigatewayv2_route" "get_course" {
  api_id    = aws_apigatewayv2_api.this.id
  route_key = "GET /courses/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.get_course.id}"
}
resource "aws_apigatewayv2_route" "save_course" {
  api_id    = aws_apigatewayv2_api.this.id
  route_key = "POST /courses"
  target    = "integrations/${aws_apigatewayv2_integration.save_course.id}"
}
resource "aws_apigatewayv2_route" "update_course" {
  api_id    = aws_apigatewayv2_api.this.id
  route_key = "PUT /courses/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.update_course.id}"
}
resource "aws_apigatewayv2_route" "delete_course" {
  api_id    = aws_apigatewayv2_api.this.id
  route_key = "DELETE /courses/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.delete_course.id}"
}