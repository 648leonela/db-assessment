# Normalization Process — EcoMarket Riwi S.A.S.

> Full analytical trace from the raw Excel file to a relational model in Third
> Normal Form (3NF). Every design decision is justified.

---

## 1. Initial state (source data)

The company operated everything from a single Excel sheet
(`Dataset_EcoMarketRiwi_Jornada_Tarde.xlsx`, sheet `Dataset_EcoMarketFresh`).
It is a **flat, denormalized table** with one row per order line and the
following columns:

| ClientName | City | Product | Category | DistributionCenter | OrderID | OrderDate | Quantity | UnitPrice | Stock |
|------------|------|---------|----------|--------------------|---------|-----------|----------|-----------|-------|

It contains 20 data rows. A representative extract:

```
SuperMax   | Bogotá       | Apple Gala             | Fruits     | Center North | O1001 | 2026-05-01 | 10 | 2.5 | 100
super max  | Bogota       | Gala Apple             | Fruit      | North Center | O1002 | 2026-05-02 |  5 | 2.5 |  95
FreshMart  | Medellín     | Banana                 | Fruits     | Center West  | O1003 | 2026-05-02 | 20 | 1.2 | 180
Fresh Mart | Medellin     | Bananas                | Fruit      | West Center  | O1004 | 2026-05-03 | 15 | 1.2 | 165
...
SuperMax   | Barranquilla | Chicken Breast         | Meat       | Coast DC     | O1007 | 2026-05-06 | 25 | 6.5 |  70
SuperMax   | Barranquila  | Chicken                | Meats      | Coastal DC   | O1008 | 2026-05-07 | 10 | 6.5 |  60
```

This is **Unnormalized Form (UNF / 0NF)**: there is no primary key, no
referential integrity, and the same real-world entity is written in many
different ways.

---

## 2. Problems found

### 2.1 Redundancy
- `ClientName`, `City`, `Product`, `Category`, `DistributionCenter` and
  `UnitPrice` are **repeated on every single row**. The unit price of a product
  (e.g. `2.5` for the apple) is copied over and over.
- The same client, product, category and distribution center are stored dozens
  of times instead of once.

### 2.2 Inconsistencies (the same entity written differently)

| Concept | Variants found in the file | Canonical value chosen |
|---------|-----------------------------|------------------------|
| Client `SuperMax` | `SuperMax`, `super max`, `SuperMax ` (trailing space) | **SuperMax** |
| Client `FreshMart` | `FreshMart`, `Fresh Mart` | **FreshMart** |
| Client `MiniShop` | `MiniShop`, `Mini Shop` | **MiniShop** |
| Client `EcoStore` | `EcoStore`, `Eco Store` | **EcoStore** |
| Client `MarketOne` | `MarketOne`, `Market One` | **MarketOne** |
| Client `RetailCo` | `RetailCo`, `Retail Co` | **RetailCo** |
| Client `FoodPlus` | `FoodPlus`, `Food Plus` | **FoodPlus** |
| Client `GreenBuy` | `GreenBuy`, `Green Buy` | **GreenBuy** |
| Client `QuickFood` | `QuickFood`, `Quick Food` | **QuickFood** |
| City Bogotá | `Bogotá`, `Bogota` | **Bogotá** |
| City Medellín | `Medellín`, `Medellin` | **Medellín** |
| City Cali | `Cali`, `CALI` | **Cali** |
| City Barranquilla | `Barranquilla`, `Barranquila` | **Barranquilla** |
| City Cartagena | `Cartagena`, `Cartagena ` | **Cartagena** |
| City Bucaramanga | `Bucaramanga`, `B/manga` | **Bucaramanga** |
| City Pereira | `Pereira`, `Pereria` | **Pereira** |
| City Manizales | `Manizales`, `Manizalez` | **Manizales** |
| City Cúcuta | `Cúcuta`, `Cucuta` | **Cúcuta** |
| Category Fruits | `Fruits`, `Fruit` | **Fruits** |
| Category Meat | `Meat`, `Meats` | **Meat** |
| Category Grains | `Grains`, `Grain` | **Grains** |
| Category Oils | `Oils`, `Oil` | **Oils** |
| Category Vegetables | `Vegetables`, `Vegetable` | **Vegetables** |
| Center North | `Center North`, `North Center` | **North Center** |
| Center West | `Center West`, `West Center` | **West Center** |
| Center South | `South Hub`, `Hub South` | **South Hub** |
| Center Coast | `Coast DC`, `Coastal DC` | **Coast DC** |
| Center East | `East Hub`, `Hub East` | **East Hub** |
| Center Coffee | `Coffee DC`, `Coffee Center` | **Coffee DC** |
| Product Apple | `Apple Gala`, `Gala Apple` | **Gala Apple** |
| Product Banana | `Banana`, `Bananas` | **Banana** |
| Product Milk | `Whole Milk`, `Milk 1L` | **Whole Milk 1L** |
| Product Chicken | `Chicken Breast`, `Chicken` | **Chicken Breast** |
| Product Rice | `Rice 1kg`, `Rice` | **Rice 1kg** |
| Product Oil | `Olive Oil`, `Extra Virgin Olive Oil` | **Extra Virgin Olive Oil** |
| Product Eggs | `Eggs x12`, `Dozen Eggs` | **Eggs x12** |
| Product Tomato | `Tomato`, `Tomatoes` | **Tomato** |
| Product Lettuce | `Lettuce`, `Iceberg Lettuce` | **Iceberg Lettuce** |
| Product Pasta | `Pasta`, `Spaghetti` | **Pasta** |

### 2.3 Missing integrity
- No primary keys, no foreign keys.
- Nothing prevents inserting an order for a non-existing client or product.
- Impossible to know the *real* inventory: `Stock` mixes different snapshots of
  the same product/center.

### 2.4 Ambiguity in `City`
The client **SuperMax** appears in **two different cities** (`Bogotá` for orders
O1001/O1002 and `Barranquilla` for O1007/O1008). This is decisive:
**`City` cannot be an attribute of the client**, because one client transacts in
several cities. `City` is therefore modeled as an attribute of the **order**
(the market/delivery city of that transaction). The same logic rules out putting
the city on the distribution center: `Coffee DC` serves both Pereira and
Manizales, and `Coast DC` serves Barranquilla and Cartagena.

---

## 3. Normalization

### 3.1 First Normal Form (1NF)
**Rule:** atomic values, no repeating groups, a primary key that uniquely
identifies each row.

- All cells already hold atomic values (no lists inside a cell).
- We trim whitespace and unify casing so that `super max` and `SuperMax ` become
  the single value `SuperMax`.
- We establish `OrderID` + `Product` as the natural key of a line (later
  replaced by surrogate keys).

Result — a single relation in 1NF (still redundant):

```
ORDER_LINE(OrderID, OrderDate, ClientName, City, DistributionCenter,
           Product, Category, UnitPrice, Quantity, Stock)
PK = (OrderID, Product)
```

### 3.2 Second Normal Form (2NF)
**Rule:** be in 1NF and remove **partial dependencies** (non-key attributes that
depend on only part of a composite key).

With `PK = (OrderID, Product)` we detect partial dependencies:

- `OrderDate`, `ClientName`, `City`, `DistributionCenter` depend on **`OrderID`
  only** (not on the product). → move to an **Order** relation.
- `Category`, `UnitPrice` depend on **`Product` only** (not on the order). →
  move to a **Product** relation.
- `Quantity` depends on the **full key** `(OrderID, Product)`. → stays as the
  order line.
- `Stock` depends on `(Product, DistributionCenter)`, not on the order. → move
  to an **Inventory** relation.

Result (2NF):

```
ORDER(OrderID, OrderDate, ClientName, City, DistributionCenter)
PRODUCT(Product, Category, UnitPrice)
ORDER_DETAIL(OrderID, Product, Quantity)
INVENTORY(Product, DistributionCenter, Stock)
```

### 3.3 Third Normal Form (3NF)
**Rule:** be in 2NF and remove **transitive dependencies** (a non-key attribute
that depends on another non-key attribute).

- In `PRODUCT`, `Category` is a descriptive value shared by many products; it is
  a domain of its own → **Category** table (`Product → Category` is kept only as
  an FK).
- `ClientName`, `City` and `DistributionCenter` in `ORDER` are descriptive
  entities repeated across orders → promoted to their own tables **Client**,
  **City**, **DistributionCenter**, referenced by FK.
- `UnitPrice` depends only on the product, so it lives in **Product** (not in the
  order line). Since the source keeps exactly one consistent price per product,
  storing it per line would re-introduce redundancy; the price is therefore a
  determinate attribute of the product.

Final relations, all in **3NF** (every non-key attribute depends on the key, the
whole key, and nothing but the key):

```
eco_city(city_id PK, city_name UNIQUE)
eco_category(category_id PK, category_name UNIQUE)
eco_client(client_id PK, client_name UNIQUE)
eco_distribution_center(center_id PK, center_name UNIQUE)
eco_product(product_id PK, product_name UNIQUE, unit_price, category_id FK→category)
eco_order(order_id PK, order_code UNIQUE, order_date,
          client_id FK→client, center_id FK→center, city_id FK→city)
eco_order_detail(order_detail_id PK, order_id FK→order, product_id FK→product,
                 quantity, UNIQUE(order_id, product_id))
eco_inventory(inventory_id PK, product_id FK→product, center_id FK→center,
              stock, UNIQUE(product_id, center_id))
```

---

## 4. Final normalized model (canonical data)

After deduplication the 20 dirty rows collapse into:

- **9 cities**, **6 categories**, **9 clients**, **6 distribution centers**,
  **10 products**.
- **20 orders** (each with **1 detail line** — the model supports N lines per
  order, the source simply has one product per order).
- **10 inventory records** (one current stock per product/center pair).

Functional dependencies of the final model:

```
city_id            → city_name
category_id        → category_name
client_id          → client_name
center_id          → center_name
product_id         → product_name, unit_price, category_id
order_id           → order_code, order_date, client_id, center_id, city_id
order_detail_id    → order_id, product_id, quantity
inventory_id       → product_id, center_id, stock
```

No partial dependencies, no transitive dependencies → **3NF achieved**.

---

## 5. Data-loading strategy (model validation)

The original Excel is redundant and incompatible with the relational model, so
it is **not** loaded as-is. Instead we **derive the canonical (clean) data** by
deduplicating each dirty column into its lookup table (see the mapping in §2.2)
and load that into the normalized schema.

- The clean data lives in `data/csv/*.csv` and is loaded with PostgreSQL `COPY`
  (`sql/02_load_data.sql`).
- Equivalent pure-`INSERT` loading is available through
  `sql/02_load_data_inserts.sql` or `npm run setup` (Node.js + `pg` driver) for
  environments without file-system access to the DB server from `psql`.

This proves the designed structure can store consistent information and keep
referential integrity between all entities, which is exactly what the raw file
could not guarantee.
