resource "aws_lambda_function" "lambda_api_function" {
    function_name = var.lambda_name
    architectures = ["arm64"]
    role = var.iam_role_arn

    memory_size = 4096
    timeout = 30

    environment {
      variables = var.lambda_environments
    }

    description = "Salesforce Code (v2) API Handler Function"
    image_uri = module.docker_image.image_uri
    package_type = "Image"

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