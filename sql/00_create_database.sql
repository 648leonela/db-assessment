-- ============================================================================
--  EcoMarket Riwi S.A.S. — Database creation
--  Engine: PostgreSQL 14+
--  Naming rule: bd_<name>_<lastname>_<clan>  ->  bd_leonela_miranda_esthercitas
-- ============================================================================
-- Run this while connected to the default `postgres` database.

CREATE DATABASE bd_leonela_miranda_esthercitas
    WITH ENCODING = 'UTF8'
         TEMPLATE = template0
         LC_COLLATE = 'C'
         LC_CTYPE = 'C';

-- Then connect to it and run 01_ddl.sql:
--   \c bd_leonela_miranda_esthercitas
