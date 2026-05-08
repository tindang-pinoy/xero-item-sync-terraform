SELECT_ALL_ITEMS_SQL = """
SELECT 
* 
FROM inventory_item
where substring(xero_name, 1, 1) not in ('z')
ORDER BY xero_name DESC
;
"""

SELECT_ITEM_BY_ID_SQL = """
SELECT * FROM inventory_item
WHERE item_id = %(item_id)s
;
"""

SELECT_PURCHASE_DETAILS_SQL = """
SELECT * FROM inventory_item_purchase_details
WHERE item_id = %(item_id)s
;
"""

SELECT_SALES_DETAILS_SQL = """
SELECT * FROM inventory_item_sales_details
WHERE item_id = %(item_id)s
;
"""

UPSERT_INVENTORY_ITEM_SQL = """
INSERT INTO inventory_item (
    item_id,
    id,
    code,
    xero_name,
    description,
    purchase_description,
    updated_at_utc,
    updated_at_nzt,
    is_tracked_as_inventory,
    inventory_asset_account_code,
    total_cost_pool,
    quantity_on_hand,
    is_sold,
    is_purchased
) VALUES (
    %(item_id)s,
    %(id)s,
    %(code)s,
    %(xero_name)s,
    %(description)s,
    %(purchase_description)s,
    %(updated_at_utc)s,
    %(updated_at_nzt)s,
    %(is_tracked_as_inventory)s,
    %(inventory_asset_account_code)s,
    %(total_cost_pool)s,
    %(quantity_on_hand)s,
    %(is_sold)s,
    %(is_purchased)s
)
ON CONFLICT (item_id) DO UPDATE SET
    code = EXCLUDED.code,
    xero_name = EXCLUDED.xero_name,
    description = EXCLUDED.description,
    purchase_description = EXCLUDED.purchase_description,
    updated_at_utc = EXCLUDED.updated_at_utc,
    updated_at_nzt = EXCLUDED.updated_at_nzt,
    is_tracked_as_inventory = EXCLUDED.is_tracked_as_inventory,
    inventory_asset_account_code = EXCLUDED.inventory_asset_account_code,
    total_cost_pool = EXCLUDED.total_cost_pool,
    quantity_on_hand = EXCLUDED.quantity_on_hand,
    is_sold = EXCLUDED.is_sold,
    is_purchased = EXCLUDED.is_purchased
;
"""

UPSERT_PURCHASE_DETAILS_SQL = """
INSERT INTO inventory_item_purchase_details (
    item_id,
    id,
    unit_price,
    cogs_account_code,
    tax_type
) VALUES (
    %(item_id)s,
    %(id)s,
    %(unit_price)s,
    %(cogs_account_code)s,
    %(tax_type)s
)
ON CONFLICT (item_id) DO UPDATE SET
    unit_price = EXCLUDED.unit_price,
    cogs_account_code = EXCLUDED.cogs_account_code,
    tax_type = EXCLUDED.tax_type
;
"""

UPSERT_SALES_DETAILS_SQL = """
INSERT INTO inventory_item_sales_details (
    item_id,
    id,
    unit_price,
    account_code,
    tax_type
) VALUES (
    %(item_id)s,
    %(id)s,
    %(unit_price)s,
    %(account_code)s,
    %(tax_type)s
)
ON CONFLICT (item_id) DO UPDATE SET
    unit_price = EXCLUDED.unit_price,
    account_code = EXCLUDED.account_code,
    tax_type = EXCLUDED.tax_type
;
"""