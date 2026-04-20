resource "aws_security_group" "lambda_sg" {
  name        = "${var.lambda_name}-sg"
  description = "Security group for Lambda function ${var.lambda_name}"
  vpc_id      = var.vpc_id

  tags = merge(var.default_values.tags, {
    Name = "${var.lambda_name}-sg"
  })
}

resource "aws_vpc_security_group_egress_rule" "all_outbound" {
  security_group_id = aws_security_group.lambda_sg.id
  description       = "Allow all outbound traffic"

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"

  tags = var.default_values.tags
}
