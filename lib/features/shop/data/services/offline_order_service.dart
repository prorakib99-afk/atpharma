import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/api_request_options.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/app_database.dart';
import '../../../../core/utils/json_value_parser.dart';

final class StorefrontOrderConfig {
  const StorefrontOrderConfig({
    required this.currency,
    required this.taxPercent,
    required this.deliveryCharge,
  });

  static const StorefrontOrderConfig fallback = StorefrontOrderConfig(
    currency: 'SAR',
    taxPercent: 0,
    deliveryCharge: 0,
  );

  final String currency;
  final double taxPercent;
  final double deliveryCharge;
}

final class OfflineOrderItem {
  const OfflineOrderItem({required this.productId, required this.quantity});

  final String productId;
  final int quantity;

  Map<String, Object?> toJson() => <String, Object?>{
    'productId': productId.trim(),
    'quantity': quantity,
  };
}

final class OfflineOrderDraft {
  const OfflineOrderDraft({
    required this.items,
    required this.shippingName,
    required this.shippingPhone,
    required this.shippingAddress,
    this.shippingArea,
    this.shippingCity,
    this.email,
    this.paymentMethod,
    this.couponCode,
    this.notes,
  });

  final List<OfflineOrderItem> items;
  final String shippingName;
  final String shippingPhone;
  final String shippingAddress;
  final String? shippingArea;
  final String? shippingCity;
  final String? email;
  final String? paymentMethod;
  final String? couponCode;
  final String? notes;

  Map<String, Object?> toJson() {
    if (items.isEmpty ||
        items.any(
          (OfflineOrderItem item) =>
              item.productId.trim().isEmpty || item.quantity < 1,
        ) ||
        shippingName.trim().isEmpty ||
        shippingPhone.trim().isEmpty ||
        shippingAddress.trim().isEmpty) {
      throw const FormatException('Order is missing required checkout data.');
    }

    return <String, Object?>{
      'items': items.map((OfflineOrderItem item) => item.toJson()).toList(),
      'shippingName': shippingName.trim(),
      'shippingPhone': shippingPhone.trim(),
      'shippingAddress': shippingAddress.trim(),
      if ((shippingArea ?? '').trim().isNotEmpty)
        'shippingArea': shippingArea!.trim(),
      if ((shippingCity ?? '').trim().isNotEmpty)
        'shippingCity': shippingCity!.trim(),
      if ((email ?? '').trim().isNotEmpty) 'email': email!.trim().toLowerCase(),
      if ((paymentMethod ?? '').trim().isNotEmpty)
        'paymentMethod': paymentMethod!.trim(),
      if ((couponCode ?? '').trim().isNotEmpty)
        'couponCode': couponCode!.trim(),
      if ((notes ?? '').trim().isNotEmpty) 'notes': notes!.trim(),
    };
  }
}

final class OfflineOrderService extends ChangeNotifier {
  OfflineOrderService({
    required this._database,
    required this._dioClient,
    Connectivity? connectivity,
  }) : _connectivity = connectivity ?? Connectivity();

  final AppDatabase _database;
  final DioClient _dioClient;
  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _retryTimer;
  Future<void>? _initialization;
  bool _storageAvailable = false;
  bool _syncing = false;
  int _pendingCount = 0;

  int get pendingCount => _pendingCount;
  bool get isSyncing => _syncing;
  bool get storageAvailable => _storageAvailable;

  Future<void> initialize() {
    return _initialization ??= _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _database.instance;
      _storageAvailable = true;
      await _refreshPendingCount();
    } catch (_) {
      _storageAvailable = false;
    }
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      if (results.any((ConnectivityResult result) {
        return result != ConnectivityResult.none;
      })) {
        unawaited(syncPending());
        unawaited(refreshConfig());
      }
    });
    unawaited(syncPending());
    unawaited(refreshConfig());
  }

  Future<String> enqueue(OfflineOrderDraft draft) async {
    await initialize();
    if (!_storageAvailable) {
      throw StateError('Offline order storage is unavailable.');
    }
    final Map<String, Object?> payload = draft.toJson();
    final String localId = _newLocalId();
    final int now = DateTime.now().millisecondsSinceEpoch;
    await (await _database.instance).insert('offline_orders', <String, Object?>{
      'local_id': localId,
      'idempotency_key': localId,
      'payload': jsonEncode(payload),
      'status': 'pending',
      'attempts': 0,
      'created_at': now,
      'updated_at': now,
    });
    await _refreshPendingCount();
    unawaited(syncPending());
    return localId;
  }

  Future<StorefrontOrderConfig> config() async {
    if (!_storageAvailable) return StorefrontOrderConfig.fallback;
    final List<Map<String, Object?>> rows = await (await _database.instance)
        .query('storefront_config', where: 'id = 1', limit: 1);
    if (rows.isEmpty) return StorefrontOrderConfig.fallback;
    final Map<String, Object?> row = rows.first;
    return StorefrontOrderConfig(
      currency: row['currency']! as String,
      taxPercent: (row['tax_percent']! as num).toDouble(),
      deliveryCharge: (row['delivery_charge']! as num).toDouble(),
    );
  }

  Future<void> refreshConfig() async {
    if (!_storageAvailable) return;
    try {
      final Response<dynamic> response = await _dioClient.get<dynamic>(
        ShopOrderEndpoints.config,
        options: ApiRequestOptions.publicRequest(),
      );
      final Map<String, dynamic>? root = JsonValueParser.map(response.data);
      final Map<String, dynamic>? data =
          JsonValueParser.map(root?['data']) ?? root;
      if (data == null) return;
      final StorefrontOrderConfig value = StorefrontOrderConfig(
        currency: JsonValueParser.string(
          data['currency'],
          fallback: StorefrontOrderConfig.fallback.currency,
        ),
        taxPercent: JsonValueParser.decimal(data['taxPercent']),
        deliveryCharge: JsonValueParser.decimal(data['deliveryCharge']),
      );
      await (await _database.instance)
          .insert('storefront_config', <String, Object?>{
            'id': 1,
            'currency': value.currency,
            'tax_percent': value.taxPercent,
            'delivery_charge': value.deliveryCharge,
            'updated_at': DateTime.now().millisecondsSinceEpoch,
          }, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (_) {
      // Cached/fallback config remains available while offline.
    }
  }

  Future<void> syncPending() async {
    if (!_storageAvailable || _syncing) return;
    final List<ConnectivityResult> connectivity = await _connectivity
        .checkConnectivity();
    if (connectivity.every(
      (ConnectivityResult result) => result == ConnectivityResult.none,
    )) {
      return;
    }

    _syncing = true;
    notifyListeners();
    try {
      final int now = DateTime.now().millisecondsSinceEpoch;
      final Database db = await _database.instance;
      final List<Map<String, Object?>> rows = await db.query(
        'offline_orders',
        where:
            "status IN ('pending', 'retry') "
            'AND (next_retry_at IS NULL OR next_retry_at <= ?)',
        whereArgs: <Object?>[now],
        orderBy: 'created_at ASC',
        limit: 20,
      );
      for (final Map<String, Object?> row in rows) {
        await _syncOne(db, row);
      }
    } finally {
      _syncing = false;
      await _refreshPendingCount();
      await _scheduleNextRetry();
      notifyListeners();
    }
  }

  Future<void> _scheduleNextRetry() async {
    _retryTimer?.cancel();
    final List<Map<String, Object?>> rows = await (await _database.instance)
        .rawQuery(
          "SELECT MIN(next_retry_at) AS next_retry FROM offline_orders "
          "WHERE status = 'retry' AND next_retry_at IS NOT NULL",
        );
    if (rows.isEmpty || rows.first['next_retry'] == null) return;
    final int nextRetry = rows.first['next_retry']! as int;
    final Duration delay = Duration(
      milliseconds: max(0, nextRetry - DateTime.now().millisecondsSinceEpoch),
    );
    _retryTimer = Timer(delay, () => unawaited(syncPending()));
  }

  Future<void> _syncOne(Database db, Map<String, Object?> row) async {
    final String localId = row['local_id']! as String;
    final int attempts = (row['attempts']! as int) + 1;
    await db.update(
      'offline_orders',
      <String, Object?>{
        'status': 'syncing',
        'attempts': attempts,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'local_id = ?',
      whereArgs: <Object?>[localId],
    );

    try {
      final Object payload = jsonDecode(row['payload']! as String);
      final Response<dynamic> response = await _dioClient.post<dynamic>(
        ShopOrderEndpoints.createOrder,
        data: payload,
        options: ApiRequestOptions.publicRequest(
          headers: <String, dynamic>{
            'X-Idempotency-Key': row['idempotency_key'],
          },
          allowRetry: false,
        ),
      );
      final Map<String, dynamic>? root = JsonValueParser.map(response.data);
      final Map<String, dynamic>? data =
          JsonValueParser.map(root?['data']) ?? root;
      final String orderNumber = JsonValueParser.string(
        data?['orderNumber'] ?? data?['number'],
      );
      await db.update(
        'offline_orders',
        <String, Object?>{
          'status': 'synced',
          'server_order_number': orderNumber,
          'last_error': null,
          'next_retry_at': null,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'local_id = ?',
        whereArgs: <Object?>[localId],
      );
    } on ApiException catch (error) {
      final bool permanent =
          error.isValidationError ||
          error.isUnauthorized ||
          error.isForbidden ||
          error.isNotFound;
      await _recordFailure(db, localId, attempts, error.message, permanent);
    } catch (error) {
      await _recordFailure(db, localId, attempts, error.toString(), false);
    }
  }

  Future<void> _recordFailure(
    Database db,
    String localId,
    int attempts,
    String message,
    bool permanent,
  ) {
    final int delayMinutes = min(60, 1 << min(attempts - 1, 6));
    return db.update(
      'offline_orders',
      <String, Object?>{
        'status': permanent ? 'failed' : 'retry',
        'last_error': message,
        'next_retry_at': permanent
            ? null
            : DateTime.now()
                  .add(Duration(minutes: delayMinutes))
                  .millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'local_id = ?',
      whereArgs: <Object?>[localId],
    );
  }

  Future<void> _refreshPendingCount() async {
    final List<Map<String, Object?>> rows = await (await _database.instance)
        .rawQuery(
          "SELECT COUNT(*) AS count FROM offline_orders "
          "WHERE status IN ('pending', 'retry', 'syncing')",
        );
    _pendingCount = Sqflite.firstIntValue(rows) ?? 0;
    notifyListeners();
  }

  String _newLocalId() {
    final int now = DateTime.now().microsecondsSinceEpoch;
    final int random = Random.secure().nextInt(0x7fffffff);
    return 'offline-$now-$random';
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    unawaited(_connectivitySubscription?.cancel());
    super.dispose();
  }
}
