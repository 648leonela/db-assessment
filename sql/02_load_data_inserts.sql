-- ============================================================================
--  EcoMarket Riwi S.A.S. — Data load via pure INSERT  (FALLBACK strategy)
--  Use this when you cannot access the file system from psql (e.g. pgAdmin /
--  DBeaver query editor). Foreign keys are resolved by unique name lookups, so
--  it does not depend on any specific generated id order.
-- ============================================================================

TRUNCATE eco_inventory, eco_order_detail, eco_order,
         eco_product, eco_distribution_center, eco_client,
         eco_category, eco_city
    RESTART IDENTITY CASCADE;

-- Lookups -------------------------------------------------------------------
INSERT INTO eco_city (city_name) VALUES
    ('Bogotá'), ('Medellín'), ('Cali'), ('Barranquilla'), ('Cartagena'),
    ('Bucaramanga'), ('Pereira'), ('Manizales'), ('Cúcuta');

INSERT INTO eco_category (category_name) VALUES
    ('Fruits'), ('Dairy'), ('Meat'), ('Grains'), ('Oils'), ('Vegetables');

INSERT INTO eco_client (client_name) VALUES
    ('SuperMax'), ('FreshMart'), ('MiniShop'), ('EcoStore'), ('MarketOne'),
    ('RetailCo'), ('FoodPlus'), ('GreenBuy'), ('QuickFood');

INSERT INTO eco_distribution_center (center_name) VALUES
    ('North Center'), ('West Center'), ('South Hub'), ('Coast DC'),
    ('East Hub'), ('Coffee DC');

-- Products (category resolved by name) --------------------------------------
INSERT INTO eco_product (product_name, unit_price, category_id)
SELECT p.product_name, p.unit_price, c.category_id
FROM (VALUES
    ('Gala Apple',              2.50, 'Fruits'),
    ('Banana',                  1.20, 'Fruits'),
    ('Whole Milk 1L',           3.80, 'Dairy'),
    ('Chicken Breast',          6.50, 'Meat'),
    ('Rice 1kg',                2.00, 'Grains'),
    ('Extra Virgin Olive Oil',  8.90, 'Oils'),
    ('Eggs x12',                4.20, 'Dairy'),
    ('Tomato',                  1.80, 'Vegetables'),
    ('Iceberg Lettuce',         1.10, 'Vegetables'),
    ('Pasta',                   2.30, 'Grains')
) AS p(product_name, unit_price, category_name)
JOIN eco_category c ON c.category_name = p.category_name;

-- Orders (client / center / city resolved by name) --------------------------
INSERT INTO eco_order (order_code, order_date, client_id, center_id, city_id)
SELECT o.order_code, o.order_date::date, cl.client_id, dc.center_id, ci.city_id
FROM (VALUES
    ('O1001','2026-05-01','SuperMax','North Center','Bogotá'),
    ('O1002','2026-05-02','SuperMax','North Center','Bogotá'),
    ('O1003','2026-05-02','FreshMart','West Center','Medellín'),
    ('O1004','2026-05-03','FreshMart','West Center','Medellín'),
    ('O1005','2026-05-04','MiniShop','South Hub','Cali'),
    ('O1006','2026-05-05','MiniShop','South Hub','Cali'),
    ('O1007','2026-05-06','SuperMax','Coast DC','Barranquilla'),
    ('O1008','2026-05-07','SuperMax','Coast DC','Barranquilla'),
    ('O1009','2026-05-08','EcoStore','Coast DC','Cartagena'),
    ('O1010','2026-05-09','EcoStore','Coast DC','Cartagena'),
    ('O1011','2026-05-10','MarketOne','East Hub','Bucaramanga'),
    ('O1012','2026-05-11','MarketOne','East Hub','Bucaramanga'),
    ('O1013','2026-05-12','RetailCo','Coffee DC','Pereira'),
    ('O1014','2026-05-13','RetailCo','Coffee DC','Pereira'),
    ('O1015','2026-05-14','FoodPlus','Coffee DC','Manizales'),
    ('O1016','2026-05-15','FoodPlus','Coffee DC','Manizales'),
    ('O1017','2026-05-16','GreenBuy','North Center','Bogotá'),
    ('O1018','2026-05-17','GreenBuy','North Center','Bogotá'),
    ('O1019','2026-05-18','QuickFood','East Hub','Cúcuta'),
    ('O1020','2026-05-19','QuickFood','East Hub','Cúcuta')
) AS o(order_code, order_date, client_name, center_name, city_name)
JOIN eco_client cl              ON cl.client_name = o.client_name
JOIN eco_distribution_center dc ON dc.center_name = o.center_name
JOIN eco_city ci                ON ci.city_name   = o.city_name;

-- Order details (order + product resolved by name) --------------------------
INSERT INTO eco_order_detail (order_id, product_id, quantity)
SELECT ord.order_id, pr.product_id, d.quantity
FROM (VALUES
    ('O1001','Gala Apple',10), ('O1002','Gala Apple',5),
    ('O1003','Banana',20),     ('O1004','Banana',15),
    ('O1005','Whole Milk 1L',12), ('O1006','Whole Milk 1L',8),
    ('O1007','Chicken Breast',25),('O1008','Chicken Breast',10),
    ('O1009','Rice 1kg',30),   ('O1010','Rice 1kg',18),
    ('O1011','Extra Virgin Olive Oil',6), ('O1012','Extra Virgin Olive Oil',4),
    ('O1013','Eggs x12',14),   ('O1014','Eggs x12',9),
    ('O1015','Tomato',22),     ('O1016','Tomato',16),
    ('O1017','Iceberg Lettuce',11), ('O1018','Iceberg Lettuce',7),
    ('O1019','Pasta',19),      ('O1020','Pasta',13)
) AS d(order_code, product_name, quantity)
JOIN eco_order ord   ON ord.order_code   = d.order_code
JOIN eco_product pr  ON pr.product_name  = d.product_name;

-- Inventory (product + center resolved by name) -----------------------------
INSERT INTO eco_inventory (product_id, center_id, stock)
SELECT pr.product_id, dc.center_id, i.stock
FROM (VALUES
    ('Gala Apple','North Center',95),
    ('Banana','West Center',165),
    ('Whole Milk 1L','South Hub',52),
    ('Chicken Breast','Coast DC',60),
    ('Rice 1kg','Coast DC',182),
    ('Extra Virgin Olive Oil','East Hub',36),
    ('Eggs x12','Coffee DC',81),
    ('Tomato','Coffee DC',104),
    ('Iceberg Lettuce','North Center',43),
    ('Pasta','East Hub',127)
) AS i(product_name, center_name, stock)
JOIN eco_product pr             ON pr.product_name = i.product_name
JOIN eco_distribution_center dc ON dc.center_name  = i.center_name;
