'use strict';

const { Database } = require('./config/database');
const { Logger } = require('./shared/logger');
const { ClientService } = require('./modules/client/client.service');
const { ProductService } = require('./modules/product/product.service');
const { OrderService } = require('./modules/order/order.service');
const { InventoryService } = require('./modules/inventory/inventory.service');
const { AnalyticsService } = require('./modules/analytics/analytics.service');

/**
 * Demo runner: exercises every module/service (raw SQL over the `pg` driver)
 * against the six business needs, the two views and the stored function.
 */
async function main() {
  Logger.section('EcoMarket Riwi — Development runner (raw SQL / pg)');
  Logger.info('Press Ctrl+C to stop. Nodemon restarts on file changes (type rs to force restart).');
  Logger.info(`Environment: ${process.env.NODE_ENV || 'development'}`);

  const clients = new ClientService(Database);
  const products = new ProductService(Database);
  const orders = new OrderService(Database);
  const inventory = new InventoryService(Database);
  const analytics = new AnalyticsService(Database);

  Logger.section('Query 1 — Available inventory per product');
  Logger.table(await products.inventoryPerProduct());

  Logger.section('Query 2 — Order history by city');
  Logger.table(await orders.historyByCity());

  Logger.section('Query 3 — Total sold per category (view)');
  Logger.table(await analytics.salesByCategory());

  Logger.section('Query 4 — Products with the lowest inventory');
  Logger.table(await products.lowestInventory(5));

  Logger.section('Query 5 — Clients with the most orders');
  Logger.table(await clients.mostActive());

  Logger.section('Query 6 — Inventory value per distribution center');
  Logger.table(await inventory.valueByCenter());

  Logger.section('View — Client commercial profile');
  Logger.table(await analytics.clientCommercialProfile());

  Logger.section('Stored function — eco_get_clients(1) vs eco_get_clients()');
  Logger.info('eco_get_clients(1):');
  Logger.table(await clients.getClients(1));
  Logger.info('eco_get_clients() -> all:');
  Logger.table(await clients.getClients(null));

  Logger.section('DML — create a new client with an associated order');
  const created = await orders.createClientWithOrder({
    clientName: `DemoClient_${Date.now()}`,
    orderCode: `D${Date.now()}`,
    centerName: 'North Center',
    cityName: 'Bogotá',
    items: [{ productName: 'Gala Apple', quantity: 8 }],
  });
  Logger.info(`Created order ${created.orderCode} for ${created.clientName} `
    + `(${created.lines} line) in ${created.cityName}.`);
}

main()
  .catch((e) => Logger.error(e.message))
  .finally(() => Database.disconnect());
