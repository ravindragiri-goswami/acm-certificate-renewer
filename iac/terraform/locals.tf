locals {

  cron_lambda_name      = "arc-${var.environment}-dotnet-acm-cert-renewer-lambda-${random_pet.this.id}"
  cron_lambda_schedule  = var.cron_lambda_schedule == null ? "rate(1 minute)" : var.cron_lambda_schedule
  kms_key_admin_arns       = var.kms_key_admin_arns
}
