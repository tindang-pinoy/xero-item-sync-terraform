resource "aws_lambda_function" "lambda_api_function" {
    function_name = var.lambda_name
    architectures = ["arm64"]
    role = var.iam_role_arn

    memory_size = 4096
    timeout = 30

    environment {
      variables = var.lambda_environments
    }

    description = "Xero Item Sync Lambda Function"
    image_uri = module.docker_image.image_uri
    package_type = "Image"

  dynamic "vpc_config" {
    for_each = length(var.subnet_ids) > 0 ? [1] : []
    content {
      subnet_ids         = var.subnet_ids
      security_group_ids = var.security_group_ids
    }
  }

  tags = local.tags
}

module "docker_image" {
    source = "terraform-aws-modules/lambda/aws//modules/docker-build"
    create_ecr_repo = true
    ecr_repo = local.project_name

    use_image_tag = true
    image_tag = var.image_tag

    source_path = "../"
}