'use strict';

/** Tiny console logger with section helpers for the demo runner. */
class Logger {
  static section(title) {
    console.log(`\n${'='.repeat(70)}\n  ${title}\n${'='.repeat(70)}`);
  }

  static info(msg) {
    console.log(`  ${msg}`);
  }

  static table(rows) {
    console.table(rows);
  }

  static error(msg) {
    console.error(`  [ERROR] ${msg}`);
  }
}

module.exports = { Logger };
