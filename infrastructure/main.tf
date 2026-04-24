module "iam_role" {
  source = "./modules/aws_iam"

  default_values        = local.default_values
  iam_role_name         = "${var.lambda_name_fetcher}-execution-role"
  lambda_name           = var.lambda_name_fetcher
  aws_region            = var.aws_region
  db_writer_lambda_name = var.lambda_name_uploader
  rds_iam_db_username   = var.rds_iam_db_username
  rds_resource_id       = data.aws_ssm_parameter.db_resource_id.value
  secret_arns           = var.secret_arns
}

# -------------------------------------------------------
# Lambda 1 — Fetcher
# Outside VPC: has full internet access for Xero API.
# Fetches data from Xero then invokes Lambda 2.
# -------------------------------------------------------
module "lambda_fetcher" {
  source = "./modules/aws_lambda"

  default_values = local.default_values
  lambda_name    = var.lambda_name_fetcher
  lambda_version = var.lambda_version
  iam_role_arn   = module.iam_role.lambda_fetcher_role_arn
  image_tag      = local.handler_image_tag
  lambda_description = var.lambda_fetcher_description
  lambda_environments = local.lambda_fetcher_environments
}

# -------------------------------------------------------
# Lambda 2 — DB Writer
# Inside default VPC with Lambda SG attached.
# No internet access needed — uses IAM auth token
# (generated locally via SigV4) to connect to RDS.
# -------------------------------------------------------
module "lambda_uploader" {
  source = "./modules/aws_lambda"

  default_values = local.default_values
  lambda_name    = var.lambda_name_uploader
  lambda_version = var.lambda_version
  iam_role_arn   = module.iam_role.lambda_db_writer_role_arn
  create_image   = false
  image_uri      = module.lambda_fetcher.image_uri
  handler_command = ["lambda_db_writer.lambda_handler"]
  subnet_ids         = data.aws_subnets.default.ids
  security_group_ids = [data.aws_ssm_parameter.lambda_sg_id.value]
  lambda_description = var.lambda_uploader_description
  lambda_environments = local.lambda_uploader_environments
}

# -------------------------------------------------------
# SQS — triggers Lambda 1 (fetcher)
# -------------------------------------------------------
module "sqs_queue" {
  source = "./modules/aws_sqs"

  default_values      = local.default_values
  queue_name          = var.lambda_name_fetcher
  lambda_function_arn = module.lambda_fetcher.lambda_function_arn
}

# SQS consume permissions on the fetcher role
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
  name   = "${var.lambda_name_fetcher}-sqs-policy"
  role   = module.iam_role.lambda_fetcher_role_name
  policy = data.aws_iam_policy_document.lambda_sqs_permissions.json
}
