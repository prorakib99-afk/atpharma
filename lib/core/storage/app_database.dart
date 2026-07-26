import 'package:sqflite/sqflite.dart';

final class AppDatabase {
  Database? _database;

  Future<Database> get instance async {
    return _database ??= await openDatabase(
      'atpharma_offline.db',
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute(
          'CREATE TABLE storefront_config ('
          'id INTEGER PRIMARY KEY CHECK (id = 1), '
          'currency TEXT NOT NULL, '
          'tax_percent REAL NOT NULL, '
          'delivery_charge REAL NOT NULL, '
          'updated_at INTEGER NOT NULL'
          ')',
        );
        await db.execute(
          'CREATE TABLE offline_orders ('
          'local_id TEXT PRIMARY KEY, '
          'idempotency_key TEXT NOT NULL UNIQUE, '
          'payload TEXT NOT NULL, '
          'status TEXT NOT NULL, '
          'attempts INTEGER NOT NULL DEFAULT 0, '
          'next_retry_at INTEGER, '
          'last_error TEXT, '
          'server_order_number TEXT, '
          'created_at INTEGER NOT NULL, '
          'updated_at INTEGER NOT NULL'
          ')',
        );
        await db.execute(
          'CREATE INDEX offline_orders_sync_idx '
          'ON offline_orders(status, next_retry_at)',
        );
        await db.execute(
          'CREATE TABLE cached_products ('
          'cache_key TEXT PRIMARY KEY, '
          'payload TEXT NOT NULL, '
          'updated_at INTEGER NOT NULL'
          ')',
        );
      },
      onOpen: (Database db) async {
        await db.update(
          'offline_orders',
          <String, Object?>{'status': 'pending'},
          where: 'status = ?',
          whereArgs: <Object?>['syncing'],
        );
      },
    );
  }

  Future<void> close() async {
    final Database? database = _database;
    _database = null;
    await database?.close();
  }
}
