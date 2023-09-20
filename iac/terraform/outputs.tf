output "lambda_cron_arn" {
  value = module.cron.lambda_arn
}

output "lambda_cron_name" {
  value = module.cron.lambda_function_name
}

output "lambda_cron_version" {
  value = module.cron.lambda_version
}