locals {
    project_name = var.default_values.project_name
    project_owner = var.default_values.project_owner
    project_version = var.default_values.project_version
    tags = merge(var.default_values.tags, {
        "LambdaVersion" = var.lambda_version
    })
}