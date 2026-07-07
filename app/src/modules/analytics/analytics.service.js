'use strict';

/** Reads the analytical SQL views for commercial reporting. */
class AnalyticsService {
  constructor(db) {
    this.db = db;
  }

  /** Query 3 — total sold per category (backed by the SQL view). */
  async salesByCategory() {
    const { rows } = await this.db.query(`
      SELECT category_name, units_sold::int, total_revenue
      FROM   eco_vw_sales_by_category
      ORDER  BY total_revenue DESC`);
    return rows;
  }

  async clientCommercialProfile() {
    const { rows } = await this.db.query(`
      SELECT client_name, total_orders::int, total_units::int, total_spent
      FROM   eco_vw_client_commercial_profile
      ORDER  BY total_spent DESC`);
    return rows;
  }
}

module.exports = { AnalyticsService };
