import 'package:flutter/foundation.dart';

@immutable
class FavoriteProduct {
  const FavoriteProduct({
    required this.id,
    required this.name,
    required this.image,
    required this.description,
    required this.brand,
    required this.price,
  });

  final String id;
  final String name;
  final String image;
  final String description;
  final String brand;
  final int price;
}

class FavoriteStore extends ChangeNotifier {
  FavoriteStore._();

  static final FavoriteStore instance = FavoriteStore._();

  final Map<String, FavoriteProduct> _items = <String, FavoriteProduct>{};

  List<FavoriteProduct> get items =>
      List<FavoriteProduct>.unmodifiable(_items.values);

  int get count => _items.length;

  bool contains(String id) => _items.containsKey(id);

  void toggle(FavoriteProduct product) {
    if (_items.containsKey(product.id)) {
      _items.remove(product.id);
    } else {
      _items[product.id] = product;
    }

    notifyListeners();
  }

  void remove(String id) {
    if (_items.remove(id) != null) {
      notifyListeners();
    }
  }
}
