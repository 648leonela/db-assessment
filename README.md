# EcoMarket Riwi S.A.S. — Relational Database (Module 4)

Modernization of EcoMarket Riwi's operation: migrating a single, messy Excel
sheet into a normalized (3NF) relational database in **PostgreSQL**, with full
DDL/DML/query scripts, CSV data loading, analytical views, a stored function
and a modular **OOP application built on raw SQL** (node-postgres).

---

## Project description

EcoMarket Riwi S.A.S. distributes fresh food to supermarkets, restaurants and
specialty stores across several cities. For years the whole operation lived in
one shared Excel file, which produced duplicated clients, products written in
many ways, inconsistent categories, repeated distribution centers, inconsistent
city names and unreliable reports.

This project turns that raw file into a professional data model:

- Analyzes the source Excel and detects redundancy and inconsistency.
- Designs the Entity-Relationship Model.
- Applies **1NF, 2NF and 3NF**.
- Implements the schema in PostgreSQL with full integrity constraints.
- Loads consistent data through CSV + `COPY` (and a pure-`INSERT` alternative).
- Answers six real business questions with SQL.
- Adds two analytical views and a client-querying stored function.
- Ships a modular, object-oriented Node.js application that runs **raw SQL**.

## Technologies

| Area            | Technology                          |
|-----------------|-------------------------------------|
| Database engine | **PostgreSQL 14+** (validated on 16/17)|
| DB driver       | **node-postgres (`pg`) 8** — raw SQL, no ORM |
| Runtime         | **Node.js 22** (JavaScript, OOP)    |
| Dev runner      | **Nodemon 3** (hot-reload on save)  |
| Modeling        | dbdiagram.io (DBML) + Mermaid       |
| Containerization| Docker (PostgreSQL for local runs)  |

## User interface note

The assessment **does not require a web or desktop graphical interface**. The
deliverable is a **relational database** plus executable SQL scripts and
documentation. For the extra points, a **modular OOP application** was added;
it uses **raw SQL** through the `pg` driver (no ORM). Its execution interface is
the **console runner** in `app/src/index.js`, which prints all six business
queries, both analytical views, the stored function and a sample DML operation
to the terminal.

Run it with `npm run dev` (development, auto-restart) or `npm start` (single run).

## Database engine

**PostgreSQL**. It was chosen for its strong support of referential integrity,
`CHECK` constraints, identity columns, set-returning functions (`plpgsql`) and
the client-side `\copy` bulk-load command used for data ingestion.

Database name (assessment rule `bd_<name>_<lastname>_<clan>`):

```
bd_leonela_miranda_esthercitas
```

## Normalization process

The full trace (initial state, problems, transformations and the final model)
is documented in **[docs/normalization.md](docs/normalization.md)**. Summary:

- **Initial state (UNF):** one flat sheet, no keys, everything repeated.
- **Problems:** the same client/product/city/category/center written in many
  ways, unit price repeated on every row, no integrity, and one client
  (`SuperMax`) transacting in two cities.
- **1NF:** atomic values, whitespace/casing unified, a key established.
- **2NF:** partial dependencies removed → `Order`, `Product`, `Order_Detail`,
  `Inventory` split out.
- **3NF:** transitive dependencies removed → `City`, `Category`, `Client`,
  `DistributionCenter` promoted to their own tables; price kept in `Product`.

Key decision: **`city` belongs to the order** (not to the client or the center),
because the data proves a single client and a single center operate across
multiple cities.

## Database schema

Eight tables, all prefixed with `eco_`, columns and tables in English.

| Table | Purpose | Key constraints |
|-------|---------|-----------------|
| `eco_city` | Cities | PK, `city_name` UNIQUE NOT NULL |
| `eco_category` | Product categories | PK, `category_name` UNIQUE NOT NULL |
| `eco_client` | Clients | PK, `client_name` UNIQUE NOT NULL |
| `eco_distribution_center` | Logistics centers | PK, `center_name` UNIQUE NOT NULL |
| `eco_product` | Products | PK, `product_name` UNIQUE, `unit_price` CHECK > 0, FK → category |
| `eco_order` | Orders | PK, `order_code` UNIQUE, FK → client/center/city |
| `eco_order_detail` | Order line items | PK, UNIQUE(order,product), `quantity` CHECK > 0, FK → order/product |
| `eco_inventory` | Stock per product/center | PK, UNIQUE(product,center), `stock` CHECK ≥ 0, FK → product/center |

## Entity Relationship Diagram

![Entity Relationship Diagram](docs/er-diagram.png)

Sources: **[docs/er-diagram.dbml](docs/er-diagram.dbml)** (import into
dbdiagram.io) and **[docs/er-diagram.mmd](docs/er-diagram.mmd)** (Mermaid).

## Repository structure

```
db-assessment/
├─ README.md
├─ package.json                               # npm scripts + nodemonConfig
├─ Dataset_EcoMarketRiwi_Jornada_Tarde.xlsx   # original source file
├─ docs/
│  ├─ normalization.md                        # 1NF/2NF/3NF process
│  ├─ er-diagram.dbml / .mmd / .png           # ER model
├─ sql/
│  ├─ 00_create_database.sql
│  ├─ 01_ddl.sql                              # tables, PK/FK/UNIQUE/NOT NULL/CHECK
│  ├─ 02_load_data.sql                        # CSV + COPY (primary load)
│  ├─ 02_load_data_inserts.sql                # pure INSERT (fallback load)
│  ├─ 03_dml.sql                              # insert / update / delete
│  ├─ 04_queries.sql                          # 6 business queries
│  ├─ 05_views.sql                            # 2 analytical views (extra)
│  └─ 06_stored_procedure.sql                 # client function (extra)
├─ data/csv/                                  # normalized/clean CSV files
├─ app/                                       # Node.js + raw SQL + OOP (extra)
│  ├─ .env / .env.example                     # DATABASE_URL for the pg driver
│  └─ src/
│     ├─ config/database.js                   # pg Pool singleton + transaction helper
│     ├─ core/BaseRepository.js · SqlRunner.js
│     ├─ shared/logger.js
│     ├─ modules/{client,product,order,inventory,analytics}
│     ├─ setup.js                             # runs the .sql files via pg
│     └─ index.js                             # console demo runner
└─ evidence/execution_evidence.md             # real execution outputs
```

## Database creation instructions

### Option A — Local PostgreSQL (psql)

```bash
# 1) Create the database (run from the project root)
psql -U postgres -f sql/00_create_database.sql

# 2) Create the schema
psql -U postgres -d bd_leonela_miranda_esthercitas -f sql/01_ddl.sql
```

### Option B — Docker (no local PostgreSQL needed)

```bash
docker run -d --name eco_pg -e POSTGRES_PASSWORD=postgres \
  -v "$PWD:/work" -w /work -p 5432:5432 postgres:16-alpine

docker exec eco_pg psql -U postgres -f /work/sql/00_create_database.sql
docker exec eco_pg psql -U postgres -d bd_leonela_miranda_esthercitas -f /work/sql/01_ddl.sql
```

## Data loading instructions

**Strategy:** the raw Excel is *not* loaded as-is (it is redundant and
inconsistent). Instead, the dirty columns are deduplicated into their lookup
tables (mapping in `docs/normalization.md`) and the resulting clean data is
loaded. This proves the 3NF structure stores consistent data with full
referential integrity.

```bash
# Primary: CSV + COPY (run from the project root so relative paths resolve)
psql -U postgres -d bd_leonela_miranda_esthercitas -f sql/02_load_data.sql

# Fallback: pure INSERT (works in pgAdmin/DBeaver, no file-system access needed)
psql -U postgres -d bd_leonela_miranda_esthercitas -f sql/02_load_data_inserts.sql
```

Then run the rest:

```bash
psql -U postgres -d bd_leonela_miranda_esthercitas -f sql/03_dml.sql
psql -U postgres -d bd_leonela_miranda_esthercitas -f sql/05_views.sql
psql -U postgres -d bd_leonela_miranda_esthercitas -f sql/06_stored_procedure.sql
psql -U postgres -d bd_leonela_miranda_esthercitas -f sql/04_queries.sql
```

## SQL query explanation

| # | Query | Business need | Technique |
|---|-------|---------------|-----------|
| 1 | Available inventory per product | Plan new purchases | `SUM(stock)` grouped by product |
| 2 | Order history by city | Cities with most orders | `COUNT(order)` grouped by city |
| 3 | Total sold per category | Categories with most revenue | `SUM(quantity*unit_price)` by category |
| 4 | Products with lowest inventory | Products about to run out | `ORDER BY stock ASC LIMIT 5` |
| 5 | Clients with most orders | Most active clients | `COUNT(order)` grouped by client |
| 6 | Inventory value per center | Value stored per center | `SUM(stock*unit_price)` by center |

Extra objects:

- **`eco_vw_sales_by_category`** — units, revenue and order count per category.
- **`eco_vw_client_commercial_profile`** — orders, units and spend per client.
- **`eco_get_clients(p_client_id)`** — set-returning function: returns one client
  when given an id, or **all** clients when given `NULL`.

Real outputs for every one of these are in
**[evidence/execution_evidence.md](evidence/execution_evidence.md)**.

## Database build instructions

Two equivalent ways to build the schema. Use **one** path per database.

### Path A — Pure SQL with psql

Run from the **project root**:

```bash
# 1) Create database
psql -U postgres -f sql/00_create_database.sql

# 2) Create tables, constraints, indexes
psql -U postgres -d bd_leonela_miranda_esthercitas -f sql/01_ddl.sql

# 3) Load normalized data
psql -U postgres -d bd_leonela_miranda_esthercitas -f sql/02_load_data.sql

# 4) Views and stored function (extra points)
psql -U postgres -d bd_leonela_miranda_esthercitas -f sql/05_views.sql
psql -U postgres -d bd_leonela_miranda_esthercitas -f sql/06_stored_procedure.sql
```

> `sql/02_load_data_inserts.sql` is an alternative to step 3 when `\copy` is not
> available (pgAdmin / DBeaver).

### Path B — Node.js runner (`npm run setup`)

The application can build everything itself through the `pg` driver, executing
the same `.sql` scripts in order (`01_ddl` → `02_load_data_inserts` → `05_views`
→ `06_stored_procedure`). No psql required.

```bash
cp app/.env.example app/.env    # set your postgres password in DATABASE_URL
npm install
npm run setup                    # builds schema, loads data, creates views + function
```

**Prerequisites:** PostgreSQL running and the database
`bd_leonela_miranda_esthercitas` already created (once, via
`sql/00_create_database.sql` or pgAdmin).

## Project execution instructions

### Quick start (recommended — console runner)

All commands from the **project root**:

```bash
cp app/.env.example app/.env    # first time: set your postgres password
npm install
npm run setup                    # build schema + load data (once)
npm run dev                      # run the full demo with hot-reload
```

**What `npm run dev` does:**

1. Connects to PostgreSQL using `app/.env` (via the `pg` driver, raw SQL).
2. Runs all **6 business queries**, **2 views**, the **stored function** and a
   **sample DML insert** (console output).
3. **Nodemon** watches `app/src` and `app/.env`; saving a file restarts the
   runner. Type `rs` to force a restart. Press `Ctrl+C` to stop.

### One-shot run (no file watching)

```bash
npm start            # same as npm run demo
```

### SQL-only execution (no Node.js)

After building the database (Path A):

```bash
psql -U postgres -d bd_leonela_miranda_esthercitas -f sql/03_dml.sql
psql -U postgres -d bd_leonela_miranda_esthercitas -f sql/04_queries.sql
```

### Available npm scripts

| Script | Description |
|--------|-------------|
| `npm run setup` | Build schema + load data + views + function (raw SQL via `pg`) |
| `npm run dev` | Dev runner with nodemon (full demo) |
| `npm start` | Single execution of the demo |
| `npm run db:seed` | Alias of `setup` (rebuild + reload data) |

> Run every script above from the **project root** (`db-assessment/`).

### Environment file

```bash
cp app/.env.example app/.env   # then edit your postgres password
```

Example `DATABASE_URL`:

```
postgresql://postgres:YOUR_PASSWORD@localhost:5432/bd_leonela_miranda_esthercitas
```

## OOP application (extra points)

A modular, object-oriented data-access layer over the same database, using
**raw SQL** (no ORM) through the node-postgres (`pg`) driver.

- **OOP:** a `Database` singleton (pg `Pool` + transaction helper), an abstract
  `BaseRepository` extended by each entity repository, and one service class per
  module.
- **Modular architecture:** `src/modules/{client,product,order,inventory,analytics}`,
  each with its repository/service; shared building blocks in `src/core`
  (`BaseRepository`, `SqlRunner`), `src/config` (`database.js`) and `src/shared`.
- **Raw SQL everywhere:** all values are passed as bound parameters (`$1, $2…`)
  to prevent SQL injection; the stored function `eco_get_clients()` and both
  views are consumed directly.
- **Schema provisioning:** `src/setup.js` runs the ordered `.sql` scripts, so the
  same SQL that graders run by hand also powers the app.

See **[Database build instructions](#database-build-instructions)** and
**[Project execution instructions](#project-execution-instructions)** above for
the full step-by-step workflow.

## Deliverables checklist

- [x] DDL script — `sql/01_ddl.sql`
- [x] Load scripts — `sql/02_load_data.sql` (+ CSVs) and `sql/02_load_data_inserts.sql`
- [x] DML scripts — `sql/03_dml.sql`
- [x] SQL queries — `sql/04_queries.sql`
- [x] ER model — `docs/er-diagram.{png,dbml,mmd}`
- [x] Original Excel — `Dataset_EcoMarketRiwi_Jornada_Tarde.xlsx`
- [x] Solution files — `data/csv/`, `app/`
- [x] README.md
- [x] Execution evidence — `evidence/execution_evidence.md`
- [x] Extra: 2 views + stored function + modular OOP app (raw SQL / node-postgres)

## Developer information

| | |
|-|-|
| **Developer** | Leonela Miranda |
| **Clan** | Esthercitas |
| **Program** | Riwi — Module 4: Relational Databases |
| **Engine** | PostgreSQL |
| **App stack** | Node.js + node-postgres (raw SQL, OOP) |
