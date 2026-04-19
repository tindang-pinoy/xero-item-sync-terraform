locals {
    project_name = var.default_values.project_name
    project_owner = var.default_values.project_owner
    project_version = var.default_values.project_version
    sf_environment = var.default_values.sf_environment
    tags = merge(var.default_values.tags, {
        "LambdaVersion" = var.lambda_version
    })
}