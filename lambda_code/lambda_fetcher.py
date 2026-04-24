import boto3
import json
import logging
import os

from utilities import layer_api as api

logger = logging.getLogger()
logger.setLevel(logging.INFO)

_lambda_client = boto3.client("lambda", region_name=os.getenv("AWS_REGION", "ap-southeast-2"))


def lambda_handler(event, context):
    """
    Lambda 1 — Fetcher.
    Triggered by SQS. Fetches items from the Xero API then
    synchronously invokes the DB writer Lambda with the payload.
    Runs outside the VPC so it has full internet access.
    """
    logger.info("Fetcher: starting Xero items fetch...")

    access_token  = api.get_access_token()
    tenant_id     = api.get_xero_tenant_id(access_token)
    xero_response = api.fetch_xero_items(access_token, tenant_id)

    logger.info("Fetcher: invoking DB writer Lambda...")

    db_writer_name = os.getenv("DB_WRITER_FUNCTION_NAME")
    
    response = _lambda_client.invoke(
        FunctionName    = db_writer_name,
        InvocationType  = "RequestResponse",
        Payload         = json.dumps(xero_response),
    )

    status = response["StatusCode"]
    result = json.loads(response["Payload"].read())
    logger.info(f"Fetcher: DB writer returned {status} — {result}")

    if status != 200:
        raise RuntimeError(f"DB writer Lambda failed with status {status}: {result}")

    return {
        "statusCode": 200,
        "body": "Xero items synchronization completed successfully.",
    }
