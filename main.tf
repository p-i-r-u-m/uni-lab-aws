provider "aws" {
  region = var.aws_region
}

# Створюємо таблицю для авторів
module "dynamodb_authors" {
  source     = "./modules/dynamodb"
  table_name = "${module.label.id}-authors"
  tags       = module.label.tags
}

# Створюємо таблицю для курсів
module "dynamodb_courses" {
  source     = "./modules/dynamodb"
  table_name = "${module.label.id}-courses"
  tags       = module.label.tags
}


# Створюємо IAM роль і передаємо їй ARN обох таблиць
module "iam_lambda" {
  source      = "./modules/iam"
  name_prefix = module.label.id
  table_arns  = [module.dynamodb_authors.table_arn, module.dynamodb_courses.table_arn]
}

# Створюємо 6 функцій
module "lambda_get_all_authors" {
  source            = "./modules/lambda"
  function_name     = "${module.label.id}-get-all-authors"
  filename          = "get-all-authors"
  role_arn          = module.iam_lambda.role_arn
  target_table_name = module.dynamodb_authors.table_name
}

module "lambda_get_all_courses" {
  source            = "./modules/lambda"
  function_name     = "${module.label.id}-get-all-courses"
  filename          = "get-all-courses"
  role_arn          = module.iam_lambda.role_arn
  target_table_name = module.dynamodb_courses.table_name
}

module "lambda_get_course" {
  source            = "./modules/lambda"
  function_name     = "${module.label.id}-get-course"
  filename          = "get-course"
  role_arn          = module.iam_lambda.role_arn
  target_table_name = module.dynamodb_courses.table_name
}

module "lambda_save_course" {
  source            = "./modules/lambda"
  function_name     = "${module.label.id}-save-course"
  filename          = "save-course"
  role_arn          = module.iam_lambda.role_arn
  target_table_name = module.dynamodb_courses.table_name
}

module "lambda_update_course" {
  source            = "./modules/lambda"
  function_name     = "${module.label.id}-update-course"
  filename          = "update-course"
  role_arn          = module.iam_lambda.role_arn
  target_table_name = module.dynamodb_courses.table_name
}

module "lambda_delete_course" {
  source            = "./modules/lambda"
  function_name     = "${module.label.id}-delete-course"
  filename          = "delete-course"
  role_arn          = module.iam_lambda.role_arn
  target_table_name = module.dynamodb_courses.table_name
}

module "api_gateway" {
  source                     = "./modules/api_gateway"
  name_prefix                = module.label.id
  lambda_get_all_authors_arn = module.lambda_get_all_authors.function_arn
  lambda_get_all_courses_arn = module.lambda_get_all_courses.function_arn
  lambda_get_course_arn      = module.lambda_get_course.function_arn
  lambda_save_course_arn     = module.lambda_save_course.function_arn
  lambda_update_course_arn   = module.lambda_update_course.function_arn
  lambda_delete_course_arn   = module.lambda_delete_course.function_arn
}

module "s3_frontend" {
  source      = "./modules/s3_frontend"
  bucket_name = "${module.label.id}-frontend-bucket"
}

module "monitoring" {
  source               = "./modules/monitoring"
  email_address        = "ivan.hrushevskyi.ri.2024@lpnu.ua" # ВПИШИ СЮДИ СВОЮ ПОШТУ
  lambda_function_name = module.lambda_get_all_courses.function_name
}