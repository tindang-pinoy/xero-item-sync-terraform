# -------------------------------------------------------
# SSM lookups — cross-project dependencies resolved here
# so the rest of the configuration stays free of data sources
# -------------------------------------------------------

# From core-infrastructure
data "aws_ssm_parameter" "lambda_sg_id" {
  name = "/${var.core_infrastructure_project_name}/security-groups/lambda-sg-id"
}

# From database project
data "aws_ssm_parameter" "db_endpoint" {
  name = "/${var.database_project_name}/rds/endpoint"
}

data "aws_ssm_parameter" "db_name" {
  name = "/${var.database_project_name}/rds/db-name"
}

data "aws_ssm_parameter" "db_resource_id" {
  name = "/${var.database_project_name}/rds/resource-id"
}
