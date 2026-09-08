import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/json_value_parser.dart';
import '../../domain/entities/shop_product_entity.dart';

final class ShopProductModel {
  const ShopProductModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.genericName,
    required this.productCode,
    required this.sku,
    required this.coverImageUrl,
    required this.galleryUrls,
    required this.sellingPrice,
    required this.stock,
    required this.stockStatus,
    required this.prescriptionRequired,
    required this.featured,
    required this.shortDescription,
    required this.fullDescription,
    required this.tags,
    required this.sections,
    required this.publicationStatus,
    required this.isActive,
    this.discount,
    this.taxVatPercent,
    this.expiryDate,
    this.minimumOrder,
    this.bulkSellingPrice,
    this.category,
    this.type,
    this.company,
    this.currencyCode = '',
    this.countryCode = '',
  });

  final String id;
  final String name;
  final String slug;
  final String genericName;
  final String productCode;
  final String sku;

  final String coverImageUrl;
  final List<String> galleryUrls;

  final double sellingPrice;
  final double? discount;
  final double? taxVatPercent;
  final double? bulkSellingPrice;

  final int stock;
  final int? minimumOrder;

  final String stockStatus;
  final String publicationStatus;

  final bool prescriptionRequired;
  final bool featured;
  final bool isActive;

  final DateTime? expiryDate;

  final String shortDescription;
  final String fullDescription;

  final List<String> tags;
  final List<ShopProductSectionModel> sections;

  final ShopProductCategoryModel? category;
  final ShopProductTypeModel? type;
  final ShopProductCompanyModel? company;
  final String currencyCode;
  final String countryCode;

  factory ShopProductModel.fromJson(Map<String, dynamic> json) {
    final String publicImageUrl = JsonValueParser.string(json['imageSrc']);
    final bool? publicInStock = json['inStock'] is bool
        ? json['inStock'] as bool
        : null;

    return ShopProductModel(
      id: JsonValueParser.string(json['id']),
      name: JsonValueParser.string(json['name'], fallback: 'Unnamed Product'),
      slug: JsonValueParser.string(json['slug']),
      genericName: JsonValueParser.string(json['genericName']),
      productCode: JsonValueParser.string(json['productCode']),
      sku: JsonValueParser.string(json['sku']),
      coverImageUrl: ApiConstants.resolveMediaUrl(
        JsonValueParser.nullableString(json['coverImageUrl']) ??
            (publicImageUrl.isEmpty ? null : publicImageUrl),
      ),
      galleryUrls: JsonValueParser.stringList(json['galleryUrls'])
          .map<String>(ApiConstants.resolveMediaUrl)
          .where((String imageUrl) => imageUrl.isNotEmpty)
          .toList(growable: false),
      sellingPrice: JsonValueParser.decimal(
        json['sellingPrice'] ?? json['price'],
      ),
      discount: JsonValueParser.nullableDecimal(json['discount']),
      taxVatPercent: JsonValueParser.nullableDecimal(json['taxVatPercent']),
      bulkSellingPrice: JsonValueParser.nullableDecimal(
        json['bulkSellingPrice'],
      ),
      stock: json.containsKey('stock')
          ? JsonValueParser.integer(json['stock'])
          : (publicInStock == true ? 1 : 0),
      minimumOrder: JsonValueParser.nullableInteger(json['minimumOrder']),
      stockStatus: JsonValueParser.string(
        json['stockStatus'],
        fallback: publicInStock == null
            ? 'UNKNOWN'
            : (publicInStock ? 'IN_STOCK' : 'OUT_OF_STOCK'),
      ),
      publicationStatus: JsonValueParser.string(
        json['status'],
        fallback: 'UNKNOWN',
      ),
      prescriptionRequired: JsonValueParser.boolean(
        json['prescriptionRequired'],
      ),
      featured: JsonValueParser.boolean(json['featured']),
      isActive: JsonValueParser.boolean(json['isActive'], fallback: true),
      expiryDate: JsonValueParser.dateTime(json['expiryDate']),
      shortDescription: JsonValueParser.string(
        json['shortDescription'] ?? json['description'],
      ),
      fullDescription: JsonValueParser.string(json['fullDescription']),
      tags: JsonValueParser.stringList(json['tags']),
      sections: JsonValueParser.list(json['sections'])
          .map<ShopProductSectionModel?>((dynamic item) {
            final Map<String, dynamic>? sectionJson = JsonValueParser.map(item);

            if (sectionJson == null) {
              return null;
            }

            return ShopProductSectionModel.fromJson(sectionJson);
          })
          .whereType<ShopProductSectionModel>()
          .toList(growable: false),
      category: ShopProductCategoryModel.fromNullableJson(
        JsonValueParser.map(json['category']),
      ),
      type: ShopProductTypeModel.fromNullableJson(
        JsonValueParser.map(json['type']),
      ),
      company:
          ShopProductCompanyModel.fromNullableJson(
            JsonValueParser.map(json['company']),
          ) ??
          ShopProductCompanyModel.fromBrand(json['brand']),
      currencyCode: JsonValueParser.string(
        json['currencyCode'] ?? json['currency_code'] ?? json['currency'],
      ),
      countryCode: JsonValueParser.string(
        json['countryCode'] ?? json['country_code'] ?? json['country'],
      ),
    );
  }

  ShopProductEntity toEntity() {
    return ShopProductEntity(
      id: id,
      name: name,
      slug: slug,
      genericName: genericName,
      productCode: productCode,
      sku: sku,
      coverImageUrl: coverImageUrl,
      galleryUrls: List<String>.unmodifiable(galleryUrls),
      sellingPrice: sellingPrice,
      discount: discount,
      taxVatPercent: taxVatPercent,
      bulkSellingPrice: bulkSellingPrice,
      stock: stock,
      minimumOrder: minimumOrder,
      stockStatus: _mapStockStatus(stockStatus),
      publicationStatus: _mapPublicationStatus(publicationStatus),
      prescriptionRequired: prescriptionRequired,
      featured: featured,
      isActive: isActive,
      expiryDate: expiryDate,
      shortDescription: shortDescription,
      fullDescription: fullDescription,
      tags: List<String>.unmodifiable(tags),
      sections: List<ShopProductSectionEntity>.unmodifiable(
        sections.map((ShopProductSectionModel section) {
          return section.toEntity();
        }),
      ),
      category: category?.toEntity(),
      type: type?.toEntity(),
      company: company?.toEntity(),
      currencyCode: currencyCode,
      countryCode: countryCode,
    );
  }

  static ShopProductStockStatus _mapStockStatus(String value) {
    return switch (value.trim().toUpperCase()) {
      'IN_STOCK' => ShopProductStockStatus.inStock,
      'LOW_STOCK' => ShopProductStockStatus.lowStock,
      'OUT_OF_STOCK' => ShopProductStockStatus.outOfStock,
      _ => ShopProductStockStatus.unknown,
    };
  }

  static ShopProductPublicationStatus _mapPublicationStatus(String value) {
    return switch (value.trim().toUpperCase()) {
      'DRAFT' => ShopProductPublicationStatus.draft,
      'PUBLISHED' => ShopProductPublicationStatus.published,
      _ => ShopProductPublicationStatus.unknown,
    };
  }
}

final class ShopProductCategoryModel {
  const ShopProductCategoryModel({required this.id, required this.name});

  final String id;
  final String name;

  static ShopProductCategoryModel? fromNullableJson(
    Map<String, dynamic>? json,
  ) {
    if (json == null) {
      return null;
    }

    return ShopProductCategoryModel(
      id: JsonValueParser.string(json['id']),
      name: JsonValueParser.string(json['name']),
    );
  }

  ShopProductCategoryEntity toEntity() {
    return ShopProductCategoryEntity(id: id, name: name);
  }
}

final class ShopProductTypeModel {
  const ShopProductTypeModel({required this.id, required this.name});

  final String id;
  final String name;

  static ShopProductTypeModel? fromNullableJson(Map<String, dynamic>? json) {
    if (json == null) {
      return null;
    }

    return ShopProductTypeModel(
      id: JsonValueParser.string(json['id']),
      name: JsonValueParser.string(json['name']),
    );
  }

  ShopProductTypeEntity toEntity() {
    return ShopProductTypeEntity(id: id, name: name);
  }
}

final class ShopProductCompanyModel {
  const ShopProductCompanyModel({
    required this.id,
    required this.companyName,
    required this.logoUrl,
  });

  final String id;
  final String companyName;
  final String logoUrl;

  static ShopProductCompanyModel? fromNullableJson(Map<String, dynamic>? json) {
    if (json == null) {
      return null;
    }

    return ShopProductCompanyModel(
      id: JsonValueParser.string(json['id']),
      companyName: JsonValueParser.string(json['companyName']),
      logoUrl: ApiConstants.resolveMediaUrl(
        JsonValueParser.nullableString(json['logoUrl']),
      ),
    );
  }

  static ShopProductCompanyModel? fromBrand(dynamic value) {
    final String brand = JsonValueParser.string(value);

    if (brand.isEmpty) {
      return null;
    }

    return ShopProductCompanyModel(id: '', companyName: brand, logoUrl: '');
  }

  ShopProductCompanyEntity toEntity() {
    return ShopProductCompanyEntity(
      id: id,
      companyName: companyName,
      logoUrl: logoUrl,
    );
  }
}

final class ShopProductSectionModel {
  const ShopProductSectionModel({
    required this.title,
    required this.icon,
    required this.colorHex,
    required this.content,
  });

  final String title;
  final String icon;
  final String colorHex;
  final String content;

  factory ShopProductSectionModel.fromJson(Map<String, dynamic> json) {
    return ShopProductSectionModel(
      title: JsonValueParser.string(json['title']),
      icon: JsonValueParser.string(json['icon']),
      colorHex: JsonValueParser.string(json['color'], fallback: '#0B83D9'),
      content: JsonValueParser.string(json['content']),
    );
  }

  ShopProductSectionEntity toEntity() {
    return ShopProductSectionEntity(
      title: title,
      icon: icon,
      colorHex: colorHex,
      content: content,
    );
  }
}
