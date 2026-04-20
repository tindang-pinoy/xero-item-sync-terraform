import requests
import logging
from utilities import goFetch as fetch

logger = logging.getLogger()
logger.setLevel(logging.INFO)

_XERO_TOKEN_URL = "https://identity.xero.com/connect/token"
_XERO_ITEMS_URL = "https://api.xero.com/api.xro/2.0/Items"

def fetch_xero_items() -> dict:
    credentials = fetch.get_xero_credentials()

    logger.info("Refreshing Xero access token...")
    token_response = requests.post(_XERO_TOKEN_URL, data={
        "grant_type":    "refresh_token",
        "refresh_token": credentials["refresh_token"],
        "client_id":     credentials["client_id"],
        "client_secret": credentials["client_secret"],
    })
    token_response.raise_for_status()
    access_token = token_response.json()["access_token"]

    logger.info("Fetching items from Xero API...")
    items_response = requests.get(_XERO_ITEMS_URL, headers={
        "Authorization":  f"Bearer {access_token}",
        "Xero-tenant-id": credentials["tenant_id"],
        "Accept":         "application/json",
    })
    items_response.raise_for_status()

    logger.info("Successfully fetched items from Xero API.")
    return items_response.json()
