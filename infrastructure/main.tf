# Look up the VPC and subnets created by tdp-database-terraform
data "aws_vpc" "tdp" {
  tags = {
    projectId = "tdp-database"
  }
}

data "aws_subnets" "tdp_public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.tdp.id]
  }
}

module "iam_role" {
  source = "./modules/aws_iam"

  default_values = local.default_values
  iam_role_name  = "${var.lambda_name}-execution-role"
  lambda_name    = var.lambda_name
}

module "lambda_security_group" {
  source = "./modules/aws_security_group"

  default_values = local.default_values
  lambda_name    = var.lambda_name
  vpc_id         = data.aws_vpc.tdp.id
}

module "lambda_function" {
  source = "./modules/aws_lambda"

  default_values     = local.default_values
  lambda_name        = var.lambda_name
  lambda_version     = var.lambda_version
  iam_role_arn       = module.iam_role.lambda_iam_role_arn
  image_tag           = local.handler_image_tag
  subnet_ids          = data.aws_subnets.tdp_public.ids
  security_group_ids  = [module.lambda_security_group.security_group_id]
  lambda_environments = var.lambda_environments
}

module "sqs_queue" {
  source = "./modules/aws_sqs"

  default_values      = local.default_values
  queue_name          = var.lambda_name
  lambda_function_arn = module.lambda_function.lambda_function_arn
}

data "aws_iam_policy_document" "lambda_sqs_permissions" {
  statement {
    effect = "Allow"
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:ChangeMessageVisibility",
    ]
    resources = [module.sqs_queue.queue_arn]
  }
}

resource "aws_iam_role_policy" "lambda_sqs_policy" {
  name   = "${var.lambda_name}-sqs-policy"
  role   = module.iam_role.lambda_iam_role_name
  policy = data.aws_iam_policy_document.lambda_sqs_permissions.json
}
