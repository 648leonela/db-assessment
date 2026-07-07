'use strict';

const { OrderRepository } = require('./order.repository');

/** Business logic around orders. */
class OrderService {
  constructor(db) {
    this.db = db;
    this.repo = new OrderRepository(db);
  }

  historyByCity() {
    return this.repo.historyByCity();
  }

  /**
   * Registers a NEW CLIENT together with an associated ORDER atomically,
   * using a single transaction and raw SQL. Center, city and products are
   * resolved by their unique name.
   *
   * @param {{clientName:string, orderCode:string, orderDate?:Date,
   *          centerName:string, cityName:string,
   *          items:{productName:string, quantity:number}[]}} input
   */
  createClientWithOrder(input) {
    const { clientName, orderCode, orderDate, centerName, cityName, items } = input;

    return this.db.withTransaction(async (client) => {
      const insClient = await client.query(
        'INSERT INTO eco_client (client_name) VALUES ($1) RETURNING client_id',
        [clientName],
      );
      const clientId = insClient.rows[0].client_id;

      const insOrder = await client.query(
        `INSERT INTO eco_order (order_code, order_date, client_id, center_id, city_id)
         VALUES (
           $1,
           $2,
           $3,
           (SELECT center_id FROM eco_distribution_center WHERE center_name = $4),
           (SELECT city_id   FROM eco_city                WHERE city_name   = $5)
         )
         RETURNING order_id, order_code`,
        [orderCode, orderDate ?? new Date(), clientId, centerName, cityName],
      );
      const order = insOrder.rows[0];

      let lines = 0;
      for (const item of items) {
        await client.query(
          `INSERT INTO eco_order_detail (order_id, product_id, quantity)
           VALUES ($1, (SELECT product_id FROM eco_product WHERE product_name = $2), $3)`,
          [order.order_id, item.productName, item.quantity],
        );
        lines += 1;
      }

      return {
        orderId: order.order_id,
        orderCode: order.order_code,
        clientName,
        cityName,
        lines,
      };
    });
  }
}

module.exports = { OrderService };
