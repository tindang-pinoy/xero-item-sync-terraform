module "iam_role" {
  source = "./modules/iam_role"

  default_values = local.default_values
  lambda_name    = var.lambda_name
  lambda_version = var.lambda_version
}


module "lambda_function" {
  source = "./modules/aws_lambda"

  default_values = local.default_values
  lambda_name    = var.lambda_name
  lambda_version = var.lambda_version
  iam_role_arn   = module.iam_role.iam_role_arn
  image_tag      = local.handler_image_tag
}