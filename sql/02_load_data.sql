-- ============================================================================
--  EcoMarket Riwi S.A.S. — Data load via CSV + COPY  (PRIMARY strategy)
--  Engine: PostgreSQL 14+
--
--  Run with psql FROM THE PROJECT ROOT so the relative CSV paths resolve:
--     psql -d bd_leonela_miranda_esthercitas -f sql/02_load_data.sql
--
--  `\copy` is a psql client-side command: it reads the file on the machine
--  running psql (no server-side file permissions needed).
--
--  The CSVs hold the already-normalized/deduplicated data derived from the
--  dirty Excel (see docs/normalization.md). Identity ids are generated in file
--  order, which is why the numeric foreign keys in the transactional CSVs line
--  up with the lookup tables.
-- ============================================================================

-- Clean reload (safe to run multiple times).
TRUNCATE eco_inventory, eco_order_detail, eco_order,
         eco_product, eco_distribution_center, eco_client,
         eco_category, eco_city
    RESTART IDENTITY CASCADE;

\copy eco_city (city_name)                                   FROM 'data/csv/cities.csv'               WITH (FORMAT csv, HEADER true)
\copy eco_category (category_name)                           FROM 'data/csv/categories.csv'           WITH (FORMAT csv, HEADER true)
\copy eco_client (client_name)                               FROM 'data/csv/clients.csv'              WITH (FORMAT csv, HEADER true)
\copy eco_distribution_center (center_name)                  FROM 'data/csv/distribution_centers.csv' WITH (FORMAT csv, HEADER true)
\copy eco_product (product_name, unit_price, category_id)    FROM 'data/csv/products.csv'             WITH (FORMAT csv, HEADER true)
\copy eco_order (order_code, order_date, client_id, center_id, city_id) FROM 'data/csv/orders.csv'    WITH (FORMAT csv, HEADER true)
\copy eco_order_detail (order_id, product_id, quantity)      FROM 'data/csv/order_details.csv'        WITH (FORMAT csv, HEADER true)
\copy eco_inventory (product_id, center_id, stock)           FROM 'data/csv/inventory.csv'            WITH (FORMAT csv, HEADER true)

-- Quick verification.
SELECT 'cities'    AS entity, COUNT(*) FROM eco_city
UNION ALL SELECT 'categories',            COUNT(*) FROM eco_category
UNION ALL SELECT 'clients',               COUNT(*) FROM eco_client
UNION ALL SELECT 'distribution_centers',  COUNT(*) FROM eco_distribution_center
UNION ALL SELECT 'products',              COUNT(*) FROM eco_product
UNION ALL SELECT 'orders',                COUNT(*) FROM eco_order
UNION ALL SELECT 'order_details',         COUNT(*) FROM eco_order_detail
UNION ALL SELECT 'inventory',             COUNT(*) FROM eco_inventory;
