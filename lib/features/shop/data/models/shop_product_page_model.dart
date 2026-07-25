import '../../../../core/pagination/paginated_result.dart';
import '../../../../core/utils/json_value_parser.dart';
import '../../domain/entities/shop_product_entity.dart';
import 'shop_product_model.dart';

final class ShopProductPageModel {
  const ShopProductPageModel({
    required this.products,
    required this.page,
    required this.perPage,
    required this.total,
    required this.totalPages,
  });

  final List<ShopProductModel> products;
  final int page;
  final int perPage;
  final int total;
  final int totalPages;

  factory ShopProductPageModel.fromJson(Map<String, dynamic> json) {
    final List<ShopProductModel> parsedProducts =
        JsonValueParser.list(json['data'])
            .map<ShopProductModel?>((dynamic item) {
              final Map<String, dynamic>? productJson = JsonValueParser.map(
                item,
              );

              if (productJson == null) {
                return null;
              }

              return ShopProductModel.fromJson(productJson);
            })
            .whereType<ShopProductModel>()
            .toList(growable: false);

    final int parsedPage = JsonValueParser.integer(json['page'], fallback: 1);

    final int parsedPerPage = JsonValueParser.integer(
      json['perPage'],
      fallback: 10,
    );

    final int parsedTotal = JsonValueParser.integer(json['total']);

    final int parsedTotalPages = JsonValueParser.integer(json['totalPages']);

    return ShopProductPageModel(
      products: parsedProducts,
      page: parsedPage < 1 ? 1 : parsedPage,
      perPage: parsedPerPage < 1 ? 10 : parsedPerPage,
      total: parsedTotal < 0 ? 0 : parsedTotal,
      totalPages: parsedTotalPages < 0 ? 0 : parsedTotalPages,
    );
  }

  PaginatedResult<ShopProductEntity> toEntity() {
    return PaginatedResult<ShopProductEntity>(
      items: List<ShopProductEntity>.unmodifiable(
        products.map((ShopProductModel product) {
          return product.toEntity();
        }),
      ),
      page: page,
      perPage: perPage,
      total: total,
      totalPages: totalPages,
    );
  }
}
