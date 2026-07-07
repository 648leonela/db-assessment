'use strict';

const { BaseRepository } = require('../../core/BaseRepository');

/** Raw-SQL data access for clients. */
class ClientRepository extends BaseRepository {
  constructor(db) {
    super(db, 'eco_client', 'client_id');
  }

  async findByName(clientName) {
    const { rows } = await this.db.query(
      'SELECT * FROM eco_client WHERE client_name = $1',
      [clientName],
    );
    return rows[0] || null;
  }

  /** Query 5 — clients ordered by number of orders (most active first). */
  async mostActive() {
    const { rows } = await this.db.query(`
      SELECT cl.client_name, COUNT(o.order_id)::int AS total_orders
      FROM   eco_client cl
      LEFT   JOIN eco_order o ON o.client_id = cl.client_id
      GROUP  BY cl.client_name
      ORDER  BY total_orders DESC, cl.client_name`);
    return rows;
  }

  /** Calls the SQL stored function eco_get_clients(id|NULL). */
  async callGetClients(clientId = null) {
    const { rows } = await this.db.query(
      'SELECT * FROM eco_get_clients($1::int)',
      [clientId],
    );
    return rows;
  }
}

module.exports = { ClientRepository };
