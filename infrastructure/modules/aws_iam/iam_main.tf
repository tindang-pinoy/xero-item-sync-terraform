data "aws_iam_policy_document" "lambda_assume_role_policy"{
    statement {
        effect = "Allow"
        principals {
            type = "Service"
            identifiers = ["lambda.amazonaws.com"]
        }
        actions = ["sts:AssumeRole"]
    }
}

resource "aws_iam_role" "lambda_execution_role" {
    name = var.iam_role_name
    assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}

# Provide lambda access to create lambda Cloudwatch Logs
resource "aws_iam_role_policy_attachment" "lambda_logs_basic_execution" {
    role = aws_iam_role.lambda_execution_role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}