import logging

from utilities import layer_db as db

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def lambda_handler(event, context):
    """
    Lambda 2 — DB Writer.
    Invoked synchronously by the fetcher Lambda with the raw
    Xero API response as the event payload.
    Runs inside the VPC with the Lambda SG attached so it can
    reach RDS on port 5432 via the SG-to-SG rule.
    Uses RDS IAM authentication — no password required.
    """
    logger.info("DB writer: received Xero payload, starting upsert...")

    result = db.upsert_xero_items(event)

    logger.info(f"DB writer: upsert complete — {result}")
    return {
        "statusCode": 200,
        "body": result,
    }