# Execution Evidence — EcoMarket Riwi S.A.S.

**Developer:** Leonela Miranda · **Clan:** Esthercitas  
**Environment:** PostgreSQL 17.5 (local), database `bd_leonela_miranda_esthercitas`  
**Tool:** `psql` (PostgreSQL 17) — all scripts executed from the project root  
**Date:** 2026-07-06

---

## 1. Create database (`sql/00_create_database.sql`)

```
DROP DATABASE
CREATE DATABASE

             Nombre             |   Due    | Codificaci
--------------------------------+----------+------------
 bd_leonela_miranda_esthercitas | postgres | UTF8
(1 fila)
```

## 2. DDL — schema (`sql/01_ddl.sql`)

```
CREATE TABLE  (×8)
CREATE INDEX  (×7)

                Listado de relaciones
 Esquema |         Nombre          | Tipo
---------+-------------------------+-------
 public  | eco_category            | tabla
 public  | eco_city                | tabla
 public  | eco_client              | tabla
 public  | eco_distribution_center | tabla
 public  | eco_inventory           | tabla
 public  | eco_order               | tabla
 public  | eco_order_detail        | tabla
 public  | eco_product             | tabla
(8 filas)
```

## 3. Data load via CSV + COPY (`sql/02_load_data.sql`)

```
TRUNCATE TABLE
COPY 9      -- cities
COPY 6      -- categories
COPY 9      -- clients
COPY 6      -- distribution_centers
COPY 10     -- products
COPY 20     -- orders
COPY 20     -- order_details
COPY 10     -- inventory

        entity        | count
----------------------+-------
 cities               |     9
 categories           |     6
 clients              |     9
 distribution_centers |     6
 products             |    10
 orders               |    20
 order_details        |    20
 inventory            |    10
(8 filas)
```

## 4. DML (`sql/03_dml.sql`)

```
INSERT 0 1   -- new client (MegaMarket) + order (data-modifying CTE)
UPDATE 1     -- distribution center renamed: South Hub → South Hub (Cali)
INSERT 0 1   -- orphan product created (Discontinued Snack)
DELETE 1     -- orphan product deleted (no orders)
```

## 5. Business queries (`sql/04_queries.sql`)

### Query 1 — Available inventory per product
```
      product_name      | total_stock
------------------------+-------------
 Rice 1kg               |         182
 Banana                 |         165
 Pasta                  |         127
 Tomato                 |         104
 Gala Apple             |          95
 Eggs x12               |          81
 Chicken Breast         |          60
 Whole Milk 1L          |          52
 Iceberg Lettuce        |          43
 Extra Virgin Olive Oil |          36
(10 filas)
```

### Query 2 — Order history by city
```
  city_name   | total_orders
--------------+--------------
 Bogotá       |            5
 Barranquilla |            2
 Bucaramanga  |            2
 Cali         |            2
 Cartagena    |            2
 Cúcuta       |            2
 Manizales    |            2
 Medellín     |            2
 Pereira      |            2
(9 filas)
```

### Query 3 — Total sold per category
```
 category_name | units_sold | total_revenue
---------------+------------+---------------
 Meat          |         35 |        227.50
 Dairy         |         43 |        172.60
 Grains        |         80 |        169.60
 Fruits        |         58 |         99.50
 Oils          |         10 |         89.00
 Vegetables    |         56 |         88.20
(6 filas)
```

### Query 4 — Products with the lowest inventory
```
      product_name      |   center_name    | stock
------------------------+------------------+-------
 Extra Virgin Olive Oil | East Hub         |    36
 Iceberg Lettuce        | North Center     |    43
 Whole Milk 1L          | South Hub (Cali) |    52
 Chicken Breast         | Coast DC         |    60
 Eggs x12               | Coffee DC        |    81
(5 filas)
```

### Query 5 — Clients with the most orders
```
 client_name | total_orders
-------------+--------------
 SuperMax    |            4
 EcoStore    |            2
 FoodPlus    |            2
 FreshMart   |            2
 GreenBuy    |            2
 MarketOne   |            2
 MiniShop    |            2
 QuickFood   |            2
 RetailCo    |            2
 MegaMarket  |            1
(10 filas)
```

### Query 6 — Inventory value per distribution center
```
   center_name    | inventory_value
------------------+-----------------
 Coast DC         |          754.00
 East Hub         |          612.50
 Coffee DC        |          527.40
 North Center     |          284.80
 West Center      |          198.00
 South Hub (Cali) |          197.60
(6 filas)
```

## 6. Extra points — analytical views (`sql/05_views.sql`)

```
CREATE VIEW
CREATE VIEW

                     Listado de relaciones
 Esquema |              Nombre              | Tipo
---------+----------------------------------+-------
 public  | eco_vw_client_commercial_profile | vista
 public  | eco_vw_sales_by_category         | vista
(2 filas)
```

### View 1 — `eco_vw_sales_by_category` (commercial analysis by category)
```
 category_id | category_name | orders_count | units_sold | total_revenue
-------------+---------------+--------------+------------+---------------
           3 | Meat          |            2 |         35 |        227.50
           2 | Dairy         |            4 |         43 |        172.60
           4 | Grains        |            4 |         80 |        169.60
           1 | Fruits        |            5 |         58 |         99.50
           5 | Oils          |            2 |         10 |         89.00
           6 | Vegetables    |            4 |         56 |         88.20
(6 filas)
```

### View 2 — `eco_vw_client_commercial_profile` (commercial profile per client)
```
 client_id | client_name | total_orders | total_units | total_spent
-----------+-------------+--------------+-------------+-------------
         1 | SuperMax    |            4 |          50 |      265.00
         6 | RetailCo    |            2 |          23 |       96.60
         4 | EcoStore    |            2 |          48 |       96.00
         5 | MarketOne   |            2 |          10 |       89.00
         3 | MiniShop    |            2 |          20 |       76.00
         9 | QuickFood   |            2 |          32 |       73.60
         7 | FoodPlus    |            2 |          38 |       68.40
         2 | FreshMart   |            2 |          35 |       42.00
        10 | MegaMarket  |            1 |           8 |       20.00
         8 | GreenBuy    |            2 |          18 |       19.80
(10 filas)
```

## 7. Extra points — stored function (`sql/06_stored_procedure.sql`)

```
CREATE FUNCTION

 Esquema |     Nombre      | Tipo de dato de salida
---------+-----------------+--------------------------------------------------
 public  | eco_get_clients | TABLE(client_id, client_name, total_orders, total_spent)
         |                 | p_client_id integer DEFAULT NULL
```

### `eco_get_clients(1)` — one client by ID
```
 client_id | client_name | total_orders | total_spent
-----------+-------------+--------------+-------------
         1 | SuperMax    |            4 |      265.00
(1 fila)
```

### `eco_get_clients(NULL)` — all clients
```
 client_id | client_name | total_orders | total_spent
-----------+-------------+--------------+-------------
         1 | SuperMax    |            4 |      265.00
         2 | FreshMart   |            2 |       42.00
         3 | MiniShop    |            2 |       76.00
         4 | EcoStore    |            2 |       96.00
         5 | MarketOne   |            2 |       89.00
         6 | RetailCo    |            2 |       96.60
         7 | FoodPlus    |            2 |       68.40
         8 | GreenBuy    |            2 |       19.80
         9 | QuickFood   |            2 |       73.60
        10 | MegaMarket  |            1 |       20.00
(10 filas)
```

## 8. Integrity constraints reject invalid operations

```
DELETE product with orders:
  ERROR: update or delete on table "eco_product" violates foreign key
         constraint "fk_eco_detail_product" on table "eco_order_detail"

Duplicate client name:
  ERROR: duplicate key value violates unique constraint "uq_eco_client_name"

Order with non-existing client:
  ERROR: insert or update on table "eco_order" violates foreign key
         constraint "fk_eco_order_client"

Negative stock:
  ERROR: new row for relation "eco_inventory" violates check constraint
         "chk_eco_inventory_stock"
```

## 9. Node.js console runner (raw SQL via `pg`, no ORM)

```
$ npm run setup
  Executed sql/01_ddl.sql
  Executed sql/02_load_data_inserts.sql
  Executed sql/05_views.sql
  Executed sql/06_stored_procedure.sql
  Setup complete — clients=9 products=10 orders=20 order_details=20 inventory=10

$ npm start
  Query 1–6, both views, eco_get_clients(1), eco_get_clients(NULL), DML insert
  "Created order D... for DemoClient_... (1 line) in Bogotá."
```

All results from the Node.js OOP layer match the `psql` outputs above, confirming
the model, the raw SQL scripts and the application are consistent.
