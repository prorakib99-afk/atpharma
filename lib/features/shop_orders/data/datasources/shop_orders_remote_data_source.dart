import 'package:dio/dio.dart';
import '../../../../core/network/api_request_options.dart';
import '../../../../core/network/dio_client.dart';
import '../models/shop_order_model.dart';
import '../../domain/entities/shop_order_entity.dart';

abstract interface class ShopOrdersRemoteDataSource {
  Future<ShopOrdersPage> getOrders({required int page, required int limit});
}

final class ShopOrdersRemoteDataSourceImpl
    implements ShopOrdersRemoteDataSource {
  const ShopOrdersRemoteDataSourceImpl({required DioClient dioClient})
    : _dioClient = dioClient;
  final DioClient _dioClient;
  @override
  Future<ShopOrdersPage> getOrders({
    required int page,
    required int limit,
  }) async {
    final Response<dynamic> response = await _dioClient.get<dynamic>(
      '/shop/account/orders',
      queryParameters: <String, dynamic>{'page': page, 'limit': limit},
      options: ApiRequestOptions.authenticated(),
    );
    if (response.data is! Map)
      throw const FormatException('Invalid orders response.');
    final root = Map<String, dynamic>.from(response.data as Map);
    final dynamic payload = root['data'] ?? root;
    final Map<String, dynamic> data = payload is Map
        ? Map<String, dynamic>.from(payload)
        : root;
    final dynamic raw =
        data['orders'] ?? data['items'] ?? data['results'] ?? root['orders'];
    final List<dynamic> list = raw is List ? raw : <dynamic>[];
    final dynamic meta = data['pagination'] ?? data['meta'];
    final Map<String, dynamic> pagination = meta is Map
        ? Map<String, dynamic>.from(meta)
        : data;
    int number(dynamic value, int fallback) => value is num
        ? value.toInt()
        : int.tryParse(value?.toString() ?? '') ?? fallback;
    return ShopOrdersPage(
      orders: list
          .whereType<Map>()
          .map((e) => ShopOrderModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      page: number(pagination['page'] ?? pagination['currentPage'], page),
      totalPages: number(pagination['totalPages'] ?? pagination['pages'], 1),
      total: number(
        pagination['total'] ?? pagination['totalItems'],
        list.length,
      ),
    );
  }
}
