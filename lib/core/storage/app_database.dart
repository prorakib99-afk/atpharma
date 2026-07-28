import 'package:sqflite/sqflite.dart';

final class AppDatabase {
  Database? _database;

  Future<Database> get instance async {
    return _database ??= await openDatabase(
      'atpharma_offline.db',
      version: 3,
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
        await _createCartItemsTable(db);
        await _createFavoriteProductsTable(db);
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        if (oldVersion < 2) {
          await _createCartItemsTable(db);
        }
        if (oldVersion < 3) {
          await _createFavoriteProductsTable(db);
        }
      },
      onDowngrade: (Database db, int oldVersion, int newVersion) async {
        // Keeps existing user data when rolling back from the temporary
        // product/image-cache schema. The unused cache tables are harmless.
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

  static Future<void> _createCartItemsTable(Database db) {
    return db.execute(
      'CREATE TABLE IF NOT EXISTS cart_items ('
      'product_id TEXT PRIMARY KEY, '
      'name TEXT NOT NULL, '
      'image TEXT NOT NULL, '
      'description TEXT NOT NULL, '
      'brand TEXT NOT NULL, '
      'price INTEGER NOT NULL, '
      'prescription_required INTEGER NOT NULL DEFAULT 0, '
      'currency_code TEXT NOT NULL DEFAULT \'\', '
      'country_code TEXT NOT NULL DEFAULT \'\', '
      'quantity INTEGER NOT NULL CHECK (quantity > 0), '
      'updated_at INTEGER NOT NULL'
      ')',
    );
  }

  static Future<void> _createFavoriteProductsTable(Database db) {
    return db.execute(
      'CREATE TABLE IF NOT EXISTS favorite_products ('
      'product_id TEXT PRIMARY KEY, '
      'name TEXT NOT NULL, '
      'image TEXT NOT NULL, '
      'description TEXT NOT NULL, '
      'brand TEXT NOT NULL, '
      'price INTEGER NOT NULL, '
      'updated_at INTEGER NOT NULL'
      ')',
    );
  }

  Future<void> close() async {
    final Database? database = _database;
    _database = null;
    await database?.close();
  }
}
