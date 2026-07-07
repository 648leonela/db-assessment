'use strict';

const path = require('node:path');

require('dotenv').config({ path: path.join(__dirname, '../../.env') });

const { Pool } = require('pg');

/**
 * Singleton wrapper around a node-postgres connection Pool.
 * The whole application talks to PostgreSQL through raw SQL using this class.
 */
class Database {
  /** @type {import('pg').Pool|null} */
  static #pool = null;

  /** @returns {import('pg').Pool} */
  static getPool() {
    if (!Database.#pool) {
      const raw = process.env.DATABASE_URL;
      if (!raw) {
        throw new Error('DATABASE_URL is not set. Copy app/.env.example to app/.env.');
      }
      // Strip unsupported query params from the connection URL if present.
      const url = new URL(raw);
      url.search = '';
      Database.#pool = new Pool({ connectionString: url.toString() });
    }
    return Database.#pool;
  }

  /**
   * Runs a parameterized raw SQL query.
   * @param {string} text SQL text with $1, $2... placeholders
   * @param {any[]} [params] bound parameters
   */
  static query(text, params = []) {
    return Database.getPool().query(text, params);
  }

  /**
   * Runs a function inside a single transaction (BEGIN/COMMIT/ROLLBACK).
   * The callback receives a dedicated client to run raw SQL.
   * @template T
   * @param {(client: import('pg').PoolClient) => Promise<T>} fn
   * @returns {Promise<T>}
   */
  static async withTransaction(fn) {
    const client = await Database.getPool().connect();
    try {
      await client.query('BEGIN');
      const result = await fn(client);
      await client.query('COMMIT');
      return result;
    } catch (err) {
      await client.query('ROLLBACK');
      throw err;
    } finally {
      client.release();
    }
  }

  static async disconnect() {
    if (Database.#pool) {
      await Database.#pool.end();
      Database.#pool = null;
    }
  }
}

module.exports = { Database };
