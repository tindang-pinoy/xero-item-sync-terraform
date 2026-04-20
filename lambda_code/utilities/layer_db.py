from __future__ import annotations
from psycopg.rows import dict_row
from typing import Any
from uuid import UUID
from utilities.layer_sql import UPSERT_INVENTORY_ITEM_SQL, UPSERT_PURCHASE_DETAILS_SQL, UPSERT_SALES_DETAILS_SQL
from utilities import goFetch as fetch

import os
import psycopg as psy
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

DB_HOST = os.getenv("DB_HOST")
DB_PORT = int(os.getenv("DB_PORT", 5432))
DB_NAME = os.getenv("DB_NAME")
DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")

EXCLUDED_ITEM_UUIDS = {
    UUID("4b3ef966-b4a5-4e0d-9315-a911c59057b5")
}

def init_connection():
    logger.info("Initializing connection to RDS database...")
    return psy.connect(
        host=DB_HOST,
        port=DB_PORT,
        dbname=DB_NAME,
        user=DB_USER,
        password=DB_PASSWORD,
        row_factory=dict_row
    )

def upsert_xero_items(xero_response: dict[str, Any]) -> dict[str, int]:
    items = fetch.extract_xero_items(xero_response)
    if not items:
        logger.info("No items found in Xero response. Skipping upsert.")
        return {"items": 0, "purchase_details": 0, "sales_details": 0}

    inv_rows = []
    purchase_rows = []
    sales_rows = []

    for item in items:
        item_id = UUID(item["ItemID"])
        if item_id in EXCLUDED_ITEM_UUIDS:
            logger.info(f"Skipping excluded item: {item_id}")
            continue

        inv, purchase, sales = fetch.map_items(item)

        inv_rows.append(inv.__dict__)
        if purchase is not None:
            purchase_rows.append(purchase.__dict__)
        if sales is not None:
            sales_rows.append(sales.__dict__)

    with init_connection() as conn:
        with conn.transaction():
            with conn.cursor() as cur:
                cur.executemany(UPSERT_INVENTORY_ITEM_SQL, inv_rows)
                if purchase_rows:
                    cur.executemany(UPSERT_PURCHASE_DETAILS_SQL, purchase_rows)
                if sales_rows:
                    cur.executemany(UPSERT_SALES_DETAILS_SQL, sales_rows)

    logger.info(f"Upserted {len(inv_rows)} items, {len(purchase_rows)} purchase details, {len(sales_rows)} sales details.")
    return {
        "items": len(inv_rows),
        "purchase_details": len(purchase_rows),
        "sales_details": len(sales_rows),
    }
