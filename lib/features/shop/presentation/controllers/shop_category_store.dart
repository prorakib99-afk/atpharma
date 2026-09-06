import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/network/api_request_options.dart';
import '../../../../core/network/dio_client.dart';

final class ShopCategory {
  const ShopCategory({
    required this.id,
    required this.name,
    required this.count,
    this.additionalIds = const <String>[],
  });

  final String id;
  final String name;
  final int count;
  final List<String> additionalIds;

  List<String> get filterIds {
    return <String>[id, ...additionalIds];
  }
}

final class ShopCategoryStore extends ChangeNotifier {
  ShopCategoryStore._();

  static final ShopCategoryStore instance = ShopCategoryStore._();

  List<ShopCategory> _categories = const <ShopCategory>[];
  bool _isLoading = false;
  String? _errorMessage;
  int _totalProducts = 0;

  UnmodifiableListView<ShopCategory> get categories {
    return UnmodifiableListView<ShopCategory>(_categories);
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get totalProducts => _totalProducts;

  Future<void> load({bool force = false}) async {
    if (_isLoading || (!force && _categories.isNotEmpty)) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await sl<DioClient>().get<dynamic>(
        ShopCatalogEndpoints.categories,
        options: ApiRequestOptions.publicRequest(),
      );
      final dynamic data = response.data;

      if (data is! Map || data['categories'] is! List) {
        throw const FormatException('Invalid category response.');
      }

      final List<ShopCategory> loaded = <ShopCategory>[];

      for (final dynamic item in data['categories'] as List) {
        if (item is! Map) {
          continue;
        }

        final String id = item['id']?.toString().trim() ?? '';
        final String name = item['name']?.toString().trim() ?? '';
        final int count = int.tryParse(item['count']?.toString() ?? '') ?? 0;

        if (id.isNotEmpty && name.isNotEmpty) {
          loaded.add(ShopCategory(id: id, name: name, count: count));
        }
      }

      _categories = List<ShopCategory>.unmodifiable(_groupCategories(loaded));
      _totalProducts =
          int.tryParse(data['total']?.toString() ?? '') ??
          loaded.fold<int>(0, (int sum, ShopCategory item) => sum + item.count);
    } catch (_) {
      _errorMessage = 'Unable to load categories.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<ShopCategory> _groupCategories(List<ShopCategory> source) {
    const List<String> groupOrder = <String>[
      'Medicines',
      'Grocery',
      'Personal Care',
      'Baby Care',
      'Ayurvedic & Herbal',
    ];
    final Map<String, List<ShopCategory>> groups = <String, List<ShopCategory>>{
      for (final String name in groupOrder) name: <ShopCategory>[],
    };

    for (final ShopCategory category in source) {
      groups[_groupNameFor(category.name)]!.add(category);
    }

    return groupOrder
        .map((String groupName) {
          final List<ShopCategory> members = groups[groupName]!;
          return ShopCategory(
            id: members.isEmpty
                ? 'missing:${groupName.toLowerCase()}'
                : members.first.id,
            name: groupName,
            count: members.fold<int>(
              0,
              (int total, ShopCategory category) => total + category.count,
            ),
            additionalIds: members
                .skip(1)
                .map((ShopCategory category) => category.id)
                .toList(growable: false),
          );
        })
        .toList(growable: false);
  }

  String _groupNameFor(String categoryName) {
    final String name = categoryName.toLowerCase();
    if (name.contains('baby')) return 'Baby Care';
    if (name.contains('ayurvedic') || name.contains('herbal')) {
      return 'Ayurvedic & Herbal';
    }
    if (name.contains('cosmetic') ||
        name.contains('toiletr') ||
        name.contains('personal')) {
      return 'Personal Care';
    }
    if (name.contains('general') || name.contains('grocery')) {
      return 'Grocery';
    }
    return 'Medicines';
  }
}
