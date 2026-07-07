'use strict';

/**
 * Generic repository (OOP inheritance base) built on raw SQL.
 * Concrete repositories only declare their table name and primary-key column;
 * the shared CRUD operations are implemented here with parameterized queries.
 *
 * Note: table and column names come from trusted internal constants (never user
 * input), so interpolating them into the SQL text is safe. All *values* are
 * always passed as bound parameters ($1, $2, ...).
 *
 * @abstract
 */
class BaseRepository {
  /**
   * @param {typeof import('../config/database').Database} db  Database class
   * @param {string} table     table name (e.g. "eco_client")
   * @param {string} idColumn  primary-key column (e.g. "client_id")
   */
  constructor(db, table, idColumn) {
    if (new.target === BaseRepository) {
      throw new Error('BaseRepository is abstract and cannot be instantiated directly.');
    }
    this.db = db;
    this.table = table;
    this.idColumn = idColumn;
  }

  async findAll() {
    const { rows } = await this.db.query(
      `SELECT * FROM ${this.table} ORDER BY ${this.idColumn}`,
    );
    return rows;
  }

  async findById(id) {
    const { rows } = await this.db.query(
      `SELECT * FROM ${this.table} WHERE ${this.idColumn} = $1`,
      [id],
    );
    return rows[0] || null;
  }

  async count() {
    const { rows } = await this.db.query(
      `SELECT COUNT(*)::int AS total FROM ${this.table}`,
    );
    return rows[0].total;
  }

  async delete(id) {
    const { rowCount } = await this.db.query(
      `DELETE FROM ${this.table} WHERE ${this.idColumn} = $1`,
      [id],
    );
    return rowCount;
  }
}

module.exports = { BaseRepository };
