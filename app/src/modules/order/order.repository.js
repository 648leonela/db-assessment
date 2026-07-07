'use strict';

const { BaseRepository } = require('../../core/BaseRepository');

/** Raw-SQL data access for orders. */
class OrderRepository extends BaseRepository {
  constructor(db) {
    super(db, 'eco_order', 'order_id');
  }

  /** Query 2 — order history by city. */
  async historyByCity() {
    const { rows } = await this.db.query(`
      SELECT c.city_name, COUNT(o.order_id)::int AS total_orders
      FROM   eco_city c
      JOIN   eco_order o ON o.city_id = c.city_id
      GROUP  BY c.city_name
      ORDER  BY total_orders DESC, c.city_name`);
    return rows;
  }
}

module.exports = { OrderRepository };
