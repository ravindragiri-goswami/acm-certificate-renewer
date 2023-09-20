################################################################################
## shared
################################################################################
variable "environment" {
  description = "Name of the environment resources will be created in."
  type        = string
  default     = "dev"
}

variable "region" {
  description = "Name of the region resources will be created in."
  type        = string
  default     = "us-east-1"
}

variable "profile" {
  description = "Name of the AWS Profile configured on your workstation."
  type        = string
}

variable "namespace" {
  type        = string
  default     = "arc"
  description = "Identifier used to namespace resources, i.e. project name, company name, etc."
}

variable "kms_key_admin_arns" {
  description = <<EOT
                IAM roles to map to the KMS key policy for administering 
                the KMS key used for SSE. Must be set to avoid MalformedPolicyDocumentException
                eg: ["arn:aws:iam::$\{data.aws_caller_identity.current_caller.account_id}:my-key-manager-user"]
                EOT
  type        = list(string)
}

################################################################################
## lambda
################################################################################
variable "lambda_package_type" {
  description = "lambda package type"
  type        = string
  default     = null
}

variable "vpc_config" {
  description = "Optional VPC Configurations params"
  type        = map(any)
  default     = null
}

################################################################################
## cron
################################################################################

variable "cron_lambda_schedule" {
  description = "The cron expression for the event bridge rule"
  type        = string
  default     = "rate(1 minute)"
}