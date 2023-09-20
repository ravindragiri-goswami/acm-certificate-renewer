locals {
  cw_kms_alias       = "alias/${var.lambda_name}/cw"
  kms_key_admin_arns = var.kms_key_admin_arns
}
