from __future__ import annotations
from dataclasses import dataclass
from datetime import datetime, timezone
from decimal import Decimal
from typing import Any, Iterable, Optional
from uuid import UUID

import boto3
import json
import os
import re
import logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

xero_secrets: dict = {}

@dataclass(frozen=True)
class InventoryItemRow:
    '''
    Dataclass representing a row in the inventory_items table
    '''
    item_id: UUID
    code: str
    name: str
    description: Optional[str]
    purchase_description: Optional[str]
    updated_at_utc: datetime
    is_tracked_as_inventory: bool
    inventory_asset_account_code: Optional[str]
    total_cost_pool: Decimal
    quantity_on_hand: Decimal
    is_sold: bool
    is_purchased: bool

@dataclass(frozen=True)
class PurchaseDetailsRow:
    '''
    Dataclass representing a row in the inventory_item_purchase_details table
    '''
    item_id: UUID
    unit_price: Decimal
    cogs_account_code: str
    tax_type: str

@dataclass(frozen=True)
class SalesDetailsRow:
    '''
    Dataclass representing a row in the inventory_item_sales_details table
    '''
    item_id: UUID
    unit_price: Decimal
    income_account_code: str
    tax_type: str

def say_hello():
    logger.info("Hello from goFetch!")
    print("Hello from goFetch!")

def init_secrets_manager_boto_client():
    '''
    Initializes the Boto3 client for AWS Secrets Manager
    '''
    service = "secretsmanager"
    region = "ap-southeast-2"
    session = boto3.session.Session().client(service_name = service, region_name = region)
    logger.info("Initialized Boto3 client for AWS Secrets Manager.")
    return session

def retrieve_secret(secret_name: str) -> dict:
    '''
    Retrieves the secret value from AWS Secrets Manager and returns it as a dictionary
    '''
    client = init_secrets_manager_boto_client()
    try:
        secret_value = client.get_secret_value(SecretId=secret_name)
        if "SecretString" in secret_value:
            secret_string = secret_value['SecretString']
            secret_dict = json.loads(secret_string)
        else:
            logger.error(f"Secret {secret_name} does not contain a SecretString.")
            raise ValueError(f"Secret {secret_name} does not contain a SecretString.")
        logger.info(f"Successfully retrieved secret: {secret_name}")
        return secret_dict
    except Exception as e:
        logger.error(f"Error retrieving secret {secret_name}: {str(e)}")
        raise e
    
def get_xero_credentials():
    '''
    Retrieves the Xero API credentials from AWS Secrets Manager and stores them in the global xero_secrets variable
    '''
    global xero_secrets
    if not xero_secrets:
        secret_name = os.getenv("XERO_SECRET_NAME")
        xero_secrets = retrieve_secret(secret_name)
    return xero_secrets

def extract_xero_items(xero_response: dict[str, Any]) -> list[dict[str, Any]]:
    '''
    Extracts the list of items from the Xero API response

    Args:
        xero_response (dict[str, Any]): The raw response from the Xero API as a dictionary
    Returns:
        list[dict[str, Any]]: A list of item dictionaries extracted from the Xero API response
    '''
    logger.info("Extracting items from Xero response...")
    items = xero_response.get("Items", [])
    logger.info(f"Extracted {len(items)} items from Xero response.")
    if items is None:
        logger.warning("No items found in Xero response.")
        return []
    if not isinstance(items, list):
        logger.error("Invalid format for items in Xero response. Expected a list.")
        raise ValueError("Invalid format for items in Xero response. Expected a list.")
    return items

_XERO_DATE_RE = re.compile(r"/Date\((?P<ms>-?\d+)(?P<offset>[+-]\d{4})?\)/")
def parse_xero_date(xero_date: str) -> datetime:
    '''
    Parses a date string from Xero API response and returns a datetime object
    '''
    match = _XERO_DATE_RE.fullmatch(xero_date)
    if not match:
        raise ValueError(f"Invalid Xero date format: {xero_date}")
    ms = int(match.group("ms"))
    return datetime.fromtimestamp(ms / 1000.0, tz=timezone.utc)

def decimal(value: Any) -> Optional[Decimal]:
    '''
    Convert a value to a deciaml, handling NOne and empty strings
    '''
    if value is None or (isinstance(value, str) and value.strip() == ""):
        return None
    try:
        return Decimal(value)
    except Exception as e:
        logger.error(f"Error converting value to Decimal: {value} - {str(e)}")
        raise ValueError(f"Error converting value to Decimal: {value}") from e
    
def map_items(item: dict[str, Any]) -> tuple[InventoryItemRow, Optional[PurchaseDetailsRow], Optional[SalesDetailsRow]]:
    '''
    Maps a single item dictionary from Xero API response to the corresponding dataclass instances for inventory_items, inventory_item_purchase_details, and inventory_item_sales_details tables
    '''
    item_id = UUID(item["ItemID"])

    inv = InventoryItemRow(
        item_id=item_id,
        code=item["Code"],
        name=item["Name"],
        description=item.get("Description"),
        purchase_description=item.get("PurchaseDescription"),
        updated_at_utc=parse_xero_date(item["UpdatedDateUTC"]),
        is_tracked_as_inventory=item["IsTrackedAsInventory"],
        inventory_asset_account_code=item.get("InventoryAssetAccountCode"),
        total_cost_pool=decimal(item["TotalCostPool"]),
        quantity_on_hand=decimal(item["QuantityOnHand"]),
        is_sold=item["IsSold"],
        is_purchased=item["IsPurchased"]
    )

    pd = item.get("PurchaseDetails") or None
    purchase = None
    if isinstance(pd, dict):
        # Only create a purchase row if it has the expected fields
        if pd.get("UnitPrice") is not None and pd.get("COGSAccountCode") is not None and pd.get("TaxType") is not None:
            purchase = PurchaseDetailsRow(
                item_id=item_id,
                unit_price=decimal(pd.get("UnitPrice") or 0),
                cogs_account_code=str(pd.get("COGSAccountCode") or "").strip(),
                tax_type=str(pd.get("TaxType") or "").strip()
            )
    sd = item.get("SalesDetails") or None
    sales = None
    if isinstance(sd, dict):
        # Only create a sales row if it has the expected fields
        if sd.get("UnitPrice") is not None and sd.get("IncomeAccountCode") is not None and sd.get("TaxType") is not None:
            sales = SalesDetailsRow(
                item_id = item_id,
                unit_price = decimal(sd.get("UnitPrice") or 0),
                income_account_code = str(sd.get("IncomeAccountCode") or "").strip(),
                tax_type = str(sd.get("TaxType") or "").strip()
            )

    if not inv.code:
        raise ValueError(f"Item {item_id} is missing required field 'Code'")
    if not inv.name:
        raise ValueError(f"Item {item_id} is missing required field 'Name'")
    
    return inv, purchase, sales
