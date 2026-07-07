'use strict';

const fs = require('node:fs');
const path = require('node:path');

const SQL_DIR = path.join(__dirname, '../../../sql');

/**
 * Executes raw `.sql` files (from the project's sql/ folder) through the
 * `pg` driver. Files must be pure SQL — the INSERT-based loader is used instead
 * of the psql-only `\copy` variant.
 */
class SqlRunner {
  /** @param {typeof import('../config/database').Database} db */
  constructor(db) {
    this.db = db;
  }

  /** Reads and runs a single .sql file (may contain multiple statements). */
  async runFile(fileName) {
    const fullPath = path.join(SQL_DIR, fileName);
    const sql = fs.readFileSync(fullPath, 'utf8');
    await this.db.query(sql);
    return fileName;
  }

  /** Runs several .sql files in order. */
  async runAll(fileNames) {
    const done = [];
    for (const file of fileNames) {
      await this.runFile(file);
      done.push(file);
    }
    return done;
  }
}

module.exports = { SqlRunner, SQL_DIR };
