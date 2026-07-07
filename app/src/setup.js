'use strict';

const { Database } = require('./config/database');
const { SqlRunner } = require('./core/SqlRunner');
const { Logger } = require('./shared/logger');

/**
 * Builds the whole schema from the raw SQL scripts and loads the normalized
 * data, all through the `pg` driver (no psql required).
 *
 * Steps:
 *   1. 01_ddl.sql                 -> tables, PK/FK/UNIQUE/NOT NULL/CHECK
 *   2. 02_load_data_inserts.sql   -> normalized data (pure INSERT, pg-friendly)
 *   3. 05_views.sql               -> analytical views
 *   4. 06_stored_procedure.sql    -> client stored function
 *
 * Prerequisite: the target database (bd_leonela_miranda_esthercitas) must
 * already exist. Create it once with sql/00_create_database.sql via psql/pgAdmin.
 */
async function main() {
  const runner = new SqlRunner(Database);

  Logger.section('Setup — building schema and loading data (raw SQL)');

  const files = [
    '01_ddl.sql',
    '02_load_data_inserts.sql',
    '05_views.sql',
    '06_stored_procedure.sql',
  ];

  for (const file of files) {
    await runner.runFile(file);
    Logger.info(`Executed sql/${file}`);
  }

  const { rows } = await Database.query(`
    SELECT 'clients' AS entity, COUNT(*)::int AS total FROM eco_client
    UNION ALL SELECT 'products',      COUNT(*)::int FROM eco_product
    UNION ALL SELECT 'orders',        COUNT(*)::int FROM eco_order
    UNION ALL SELECT 'order_details', COUNT(*)::int FROM eco_order_detail
    UNION ALL SELECT 'inventory',     COUNT(*)::int FROM eco_inventory`);

  Logger.section('Setup complete — row counts');
  Logger.table(rows);
}

main()
  .catch((e) => Logger.error(e.message))
  .finally(() => Database.disconnect());
