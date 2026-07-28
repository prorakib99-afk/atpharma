import 'package:flutter/foundation.dart';

import '../../../../core/storage/local_storage_service.dart';

@immutable
class FavoriteProduct {
  const FavoriteProduct({
    required this.id,
    required this.name,
    required this.image,
    required this.description,
    required this.brand,
    required this.price,
    this.isOutOfStock = false,
  });

  final String id;
  final String name;
  final String image;
  final String description;
  final String brand;
  final int price;
  final bool isOutOfStock;
}

class FavoriteStore extends ChangeNotifier {
  FavoriteStore._();

  static final FavoriteStore instance = FavoriteStore._();
  static const String _storageKey = 'favorite_products';

  final Map<String, FavoriteProduct> _items = <String, FavoriteProduct>{};
  LocalStorageService? _storage;

  Future<void> initialize(LocalStorageService storage) async {
    _storage = storage;
    final List<dynamic> rows = storage.readList(_storageKey) ?? <dynamic>[];
    _items
      ..clear()
      ..addEntries(rows.whereType<Map>().map((Map<dynamic, dynamic> rawRow) {
        final Map<String, dynamic> row = rawRow.map(
          (dynamic key, dynamic value) =>
              MapEntry<String, dynamic>(key.toString(), value),
        );
        final String id = row['id']?.toString() ?? '';
        return MapEntry<String, FavoriteProduct>(
          id,
          FavoriteProduct(
            id: id,
            name: row['name']?.toString() ?? '',
            image: row['image']?.toString() ?? '',
            description: row['description']?.toString() ?? '',
            brand: row['brand']?.toString() ?? '',
            price: (row['price'] as num?)?.toInt() ?? 0,
            isOutOfStock: row['isOutOfStock'] == true,
          ),
        );
      }).where((MapEntry<String, FavoriteProduct> entry) {
        return entry.key.isNotEmpty;
      }));
    notifyListeners();
  }

  List<FavoriteProduct> get items =>
      List<FavoriteProduct>.unmodifiable(_items.values);

  int get count => _items.length;

  bool contains(String id) => _items.containsKey(id);

  Future<void> toggle(FavoriteProduct product) async {
    if (_items.containsKey(product.id)) {
      _items.remove(product.id);
    } else {
      _items[product.id] = product;
    }

    notifyListeners();
    await _persist();
  }

  Future<void> remove(String id) async {
    if (_items.remove(id) != null) {
      notifyListeners();
      await _persist();
    }
  }

  Future<void> _persist() async {
    final LocalStorageService? storage = _storage;
    if (storage == null) return;
    await storage.write<List<Map<String, Object?>>>(
      key: _storageKey,
      value: _items.values.map((FavoriteProduct product) {
        return <String, Object?>{
          'id': product.id,
          'name': product.name,
          'image': product.image,
          'description': product.description,
          'brand': product.brand,
          'price': product.price,
          'isOutOfStock': product.isOutOfStock,
        };
      }).toList(growable: false),
    );
  }
}
