# Build the Docker image and push to ECR only for the primary Lambda.
# Secondary Lambdas reuse the same image by passing image_uri directly.
module "docker_image" {
  # Static bool — known at plan time, so Terraform can determine
  # the instance count before any resources are applied.
  count  = var.create_image ? 1 : 0
  source = "terraform-aws-modules/lambda/aws//modules/docker-build"

  create_ecr_repo = true
  ecr_repo        = local.project_name

  use_image_tag = true
  image_tag     = var.image_tag

  source_path = "../"
}

locals {
  # one() returns null when the list is empty (create_image = false),
  # coalesce then falls back to the explicitly supplied image_uri.
  resolved_image_uri = coalesce(one(module.docker_image[*].image_uri), var.image_uri)
}

resource "aws_lambda_function" "lambda_function" {
  function_name = var.lambda_name
  architectures = ["arm64"]
  role          = var.iam_role_arn

  memory_size = 4096
  timeout     = 30

  environment {
    variables = var.lambda_environments
  }

  description  = var.lambda_description
  image_uri    = local.resolved_image_uri
  package_type = "Image"

  # Override the container CMD when a non-default handler is required
  dynamic "image_config" {
    for_each = var.handler_command != null ? [1] : []
    content {
      command = var.handler_command
    }
  }

  dynamic "vpc_config" {
    for_each = length(var.subnet_ids) > 0 ? [1] : []
    content {
      subnet_ids         = var.subnet_ids
      security_group_ids = var.security_group_ids
    }
  }
  tags = local.tags
}
