-- ============================================================================
--  EcoMarket Riwi S.A.S. — Business queries
--  Each query answers a real business need stated in the assessment.
-- ============================================================================

-- ---------------------------------------------------------------------------
-- Query 1 — Available inventory per product
-- Need: "As head of supply I need to know current stock to plan new purchases."
-- ---------------------------------------------------------------------------
SELECT p.product_name,
       SUM(i.stock) AS total_stock
FROM   eco_product p
JOIN   eco_inventory i ON i.product_id = p.product_id
GROUP  BY p.product_name
ORDER  BY total_stock DESC;

-- ---------------------------------------------------------------------------
-- Query 2 — Order history by city
-- Need: "As commercial director I need to know which cities generate the most orders."
-- ---------------------------------------------------------------------------
SELECT c.city_name,
       COUNT(o.order_id) AS total_orders
FROM   eco_city c
JOIN   eco_order o ON o.city_id = c.city_id
GROUP  BY c.city_name
ORDER  BY total_orders DESC, c.city_name;

-- ---------------------------------------------------------------------------
-- Query 3 — Total sold per category
-- Need: "As financial manager I need to identify which categories generate the most revenue."
-- ---------------------------------------------------------------------------
SELECT cat.category_name,
       SUM(d.quantity)                  AS units_sold,
       SUM(d.quantity * p.unit_price)   AS total_revenue
FROM   eco_order_detail d
JOIN   eco_product  p   ON p.product_id  = d.product_id
JOIN   eco_category cat ON cat.category_id = p.category_id
GROUP  BY cat.category_name
ORDER  BY total_revenue DESC;

-- ---------------------------------------------------------------------------
-- Query 4 — Products with the lowest inventory
-- Need: "As logistics coordinator I need to know which products are about to run out."
-- ---------------------------------------------------------------------------
SELECT p.product_name,
       dc.center_name,
       i.stock
FROM   eco_inventory i
JOIN   eco_product p             ON p.product_id = i.product_id
JOIN   eco_distribution_center dc ON dc.center_id = i.center_id
ORDER  BY i.stock ASC
LIMIT  5;

-- ---------------------------------------------------------------------------
-- Query 5 — Clients with the most orders
-- Need: "As commercial director I need to identify the most active clients."
-- ---------------------------------------------------------------------------
SELECT cl.client_name,
       COUNT(o.order_id) AS total_orders
FROM   eco_client cl
JOIN   eco_order o ON o.client_id = cl.client_id
GROUP  BY cl.client_name
ORDER  BY total_orders DESC, cl.client_name;

-- ---------------------------------------------------------------------------
-- Query 6 — Economic value of inventory per distribution center
-- Need: "As general manager I need to know the value of the inventory stored in each center."
-- ---------------------------------------------------------------------------
SELECT dc.center_name,
       SUM(i.stock * p.unit_price) AS inventory_value
FROM   eco_inventory i
JOIN   eco_product p              ON p.product_id = i.product_id
JOIN   eco_distribution_center dc ON dc.center_id = i.center_id
GROUP  BY dc.center_name
ORDER  BY inventory_value DESC;
