locals {
  ecr_repos = {
    sns = {
      name = "dotnet-acm-cert-renewer-lambda"
    }
  }
}

module "tags" {
  source = "git::https://github.com/sourcefuse/terraform-aws-refarch-tags?ref=1.2.0"

  environment = var.environment
  project     = "arc-dotnet-lambda"

  extra_tags = {
    dotnet = "True"
  }
}

################################################################################
## ecr
################################################################################
module "ecr" {
  source = "cloudposse/ecr/aws"

  version   = "0.38.0"
  namespace = var.namespace
  stage     = var.environment
  for_each  = local.ecr_repos
  name      = each.value.name
  tags      = module.tags.tags
}
