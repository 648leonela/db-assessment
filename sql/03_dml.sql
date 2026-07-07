-- ============================================================================
--  EcoMarket Riwi S.A.S. — DML (data manipulation)
--  Insert / Update / Delete demonstrating referential integrity.
-- ============================================================================

-- ---------------------------------------------------------------------------
-- 1) INSERT — Register a NEW CLIENT together with an associated ORDER.
--    Done atomically with data-modifying CTEs: the client, the order and its
--    detail are created in a single statement.
-- ---------------------------------------------------------------------------
WITH new_client AS (
    INSERT INTO eco_client (client_name)
    VALUES ('MegaMarket')
    RETURNING client_id
),
new_order AS (
    INSERT INTO eco_order (order_code, order_date, client_id, center_id, city_id)
    SELECT 'O2001',
           CURRENT_DATE,
           nc.client_id,
           (SELECT center_id FROM eco_distribution_center WHERE center_name = 'North Center'),
           (SELECT city_id   FROM eco_city                WHERE city_name   = 'Bogotá')
    FROM new_client nc
    RETURNING order_id
)
INSERT INTO eco_order_detail (order_id, product_id, quantity)
SELECT no.order_id,
       (SELECT product_id FROM eco_product WHERE product_name = 'Gala Apple'),
       8
FROM new_order no;

-- ---------------------------------------------------------------------------
-- 2) UPDATE — Modify the information of a distribution center.
-- ---------------------------------------------------------------------------
UPDATE eco_distribution_center
SET    center_name = 'South Hub (Cali)'
WHERE  center_name = 'South Hub';

-- ---------------------------------------------------------------------------
-- 3) DELETE — Remove a product that has NO associated orders.
--    We first create an orphan product, then delete it only if no order line
--    references it. Its inventory rows (if any) are removed by ON DELETE CASCADE.
-- ---------------------------------------------------------------------------
INSERT INTO eco_product (product_name, unit_price, category_id)
SELECT 'Discontinued Snack', 1.50, category_id
FROM   eco_category
WHERE  category_name = 'Grains';

DELETE FROM eco_product p
WHERE  p.product_name = 'Discontinued Snack'
  AND  NOT EXISTS (
        SELECT 1 FROM eco_order_detail d WHERE d.product_id = p.product_id
  );

-- ---------------------------------------------------------------------------
-- Integrity checks — the following statements MUST FAIL (kept commented).
-- They prove the constraints block invalid operations.
-- ---------------------------------------------------------------------------

-- (a) Deleting a product WITH orders is blocked by FK ON DELETE RESTRICT:
-- DELETE FROM eco_product WHERE product_name = 'Gala Apple';
--   ERROR: update or delete on table "eco_product" violates foreign key
--          constraint "fk_eco_detail_product" on table "eco_order_detail"

-- (b) Inserting an order for a non-existing client is blocked by FK:
-- INSERT INTO eco_order (order_code, order_date, client_id, center_id, city_id)
-- VALUES ('O9999', CURRENT_DATE, 99999, 1, 1);
--   ERROR: insert or update on table "eco_order" violates foreign key
--          constraint "fk_eco_order_client"

-- (c) Duplicate client name is blocked by UNIQUE:
-- INSERT INTO eco_client (client_name) VALUES ('SuperMax');
--   ERROR: duplicate key value violates unique constraint "uq_eco_client_name"

-- (d) Negative stock is blocked by CHECK:
-- UPDATE eco_inventory SET stock = -5 WHERE inventory_id = 1;
--   ERROR: new row for relation "eco_inventory" violates check constraint
--          "chk_eco_inventory_stock"
