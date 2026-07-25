import 'package:equatable/equatable.dart';

enum ShopProductStockStatus { inStock, lowStock, outOfStock, unknown }

enum ShopProductPublicationStatus { draft, published, unknown }

final class ShopProductEntity extends Equatable {
  const ShopProductEntity({
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

  final ShopProductStockStatus stockStatus;
  final ShopProductPublicationStatus publicationStatus;

  final bool prescriptionRequired;
  final bool featured;
  final bool isActive;

  final DateTime? expiryDate;

  final String shortDescription;
  final String fullDescription;

  final List<String> tags;
  final List<ShopProductSectionEntity> sections;

  final ShopProductCategoryEntity? category;
  final ShopProductTypeEntity? type;
  final ShopProductCompanyEntity? company;

  bool get isPublished {
    return publicationStatus == ShopProductPublicationStatus.published;
  }

  bool get isInStock {
    return stock > 0 && stockStatus != ShopProductStockStatus.outOfStock;
  }

  bool get isLowStock {
    return stockStatus == ShopProductStockStatus.lowStock;
  }

  bool get isOutOfStock {
    return stock <= 0 || stockStatus == ShopProductStockStatus.outOfStock;
  }

  bool get canAddToCart {
    return isActive && isPublished && isInStock;
  }

  bool get hasDiscount {
    return discount != null && discount! > 0;
  }

  bool get hasTax {
    return taxVatPercent != null && taxVatPercent! > 0;
  }

  bool get hasGallery {
    return galleryUrls.isNotEmpty;
  }

  bool get requiresPrescription {
    return prescriptionRequired;
  }

  String get displayCompanyName {
    final String companyName = company?.companyName.trim() ?? '';

    return companyName.isEmpty ? 'AT Pharma' : companyName;
  }

  String get displayCategoryName {
    final String categoryName = category?.name.trim() ?? '';

    return categoryName.isEmpty ? 'Healthcare' : categoryName;
  }

  String get displayDescription {
    final String shortText = shortDescription.trim();

    if (shortText.isNotEmpty) {
      return shortText;
    }

    final String fullText = fullDescription.trim();

    if (fullText.isNotEmpty) {
      return fullText;
    }

    return 'Quality healthcare product for everyday needs.';
  }

  String get primaryImageUrl {
    final String cover = coverImageUrl.trim();

    if (cover.isNotEmpty) {
      return cover;
    }

    for (final String imageUrl in galleryUrls) {
      final String normalizedImageUrl = imageUrl.trim();

      if (normalizedImageUrl.isNotEmpty) {
        return normalizedImageUrl;
      }
    }

    return '';
  }

  List<String> get allImageUrls {
    final Set<String> uniqueImages = <String>{};

    final String cover = coverImageUrl.trim();

    if (cover.isNotEmpty) {
      uniqueImages.add(cover);
    }

    for (final String imageUrl in galleryUrls) {
      final String normalizedImageUrl = imageUrl.trim();

      if (normalizedImageUrl.isNotEmpty) {
        uniqueImages.add(normalizedImageUrl);
      }
    }

    return List<String>.unmodifiable(uniqueImages);
  }

  int get cartMinimumQuantity {
    final int value = minimumOrder ?? 1;

    return value <= 0 ? 1 : value;
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    name,
    slug,
    genericName,
    productCode,
    sku,
    coverImageUrl,
    galleryUrls,
    sellingPrice,
    discount,
    taxVatPercent,
    bulkSellingPrice,
    stock,
    minimumOrder,
    stockStatus,
    publicationStatus,
    prescriptionRequired,
    featured,
    isActive,
    expiryDate,
    shortDescription,
    fullDescription,
    tags,
    sections,
    category,
    type,
    company,
  ];
}

final class ShopProductCategoryEntity extends Equatable {
  const ShopProductCategoryEntity({required this.id, required this.name});

  final String id;
  final String name;

  @override
  List<Object?> get props => <Object?>[id, name];
}

final class ShopProductTypeEntity extends Equatable {
  const ShopProductTypeEntity({required this.id, required this.name});

  final String id;
  final String name;

  @override
  List<Object?> get props => <Object?>[id, name];
}

final class ShopProductCompanyEntity extends Equatable {
  const ShopProductCompanyEntity({
    required this.id,
    required this.companyName,
    required this.logoUrl,
  });

  final String id;
  final String companyName;
  final String logoUrl;

  @override
  List<Object?> get props => <Object?>[id, companyName, logoUrl];
}

final class ShopProductSectionEntity extends Equatable {
  const ShopProductSectionEntity({
    required this.title,
    required this.icon,
    required this.colorHex,
    required this.content,
  });

  final String title;
  final String icon;
  final String colorHex;

  /// Backend currently returns HTML such as:
  /// `<p>...</p><ul><li>...</li></ul>`
  ///
  /// HTML-to-Flutter conversion will be handled in the presentation layer.
  final String content;

  bool get hasContent {
    return content.trim().isNotEmpty;
  }

  @override
  List<Object?> get props => <Object?>[title, icon, colorHex, content];
}
