'use strict';

const { ProductRepository } = require('./product.repository');

/** Business logic around products and their inventory. */
class ProductService {
  constructor(db) {
    this.repo = new ProductRepository(db);
  }

  inventoryPerProduct() {
    return this.repo.inventoryPerProduct();
  }

  lowestInventory(limit = 5) {
    return this.repo.lowestInventory(limit);
  }

  /**
   * Deletes a product ONLY if it has no associated orders.
   * The FK RESTRICT constraint is the ultimate guard; this adds a friendly
   * application-level check first.
   */
  async deleteIfNoOrders(productId) {
    const lines = await this.repo.countOrderLines(productId);
    if (lines > 0) {
      throw new Error(`Product ${productId} has ${lines} order line(s); cannot delete.`);
    }
    return this.repo.delete(productId);
  }
}

module.exports = { ProductService };
