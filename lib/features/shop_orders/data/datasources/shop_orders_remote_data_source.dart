import 'package:dio/dio.dart';

import '../../../../core/constants/shop_order_cancellation_endpoints.dart';
import '../../../../core/network/api_request_options.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/session/session_manager.dart';
import '../../domain/entities/shop_order_entity.dart';
import '../models/shop_order_model.dart';

abstract interface class ShopOrdersRemoteDataSource {
  Future<ShopOrdersPage> getOrders({
    required int page,
    required int limit,
  });

  Future<ShopOrderCancellationConfig>
      getCancellationConfig();

  Future<CancelShopOrderResult> cancelOrder({
    required String orderNumber,
    required String reason,
    String? note,
  });
}

final class ShopOrdersRemoteDataSourceImpl
    implements ShopOrdersRemoteDataSource {
  const ShopOrdersRemoteDataSourceImpl({
    required this._dioClient,
    required this._sessionManager,
  });

  final DioClient _dioClient;
  final SessionManager _sessionManager;

  @override
  Future<ShopOrdersPage> getOrders({
    required int page,
    required int limit,
  }) async {
    final Response<dynamic> response =
        await _dioClient.get<dynamic>(
      _sessionManager.isGuestMode
          ? '/shop/guest/orders'
          : '/shop/account/orders',
      queryParameters: <String, dynamic>{
        'page': page,
        'limit': limit,
      },
      options:
          ApiRequestOptions.authenticatedShop(),
    );

    if (response.data is! Map) {
      throw const FormatException(
        'Invalid orders response.',
      );
    }

    final Map<String, dynamic> root =
        Map<String, dynamic>.from(
      response.data as Map,
    );

    final dynamic payload =
        root['data'] ?? root;

    final Map<String, dynamic> data =
        payload is Map
            ? Map<String, dynamic>.from(
                payload,
              )
            : root;

    final dynamic ordersPayload =
        payload is List
            ? payload
            : data['orders'] ??
                data['items'] ??
                data['results'] ??
                root['orders'];

    final dynamic raw =
        ordersPayload is Map
            ? ordersPayload['data'] ??
                ordersPayload['orders'] ??
                ordersPayload['items'] ??
                ordersPayload['results']
            : ordersPayload;

    final List<dynamic> list =
        raw is List
            ? raw
            : <dynamic>[];

    final dynamic meta =
        data['pagination'] ??
        data['meta'] ??
        root['pagination'] ??
        root['meta'] ??
        (ordersPayload is Map
            ? ordersPayload['pagination']
            : null);

    final Map<String, dynamic> pagination =
        meta is Map
            ? Map<String, dynamic>.from(
                meta,
              )
            : data;

    int number(
      dynamic value,
      int fallback,
    ) {
      if (value is num) {
        return value.toInt();
      }

      return int.tryParse(
            value?.toString() ?? '',
          ) ??
          fallback;
    }

    final List<ShopOrderEntity> orders =
        list
            .whereType<Map>()
            .map<ShopOrderEntity>(
              (
                Map<dynamic, dynamic> item,
              ) {
                return ShopOrderModel.fromJson(
                  Map<String, dynamic>.from(
                    item,
                  ),
                );
              },
            )
            .toList(growable: false);

    return ShopOrdersPage(
      orders: orders,
      page: number(
        pagination['page'] ??
            pagination['currentPage'],
        page,
      ),
      totalPages: number(
        pagination['totalPages'] ??
            pagination['pages'],
        1,
      ),
      total: number(
        pagination['total'] ??
            pagination['totalItems'],
        list.length,
      ),
    );
  }

  @override
  Future<ShopOrderCancellationConfig>
      getCancellationConfig() async {
    final Response<dynamic> response =
        await _dioClient.get<dynamic>(
      ShopOrderCancellationEndpoints.reasons,
      options:
          ApiRequestOptions.publicRequest(
        allowRetry: true,
      ),
    );

    if (response.data is! Map) {
      throw const FormatException(
        'Invalid cancellation reasons response.',
      );
    }

    return ShopOrderModel
        .cancellationConfigFromJson(
      Map<String, dynamic>.from(
        response.data as Map,
      ),
    );
  }

  @override
  Future<CancelShopOrderResult> cancelOrder({
    required String orderNumber,
    required String reason,
    String? note,
  }) async {
    final String normalizedOrderNumber =
        orderNumber.trim();

    final String normalizedReason =
        reason.trim().toUpperCase();

    final String normalizedNote =
        (note ?? '').trim();

    if (normalizedOrderNumber.isEmpty) {
      throw ArgumentError.value(
        orderNumber,
        'orderNumber',
        'Order number is required.',
      );
    }

    if (normalizedReason.isEmpty) {
      throw ArgumentError.value(
        reason,
        'reason',
        'Cancellation reason is required.',
      );
    }

    if (normalizedReason == 'OTHER' &&
        normalizedNote.isEmpty) {
      throw ArgumentError.value(
        note,
        'note',
        'A note is required for OTHER.',
      );
    }

    if (normalizedNote.length > 500) {
      throw ArgumentError.value(
        note,
        'note',
        'Cancellation note cannot exceed 500 characters.',
      );
    }

    final Response<dynamic> response =
        await _dioClient.post<dynamic>(
      ShopOrderCancellationEndpoints.cancel(
        normalizedOrderNumber,
      ),
      data: <String, dynamic>{
        'reason': normalizedReason,
        if (normalizedNote.isNotEmpty)
          'note': normalizedNote,
      },
      options:
          ApiRequestOptions.authenticatedShop(
        allowRetry: false,
      ),
    );

    if (response.data is! Map) {
      throw const FormatException(
        'Invalid cancel order response.',
      );
    }

    return ShopOrderModel
        .cancellationResultFromJson(
      Map<String, dynamic>.from(
        response.data as Map,
      ),
    );
  }
}