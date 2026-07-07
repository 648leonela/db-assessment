-- ============================================================================
--  EcoMarket Riwi S.A.S. — DDL (schema definition)
--  Engine: PostgreSQL 14+
--  Model: Third Normal Form (3NF). All objects prefixed with `eco_`.
--  Run while connected to bd_leonela_miranda_esthercitas.
-- ============================================================================

-- Idempotent: drop existing objects in dependency order.
DROP TABLE IF EXISTS eco_inventory          CASCADE;
DROP TABLE IF EXISTS eco_order_detail        CASCADE;
DROP TABLE IF EXISTS eco_order               CASCADE;
DROP TABLE IF EXISTS eco_product             CASCADE;
DROP TABLE IF EXISTS eco_distribution_center CASCADE;
DROP TABLE IF EXISTS eco_client              CASCADE;
DROP TABLE IF EXISTS eco_category            CASCADE;
DROP TABLE IF EXISTS eco_city                CASCADE;

-- ---------------------------------------------------------------------------
-- Lookup / master tables
-- ---------------------------------------------------------------------------
CREATE TABLE eco_city (
    city_id   INTEGER      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    city_name VARCHAR(80)  NOT NULL,
    CONSTRAINT uq_eco_city_name UNIQUE (city_name)
);

CREATE TABLE eco_category (
    category_id   INTEGER     GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    category_name VARCHAR(80) NOT NULL,
    CONSTRAINT uq_eco_category_name UNIQUE (category_name)
);

CREATE TABLE eco_client (
    client_id   INTEGER      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    client_name VARCHAR(120) NOT NULL,
    CONSTRAINT uq_eco_client_name UNIQUE (client_name)
);

CREATE TABLE eco_distribution_center (
    center_id   INTEGER      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    center_name VARCHAR(120) NOT NULL,
    CONSTRAINT uq_eco_center_name UNIQUE (center_name)
);

CREATE TABLE eco_product (
    product_id   INTEGER        GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_name VARCHAR(150)   NOT NULL,
    unit_price   NUMERIC(10, 2) NOT NULL,
    category_id  INTEGER        NOT NULL,
    CONSTRAINT uq_eco_product_name UNIQUE (product_name),
    CONSTRAINT chk_eco_product_price CHECK (unit_price > 0),
    CONSTRAINT fk_eco_product_category
        FOREIGN KEY (category_id) REFERENCES eco_category (category_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

-- ---------------------------------------------------------------------------
-- Transactional tables
-- ---------------------------------------------------------------------------
CREATE TABLE eco_order (
    order_id   INTEGER     GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_code VARCHAR(20) NOT NULL,
    order_date DATE        NOT NULL,
    client_id  INTEGER     NOT NULL,
    center_id  INTEGER     NOT NULL,
    city_id    INTEGER     NOT NULL,
    CONSTRAINT uq_eco_order_code UNIQUE (order_code),
    CONSTRAINT fk_eco_order_client
        FOREIGN KEY (client_id) REFERENCES eco_client (client_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_eco_order_center
        FOREIGN KEY (center_id) REFERENCES eco_distribution_center (center_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_eco_order_city
        FOREIGN KEY (city_id) REFERENCES eco_city (city_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE eco_order_detail (
    order_detail_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id        INTEGER NOT NULL,
    product_id      INTEGER NOT NULL,
    quantity        INTEGER NOT NULL,
    CONSTRAINT chk_eco_detail_qty CHECK (quantity > 0),
    CONSTRAINT uq_eco_detail_order_product UNIQUE (order_id, product_id),
    CONSTRAINT fk_eco_detail_order
        FOREIGN KEY (order_id) REFERENCES eco_order (order_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_eco_detail_product
        FOREIGN KEY (product_id) REFERENCES eco_product (product_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE eco_inventory (
    inventory_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_id   INTEGER NOT NULL,
    center_id    INTEGER NOT NULL,
    stock        INTEGER NOT NULL,
    CONSTRAINT chk_eco_inventory_stock CHECK (stock >= 0),
    CONSTRAINT uq_eco_inventory_product_center UNIQUE (product_id, center_id),
    CONSTRAINT fk_eco_inventory_product
        FOREIGN KEY (product_id) REFERENCES eco_product (product_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_eco_inventory_center
        FOREIGN KEY (center_id) REFERENCES eco_distribution_center (center_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

-- ---------------------------------------------------------------------------
-- Helpful indexes for the analytical queries
-- ---------------------------------------------------------------------------
CREATE INDEX idx_eco_order_client  ON eco_order (client_id);
CREATE INDEX idx_eco_order_city    ON eco_order (city_id);
CREATE INDEX idx_eco_order_center  ON eco_order (center_id);
CREATE INDEX idx_eco_detail_order  ON eco_order_detail (order_id);
CREATE INDEX idx_eco_detail_product ON eco_order_detail (product_id);
CREATE INDEX idx_eco_inventory_product ON eco_inventory (product_id);
CREATE INDEX idx_eco_inventory_center  ON eco_inventory (center_id);
