import 'package:atpharma/features/shop/data/datasources/shop_product_remote_data_source.dart';
import 'package:atpharma/features/shop/data/models/shop_product_model.dart';
import 'package:atpharma/features/shop/data/models/shop_product_page_model.dart';

import '../../../../core/error/app_failure.dart';
import '../../../../core/error/app_result.dart';
import '../../../../core/error/failure_mapper.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/pagination/paginated_result.dart';
import '../../domain/entities/shop_product_entity.dart';
import '../../domain/entities/shop_product_query.dart';
import '../../domain/repositories/shop_product_repository.dart';

final class ShopProductRepositoryImpl implements ShopProductRepository {
  ShopProductRepositoryImpl({required this._remoteDataSource});

  final ShopProductRemoteDataSource _remoteDataSource;

  @override
  Future<AppResult<PaginatedResult<ShopProductEntity>>> getProducts({
    required ShopProductQuery query,
    String requestKey = 'shop-products',
  }) async {
    try {
      final ShopProductPageModel response = await _remoteDataSource.getProducts(
        query: query,
        requestKey: requestKey,
      );

      final PaginatedResult<ShopProductEntity> result = response.toEntity();

      return AppSuccess<PaginatedResult<ShopProductEntity>>(result);
    } on ApiException catch (error) {
      return AppError<PaginatedResult<ShopProductEntity>>(
        FailureMapper.fromApiException(error),
      );
    } on FormatException catch (error) {
      return AppError<PaginatedResult<ShopProductEntity>>(
        FailureMapper.fromException(error),
      );
    } on ArgumentError catch (error) {
      return AppError<PaginatedResult<ShopProductEntity>>(
        FailureMapper.fromException(error),
      );
    } catch (error) {
      return AppError<PaginatedResult<ShopProductEntity>>(
        FailureMapper.fromException(error),
      );
    }
  }

  @override
  Future<AppResult<ShopProductEntity>> getProductDetails({
    required String idOrSlug,
  }) async {
    final String normalizedIdOrSlug = idOrSlug.trim();

    if (normalizedIdOrSlug.isEmpty) {
      return const AppError<ShopProductEntity>(
        AppFailure(
          message: 'Product ID or slug cannot be empty.',
          type: AppFailureType.validation,
        ),
      );
    }

    try {
      final ShopProductModel response = await _remoteDataSource
          .getProductDetails(idOrSlug: normalizedIdOrSlug);

      final ShopProductEntity product = response.toEntity();

      return AppSuccess<ShopProductEntity>(product);
    } on ApiException catch (error) {
      return AppError<ShopProductEntity>(FailureMapper.fromApiException(error));
    } on FormatException catch (error) {
      return AppError<ShopProductEntity>(FailureMapper.fromException(error));
    } on ArgumentError catch (error) {
      return AppError<ShopProductEntity>(FailureMapper.fromException(error));
    } catch (error) {
      return AppError<ShopProductEntity>(FailureMapper.fromException(error));
    }
  }

  @override
  void cancelProductsRequest({String requestKey = 'shop-products'}) {
    _remoteDataSource.cancelProductsRequest(requestKey: requestKey);
  }

  @override
  void cancelProductDetailsRequest() {
    _remoteDataSource.cancelProductDetailsRequest();
  }
}
