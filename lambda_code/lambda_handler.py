from utilities import goFetch as fetch
from utilities import layer_api as api
from utilities import layer_db as db
import logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def sync_xero_items():
    logger.info(f"Starting Xero items synchronization...")
    xero_response = api.fetch_xero_items()
    result = db.upsert_xero_items(xero_response)
    logger.info(f"Sync completed successfully.")
    logger.info(f"{result}")

def lambda_handler(event, context):
    sync_xero_items()
    return {
        "statusCode": 200,
        "body": "Xero items synchronization completed successfully."
    }