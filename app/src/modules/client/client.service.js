'use strict';

const { ClientRepository } = require('./client.repository');

/** Business logic around clients. */
class ClientService {
  constructor(db) {
    this.repo = new ClientRepository(db);
  }

  listAll() {
    return this.repo.findAll();
  }

  mostActive() {
    return this.repo.mostActive();
  }

  /**
   * Mirrors the stored function contract:
   *  - id given -> a single client
   *  - id null  -> every client
   */
  getClients(clientId = null) {
    return this.repo.callGetClients(clientId);
  }
}

module.exports = { ClientService };
