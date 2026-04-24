import requests
import logging
from utilities import goFetch as fetch

logger = logging.getLogger()
logger.setLevel(logging.INFO)

_XERO_CONNECTIONS_URL = "https://api.xero.com/connections"
_XERO_ITEMS_URL       = "https://api.xero.com/api.xro/2.0/Items"


def get_access_token() -> str:
    credentials = fetch.get_xero_credentials()
    access_token = credentials.get("accessToken", {}).get("access_token")
    if not access_token:
        raise ValueError("No access_token found in Xero secret.")
    return access_token


def get_xero_tenant_id(access_token: str) -> str:
    logger.info("Fetching Xero tenant ID from connections endpoint...")

    headers = {
        "Authorization": f"Bearer {access_token}",
        "Accept":        "application/json",
    }

    response = requests.get(_XERO_CONNECTIONS_URL, headers=headers)
    if response.status_code != 200:
        logger.error(f"Failed to fetch Xero connections. Status code: {response.status_code}, Response: {response.text}")
        raise ValueError("No Xero connections found for this access token.")
    connections = response.json()
    tenant_id = connections[0].get("tenantId")
    if not tenant_id:
        logger.error("No tenant ID found in Xero connections.")
        raise ValueError("No tenant ID found in Xero connections.")
    logger.info(f"Successfully retrieved Xero tenant ID: {tenant_id}")
    return tenant_id

def fetch_xero_items(access_token: str, tenant_id: str) -> dict:
    logger.info("Fetching items from Xero API...")
    headers = {
        "Authorization":  f"Bearer {access_token}",
        "Xero-tenant-id": tenant_id,
        "Accept":         "application/json",
    }
    response = requests.get(_XERO_ITEMS_URL, headers=headers)   
    
    if response.status_code != 200:
        logger.error(f"Failed to fetch Xero items. Status code: {response.status_code}, Response: {response.text}")
        raise ValueError("Failed to fetch Xero items.")
    logger.info("Successfully fetched items from Xero API.")
    return response.json()
