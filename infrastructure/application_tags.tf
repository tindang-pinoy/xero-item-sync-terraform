resource "aws_servicecatalogappregistry_application" "app" {
  name        = local.application_name
  description = "Service Catalog App Registry Application for ${var.project_name}"
  tags = {
    Application = var.project_name
    Owner       = var.project_owner
    Version     = var.project_version
  }
}

resource "aws_resourcegroups_group" "app_group" {
  name        = local.application_name
  description = "Resource Group for ${var.project_name}"

  resource_query {
    query = jsonencode({
      ResourceTypeFilters = ["AWS::AllSupported"]
      TagFilters = [{
        Key    = "Application",
        Values = [local.application_name]
      }]
    })
    type = "TAG_FILTERS_1_0"
  }
}