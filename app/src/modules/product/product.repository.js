'use strict';

const { BaseRepository } = require('../../core/BaseRepository');

/** Raw-SQL data access for products. */
class ProductRepository extends BaseRepository {
  constructor(db) {
    super(db, 'eco_product', 'product_id');
  }

  async findByName(productName) {
    const { rows } = await this.db.query(
      'SELECT * FROM eco_product WHERE product_name = $1',
      [productName],
    );
    return rows[0] || null;
  }

  /** Query 1 — available inventory per product. */
  async inventoryPerProduct() {
    const { rows } = await this.db.query(`
      SELECT p.product_name, SUM(i.stock)::int AS total_stock
      FROM   eco_product p
      JOIN   eco_inventory i ON i.product_id = p.product_id
      GROUP  BY p.product_name
      ORDER  BY total_stock DESC`);
    return rows;
  }

  /** Query 4 — products with the lowest inventory. */
  async lowestInventory(limit = 5) {
    const { rows } = await this.db.query(`
      SELECT p.product_name, dc.center_name, i.stock
      FROM   eco_inventory i
      JOIN   eco_product p              ON p.product_id = i.product_id
      JOIN   eco_distribution_center dc ON dc.center_id = i.center_id
      ORDER  BY i.stock ASC
      LIMIT  $1`, [limit]);
    return rows;
  }

  async countOrderLines(productId) {
    const { rows } = await this.db.query(
      'SELECT COUNT(*)::int AS total FROM eco_order_detail WHERE product_id = $1',
      [productId],
    );
    return rows[0].total;
  }
}

module.exports = { ProductRepository };
