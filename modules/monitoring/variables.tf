variable "email_address" {
  type        = string
  description = "Твоя електронна пошта для отримання алертів"
}

variable "lambda_function_name" {
  type        = string
  description = "Назва лямбди, яку ми моніторимо на помилки"
}