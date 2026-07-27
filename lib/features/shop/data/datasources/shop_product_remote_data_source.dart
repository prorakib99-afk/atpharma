import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/api_request_options.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/json_value_parser.dart';
import '../../domain/entities/shop_product_query.dart';
import '../models/shop_product_model.dart';
import '../models/shop_product_page_model.dart';

abstract interface class ShopProductRemoteDataSource {
  Future<ShopProductPageModel> getProducts({
    required ShopProductQuery query,
    String requestKey = 'shop-products',
  });

  Future<ShopProductModel> getProductDetails({required String idOrSlug});

  void cancelProductsRequest({String requestKey = 'shop-products'});

  void cancelProductDetailsRequest();
}

final class ShopProductRemoteDataSourceImpl
    implements ShopProductRemoteDataSource {
  ShopProductRemoteDataSourceImpl({required this._dioClient});

  final DioClient _dioClient;

  final Map<String, CancelToken> _activeProductRequests =
      <String, CancelToken>{};

  CancelToken? _activeProductDetailsRequest;

  @override
  Future<ShopProductPageModel> getProducts({
    required ShopProductQuery query,
    String requestKey = 'shop-products',
  }) async {
    final String normalizedRequestKey = _normalizeRequestKey(requestKey);

    cancelProductsRequest(requestKey: normalizedRequestKey);

    final CancelToken cancelToken = DioClient.createCancelToken();

    _activeProductRequests[normalizedRequestKey] = cancelToken;

    try {
      final Response<dynamic> response = await _dioClient.get<dynamic>(
        ShopCatalogEndpoints.products,
        queryParameters: _buildProductQueryParameters(query),
        options: ApiRequestOptions.publicRequest(),
        cancelToken: cancelToken,
      );

      final Map<String, dynamic>? responseJson = JsonValueParser.map(
        response.data,
      );

      if (responseJson == null) {
        throw const ApiException(
          message: 'The product list response format is invalid.',
          type: ApiExceptionType.unknown,
        );
      }

      return ShopProductPageModel.fromJson(responseJson);
    } finally {
      final CancelToken? registeredToken =
          _activeProductRequests[normalizedRequestKey];

      if (identical(registeredToken, cancelToken)) {
        _activeProductRequests.remove(normalizedRequestKey);
      }
    }
  }

  @override
  Future<ShopProductModel> getProductDetails({required String idOrSlug}) async {
    final String normalizedIdOrSlug = idOrSlug.trim();

    if (normalizedIdOrSlug.isEmpty) {
      throw ArgumentError.value(
        idOrSlug,
        'idOrSlug',
        'Product ID or slug cannot be empty.',
      );
    }

    cancelProductDetailsRequest();

    final CancelToken cancelToken = DioClient.createCancelToken();

    _activeProductDetailsRequest = cancelToken;

    try {
      final Response<dynamic> response = await _dioClient.get<dynamic>(
        ShopCatalogEndpoints.productByIdOrSlug(normalizedIdOrSlug),
        options: ApiRequestOptions.publicRequest(),
        cancelToken: cancelToken,
      );

      final Map<String, dynamic>? responseJson = JsonValueParser.map(
        response.data,
      );

      if (responseJson == null) {
        throw const ApiException(
          message: 'The product details response format is invalid.',
          type: ApiExceptionType.unknown,
        );
      }

      /*
       * Supports both possible response shapes:
       *
       * Direct:
       * {
       *   "id": "...",
       *   "name": "..."
       * }
       *
       * Wrapped:
       * {
       *   "data": {
       *     "id": "...",
       *     "name": "..."
       *   }
       * }
       */
      final Map<String, dynamic> productJson =
          JsonValueParser.map(responseJson['data']) ?? responseJson;

      return ShopProductModel.fromJson(productJson);
    } finally {
      if (identical(_activeProductDetailsRequest, cancelToken)) {
        _activeProductDetailsRequest = null;
      }
    }
  }

  @override
  void cancelProductsRequest({String requestKey = 'shop-products'}) {
    final String normalizedRequestKey = _normalizeRequestKey(requestKey);

    final CancelToken? cancelToken = _activeProductRequests.remove(
      normalizedRequestKey,
    );

    DioClient.cancelRequest(
      cancelToken,
      reason: 'A newer product request replaced the previous request.',
    );
  }

  @override
  void cancelProductDetailsRequest() {
    final CancelToken? cancelToken = _activeProductDetailsRequest;

    _activeProductDetailsRequest = null;

    DioClient.cancelRequest(
      cancelToken,
      reason: 'A newer product details request replaced the previous request.',
    );
  }

  Map<String, dynamic> _buildProductQueryParameters(ShopProductQuery query) {
    return <String, dynamic>{
      'page': query.page,
      'perPage': query.perPage,
      'q': query.normalizedSearch,
      'categoryIds': query.normalizedCategoryIds.isEmpty
          ? null
          : query.normalizedCategoryIds.join(','),
      'minPrice': query.minPrice,
      'maxPrice': query.maxPrice,
      'availability': _mapAvailability(query.availability),
      'prescription': _mapPrescription(query.prescription),
      'featured': query.featured,
      'sort': _mapSort(query.sort),
    };
  }

  String? _mapAvailability(ShopProductAvailability availability) {
    return switch (availability) {
      ShopProductAvailability.all => null,
      ShopProductAvailability.inStock => 'in-stock',
      ShopProductAvailability.outOfStock => 'out-of-stock',
    };
  }

  String? _mapPrescription(ShopProductPrescription prescription) {
    return switch (prescription) {
      ShopProductPrescription.all => null,
      ShopProductPrescription.required => 'rx-required',
      ShopProductPrescription.notRequired => 'no-rx-required',
    };
  }

  String _mapSort(ShopProductSort sort) {
    return switch (sort) {
      ShopProductSort.newest => 'newest',
      ShopProductSort.priceAscending => 'price-asc',
      ShopProductSort.priceDescending => 'price-desc',
      ShopProductSort.popular => 'popular',
    };
  }

  String _normalizeRequestKey(String value) {
    final String normalizedValue = value.trim();

    return normalizedValue.isEmpty ? 'shop-products' : normalizedValue;
  }

}
