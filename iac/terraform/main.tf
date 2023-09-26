################################################################################
## defaults
################################################################################
terraform {
  required_version = ">= 1.4.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.15"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.5.1"
    }
  }
}

## providers
provider "aws" {
  region  = var.region
  profile = var.profile
}

##Random-PET
resource "random_pet" "this" {
  length = 2
}

################################################################################
## tags
################################################################################
module "tags" {
  source = "git::https://github.com/sourcefuse/terraform-aws-refarch-tags?ref=1.0.1"

  environment = var.environment
  project     = "typescript-lambda-boilerplate"
}

################################################################################
## ECR
################################################################################
module "ecr" {
  count       = var.create_ecr_repository ? 1 : 0
  source      = "./ecr"
  environment = var.environment
  namespace   = var.namespace
  region      = var.region
}

data "aws_caller_identity" "current_caller" {}

data "aws_region" "current" {}

################################################################################
## lambda
################################################################################
module "cron" {
  source         = "./lambda"
  environment    = var.environment
  region         = var.region
  lambda_name    = local.cron_lambda_name
  lambda_memory  = 128
  lambda_timeout = 120
  lambda_package_type = "Image"
  image_uri    = "${data.aws_caller_identity.current_caller.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/arc-dev-dotnet-acm-cert-renewer-lambda:latest"

  #vpc_config = local.vpc_config

  kms_key_admin_arns = var.kms_key_admin_arns

  tags = module.tags.extra_tags
}

resource "aws_iam_policy" "Policy-for-all-resources" {
  name = "admin_policy"
  # Policy for all resources used in lambda boilerplate
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface",
          "ec2:AssignPrivateIpAddresses",
          "ec2:UnassignPrivateIpAddresses"
        ],

        Resource = "*" //NOSONAR

      }
    ]
  })
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy_attachment" "lambda_policy_role" {
  name       = "lambda_attachment"
  roles      = [aws_iam_role.lambda_role.name]
  policy_arn = aws_iam_policy.Policy-for-all-resources.arn
}

# Define the ACM permission policy
resource "aws_iam_policy" "acm_permission_policy" {
  name        = "ACMPermissionPolicy"
  description = "Policy for ACM permissions"

  # Define the permissions required for ACM certificate renewal
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = [
          "acm:RenewCertificate",
          "acm:GetCertificate",
          "acm:ListCertificates"
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_acm_permission_policy_attachment" {
  role       = module.cron.lambda_role_name
  policy_arn = aws_iam_policy.acm_permission_policy.arn
}


################################################################################
## cron
################################################################################

resource "aws_cloudwatch_event_rule" "lambda_cron" {
  name                = "${local.cron_lambda_name}-cron"
  schedule_expression = local.cron_lambda_schedule
}

resource "aws_lambda_permission" "allow_cloudwatch_to_invoke" {
  function_name = module.cron.lambda_function_name
  statement_id  = "CloudWatchInvoke"
  action        = "lambda:InvokeFunction"

  source_arn = aws_cloudwatch_event_rule.lambda_cron.arn
  principal  = "events.amazonaws.com"
}

resource "aws_cloudwatch_event_target" "invoke_lambda" {
  rule = aws_cloudwatch_event_rule.lambda_cron.name
  arn  = module.cron.lambda_arn
}
