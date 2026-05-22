# 1. Створюємо SNS Topic (канал сповіщень)
resource "aws_sns_topic" "alerts" {
  name = "lab4-system-alerts"
}

# 2. Підписуємо твій Email на цей канал
resource "aws_sns_topic_subscription" "email_target" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.email_address
}

# 3. BILLING ALARM (Сповіщення, якщо витрати перевищать $5)
resource "aws_cloudwatch_metric_alarm" "billing_alarm" {
  alarm_name          = "aws-billing-alarm-5-usd"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "EstimatedCharges"
  namespace           = "AWS/Billing"
  period              = "21600" # Перевірка кожні 6 годин
  statistic           = "Maximum"
  threshold           = "5.0"
  alarm_description   = "Відправляє алерт, якщо рахунок AWS перевищує 5 доларів"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    Currency = "USD"
  }
}

# 4. APPLICATION ALARM (Сповіщення, якщо Лямбда видає помилки)
resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "lambda-get-courses-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = "60" # Перевірка кожну хвилину
  statistic           = "Sum"
  threshold           = "0"  # Спрацює, якщо буде хоча б 1 помилка
  alarm_description   = "Моніторинг помилок виконання функції get-all-courses"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    FunctionName = var.lambda_function_name
  }
}