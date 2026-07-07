'use strict';

/** Business logic around inventory valuation and distribution centers. */
class InventoryService {
  constructor(db) {
    this.db = db;
  }

  /** Query 6 — economic value of inventory per distribution center. */
  async valueByCenter() {
    const { rows } = await this.db.query(`
      SELECT dc.center_name, SUM(i.stock * p.unit_price) AS inventory_value
      FROM   eco_inventory i
      JOIN   eco_product p              ON p.product_id = i.product_id
      JOIN   eco_distribution_center dc ON dc.center_id = i.center_id
      GROUP  BY dc.center_name
      ORDER  BY inventory_value DESC`);
    return rows;
  }

  /** Update the information (name) of a distribution center. */
  async renameCenter(centerId, centerName) {
    const { rows } = await this.db.query(
      `UPDATE eco_distribution_center
       SET    center_name = $2
       WHERE  center_id = $1
       RETURNING center_id, center_name`,
      [centerId, centerName],
    );
    return rows[0] || null;
  }
}

module.exports = { InventoryService };
