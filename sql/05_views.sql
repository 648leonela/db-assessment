-- ============================================================================
--  EcoMarket Riwi S.A.S. — Analytical VIEWS (extra points)
--  Two commercial-analysis oriented views.
-- ============================================================================

-- ---------------------------------------------------------------------------
-- View 1 — Sales performance by category
-- Consolidates units sold, revenue and number of orders per category so the
-- commercial team can rank category performance in a single read.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE VIEW eco_vw_sales_by_category AS
SELECT cat.category_id,
       cat.category_name,
       COUNT(DISTINCT d.order_id)     AS orders_count,
       SUM(d.quantity)                AS units_sold,
       SUM(d.quantity * p.unit_price) AS total_revenue
FROM   eco_category cat
JOIN   eco_product      p ON p.category_id = cat.category_id
JOIN   eco_order_detail d ON d.product_id  = p.product_id
GROUP  BY cat.category_id, cat.category_name;

-- ---------------------------------------------------------------------------
-- View 2 — Commercial profile per client
-- Number of orders, total units and total spend per client, ordered by value,
-- to support account prioritization and loyalty actions.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE VIEW eco_vw_client_commercial_profile AS
SELECT cl.client_id,
       cl.client_name,
       COUNT(DISTINCT o.order_id)     AS total_orders,
       COALESCE(SUM(d.quantity), 0)   AS total_units,
       COALESCE(SUM(d.quantity * p.unit_price), 0) AS total_spent
FROM   eco_client cl
LEFT   JOIN eco_order        o ON o.client_id  = cl.client_id
LEFT   JOIN eco_order_detail d ON d.order_id   = o.order_id
LEFT   JOIN eco_product      p ON p.product_id = d.product_id
GROUP  BY cl.client_id, cl.client_name;

-- Usage examples:
--   SELECT * FROM eco_vw_sales_by_category ORDER BY total_revenue DESC;
--   SELECT * FROM eco_vw_client_commercial_profile ORDER BY total_spent DESC;
