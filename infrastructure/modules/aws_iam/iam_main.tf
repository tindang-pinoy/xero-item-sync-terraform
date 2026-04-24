data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

# -------------------------------------------------------
# Lambda 1 — Fetcher role
# Runs outside VPC. Needs Secrets Manager (Xero creds)
# and permission to invoke the DB writer Lambda.
# -------------------------------------------------------
resource "aws_iam_role" "lambda_fetcher_role" {
  name               = var.iam_role_name
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
  tags               = local.tags
}

resource "aws_iam_role_policy_attachment" "fetcher_basic_execution" {
  role       = aws_iam_role.lambda_fetcher_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "fetcher_invoke_db_writer" {
  name = "${var.lambda_name}-invoke-db-writer"
  role = aws_iam_role.lambda_fetcher_role.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "lambda:InvokeFunction"
      Resource = "arn:aws:lambda:${var.aws_region}:${data.aws_caller_identity.current.account_id}:function:${var.db_writer_lambda_name}"
    }]
  })
}

resource "aws_iam_role_policy" "fetcher_secrets_manager" {
  count = length(var.secret_arns) > 0 ? 1 : 0
  name  = "${var.lambda_name}-secrets-manager-policy"
  role  = aws_iam_role.lambda_fetcher_role.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "secretsmanager:GetSecretValue"
      Resource = var.secret_arns
    }]
  })
}

# -------------------------------------------------------
# Lambda 2 — DB Writer role
# Runs inside VPC. Needs VPC network interfaces and
# rds-db:connect for IAM-authenticated RDS access.
# No Secrets Manager or internet access required.
# -------------------------------------------------------
resource "aws_iam_role" "lambda_db_writer_role" {
  name               = "${var.iam_role_name}-db-writer"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
  tags               = local.tags
}

resource "aws_iam_role_policy_attachment" "db_writer_basic_execution" {
  role       = aws_iam_role.lambda_db_writer_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "db_writer_vpc_access" {
  role       = aws_iam_role.lambda_db_writer_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy" "db_writer_rds_iam_auth" {
  name = "${var.lambda_name}-db-writer-rds-iam-auth"
  role = aws_iam_role.lambda_db_writer_role.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "rds-db:connect"
      Resource = "arn:aws:rds-db:${var.aws_region}:${data.aws_caller_identity.current.account_id}:dbuser:${var.rds_resource_id}/${var.rds_iam_db_username}"
    }]
  })
}
