# -------------------------------------------------------
# Default VPC + subnets — used to place Lambda 2 (DB
# writer) inside the VPC so it can reach RDS via the
# Lambda SG → RDS SG rule without needing a NAT gateway.
# Lambda 1 (fetcher) remains outside the VPC for internet
# access to the Xero API.
# -------------------------------------------------------
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  filter {
    name   = "defaultForAz"
    values = ["true"]
  }
}
