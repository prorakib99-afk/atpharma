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

      _categories = List<ShopCategory>.unmodifiable(
        _mergeMedicineCategories(loaded),
      );
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

  List<ShopCategory> _mergeMedicineCategories(List<ShopCategory> source) {
    const Set<String> medicineNames = <String>{
      'medecine',
      'medicine',
      'medicines',
      'medical equipments',
    };
    final List<ShopCategory> medicines = source
        .where((ShopCategory category) {
          return medicineNames.contains(category.name.toLowerCase());
        })
        .toList(growable: false);

    if (medicines.isEmpty) {
      return source;
    }

    final ShopCategory primary = medicines.firstWhere(
      (ShopCategory category) => category.name.toLowerCase() == 'medicines',
      orElse: () => medicines.first,
    );
    final int insertIndex = source.indexWhere(
      (ShopCategory category) =>
          medicineNames.contains(category.name.toLowerCase()),
    );
    final List<ShopCategory> result = source
        .where(
          (ShopCategory category) =>
              !medicineNames.contains(category.name.toLowerCase()),
        )
        .toList(growable: true);
    final ShopCategory merged = ShopCategory(
      id: primary.id,
      name: 'Medicines',
      count: medicines.fold<int>(
        0,
        (int total, ShopCategory category) => total + category.count,
      ),
      additionalIds: medicines
          .where((ShopCategory category) => category.id != primary.id)
          .map((ShopCategory category) => category.id)
          .toList(growable: false),
    );

    result.insert(insertIndex.clamp(0, result.length), merged);
    return result;
  }
}
