################################################################################
## shared
################################################################################
variable "environment" {
  description = "Name of the environment."
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "tags" {
  description = "Set of tags to apply to resources"
  type        = map(string)
}

################################################################################
## lambda
################################################################################
variable "image_uri" {
  type        = string
  description = "ECR image URI containing the function's deployment package."
}

variable "lambda_handler" {
  description = "Function entrypoint in your code. For more information see https://docs.aws.amazon.com/lambda/latest/dg/gettingstarted-awscli.html"
  type        = string
  default     = "index.handler"
}

variable "lambda_package_type" {
  description = "lambda package type"
  type        = string
  default     = null
}

variable "lambda_timeout" {
  description = "Lambda timeout in seconds."
  type        = number
}

variable "lambda_memory" {
  description = "Lambda memory in MB."
  type        = number
}

variable "lambda_name" {
  description = "Name of the lambda"
  type        = string
  default     = "lambda-boilerplate"
}

variable "custom_vars" {
  description = "Custom environment variables for the lambda function"
  type        = map(any)
  default     = {}
}

variable "vpc_config" {
  description = "Optional VPC Configurations params"
  type        = map(any)
  default     = null
}

################################################################################
## cloudwatch
################################################################################
variable "lambda_cw_log_group_retention_in_days" {
  description = "CloudWatch log group retention in days."
  type        = number
  default     = 30
}

################################################################################
## kms
################################################################################
variable "kms_key_admin_arns" {
  description = "Additional IAM roles to map to the KMS key policy for administering the KMS key used for SSE."
  type        = list(string)
  default     = []
}

variable "kms_key_deletion_window_in_days" {
  description = "Deletion window for KMS key in days."
  type        = number
  default     = 10
}
