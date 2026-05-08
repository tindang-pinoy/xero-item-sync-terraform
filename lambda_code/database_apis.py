from fastapi import FastAPI, HTTPException
from mangum import Mangum

from utilities import layer_db as db
from utilities.layer_sql import (
    SELECT_ALL_ITEMS_SQL,
    SELECT_ITEM_BY_ID_SQL,
    SELECT_PURCHASE_DETAILS_SQL,
    SELECT_SALES_DETAILS_SQL,
)

import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

app = FastAPI(title="Tindang Pinoy — Inventory API")


@app.get("/health")
def health():
    return {"status": "ok"}


@app.get("/items")
def list_items():
    with db.init_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(SELECT_ALL_ITEMS_SQL)
            items = cur.fetchall()
    return {"size": len(items), "items": items}

@app.get("/items/{item_id}")
def get_item(item_id: str):
    with db.init_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(SELECT_ITEM_BY_ID_SQL, {"item_id": item_id})
            item = cur.fetchone()
            if item is None:
                raise HTTPException(status_code=404, detail="Item not found")

            cur.execute(SELECT_PURCHASE_DETAILS_SQL, {"item_id": item_id})
            purchase = cur.fetchone()

            cur.execute(SELECT_SALES_DETAILS_SQL, {"item_id": item_id})
            sales = cur.fetchone()

    return {
        "item": item,
        "purchase_details": purchase,
        "sales_details": sales,
    }


handler = Mangum(app)
