# Xero Item Sync — Terraform

AWS infrastructure and Lambda code for syncing Xero inventory items into an RDS database. The Lambda is containerised, deployed via ECR, and triggered by an SQS queue message.

---

## Table of Contents

- [Architecture Overview](#architecture-overview)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
- [Infrastructure](#infrastructure)
- [Lambda](#lambda)
- [Todo](#todo)
- [Known Issues](#known-issues)

---

## Architecture Overview

```
SQS Queue
    │
    ▼
AWS Lambda (Docker / ECR)
    │
    ├──▶  Xero API  (/items)
    │
    └──▶  RDS Database  (upsert)
```

An SQS message triggers the Lambda. The Lambda authenticates with Xero, fetches the full item list, transforms the response, and upserts the records into RDS.

---

## Project Structure

```
xero-item-sync-terraform/
├── Dockerfile                        # Lambda container image (Python 3.14 on ARM64)
├── requirements.txt                  # Python dependencies
├── setup.py                          # Local dev environment bootstrap
├── .env                              # Environment variable template (not committed)
│
├── lambda_code/
│   ├── lambda_handler.py             # Lambda entry point
│   └── utilities/
│       └── goFetch.py                # HTTP utility stub
│
└── infrastructure/
    ├── main.tf                       # Module orchestration
    ├── providers.tf                  # AWS provider configuration
    ├── variables.tf                  # Input variable declarations
    ├── outputs.tf                    # Stack outputs
    ├── locals.tf                     # Computed local values
    ├── application_tags.tf           # AWS Service Catalog & Resource Group
    ├── env_variables/
    │   └── template.tfvars           # Template for environment-specific values
    └── modules/
        ├── aws_iam/                  # IAM execution role for Lambda
        └── aws_lambda/               # Lambda function + ECR image build
```

---

## Prerequisites

| Tool | Minimum Version |
|------|----------------|
| Terraform | >= 1.5 |
| Docker | >= 24 |
| Python | 3.14 |
| AWS CLI | >= 2 |
| `uv` (Python package manager) | latest |

AWS credentials must be configured with permissions for IAM, Lambda, ECR, SQS, RDS, and AWS Service Catalog.

---

## Getting Started

### 1. Bootstrap the local environment

```bash
python setup.py
```

This creates a virtual environment via `uv`, installs dependencies from `requirements.txt`, and generates a `.env` file.

### 2. Add environment variables

Edit `.env` and populate the required values (Xero credentials, RDS connection string, AWS region, etc.).

### 3. Configure Terraform variables

Copy the variable template and fill in your values:

```bash
cp infrastructure/env_variables/template.tfvars infrastructure/env_variables/dev.tfvars
# edit dev.tfvars
```

### 4. Deploy

```bash
cd infrastructure
terraform init
terraform plan -var-file="env_variables/dev.tfvars"
terraform apply -var-file="env_variables/dev.tfvars"
```

---

## Infrastructure

### Modules

| Module | Path | Purpose |
|--------|------|---------|
| `aws_iam` | `modules/aws_iam` | Creates the Lambda execution IAM role with `AWSLambdaBasicExecutionRole` |
| `aws_lambda` | `modules/aws_lambda` | Builds the Docker image, pushes to ECR, and deploys the Lambda function |

### Key resource settings (Lambda)

| Setting | Value |
|---------|-------|
| Runtime | Container image (Python 3.14) |
| Architecture | ARM64 |
| Memory | 4096 MB |
| Timeout | 30 seconds |

---

## Lambda

### Entry point

`lambda_code/lambda_handler.py` — `lambda_handler(event, context)`

### Dependencies

| Package | Purpose |
|---------|---------|
| `requests` | HTTP calls to the Xero API |
| `boto3` | AWS SDK (SQS, RDS, Secrets Manager) |
| `pyjwt` / `cryptography` | Xero OAuth 2.0 JWT handling |
| `fastapi` / `mangum` | Optional local development server |

---

## Todo

### 1. SQS trigger for Lambda

- [ ] Define an `aws_sqs_queue` Terraform resource for the inbound sync queue
- [ ] Add an `aws_lambda_event_source_mapping` to connect the SQS queue to the Lambda function
- [ ] Grant the Lambda execution role `sqs:ReceiveMessage`, `sqs:DeleteMessage`, and `sqs:GetQueueAttributes` permissions on the queue
- [ ] Parse and validate the SQS message body inside `lambda_handler.py`

### 2. Fetch items from the Xero `/items` endpoint

- [ ] Implement `utilities/goFetch.py` — an authenticated HTTP client that accepts a URL and returns the parsed JSON response
- [ ] Add Xero OAuth 2.0 token retrieval (client credentials or refresh token flow) — store credentials in AWS Secrets Manager
- [ ] Call `GET https://api.xero.com/api.xro/2.0/Items` with the correct `Xero-Tenant-Id` header
- [ ] Handle Xero API pagination if the item count exceeds the default page size
- [ ] Handle Xero rate-limit responses (429) with exponential back-off

### 3. ETL — transform the Xero response

- [ ] Create a transformation module (e.g. `utilities/transform.py`) that maps Xero `Item` fields to the target RDS schema
- [ ] Normalise field names (PascalCase → snake_case)
- [ ] Handle optional/nullable Xero fields gracefully
- [ ] Strip or redact any fields not required in the database
- [ ] Add unit tests for the transformation logic

### 4. Upsert into RDS

- [ ] Provision the target RDS instance (and subnet group, security group) in Terraform, or document the existing RDS dependency
- [ ] Store the RDS connection string in AWS Secrets Manager and retrieve it at Lambda cold-start
- [ ] Implement a database client module (e.g. `utilities/db.py`) using `psycopg2` or `sqlalchemy`
- [ ] Write an `upsert_items(records)` function that inserts new rows and updates existing ones (keyed on Xero `ItemID`)
- [ ] Add the Lambda execution role permission to access the RDS Secrets Manager secret
- [ ] Ensure the Lambda VPC configuration matches the RDS subnet if RDS is not publicly accessible
- [ ] Add integration tests against a local or dev RDS instance

---

## Known Issues

| Location | Issue |
|----------|-------|
| `infrastructure/main.tf` | Module source path references `./modules/iam_role` — should be `./modules/aws_iam` |
| `infrastructure/modules/aws_lambda/lambda_outputs.tf` | References `aws_lambda_function.lambda_function` — resource is named `lambda_api_function` |
| `Dockerfile` | `CMD` references `api_handler.lambda_handler` — entry file is `lambda_handler.py` |
| `lambda_code/utilities/goFetch.py` | Empty stub — no implementation |
| `infrastructure/providers.tf` | Empty — AWS provider block not yet defined |
| `infrastructure/outputs.tf` | Empty — no stack outputs defined |
