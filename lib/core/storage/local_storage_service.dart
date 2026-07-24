import 'package:get_storage/get_storage.dart';

class LocalStorageService {
  LocalStorageService({GetStorage? storage})
    : _storage = storage ?? GetStorage(_containerName);

  static const String _containerName = 'at_pharma_storage';

  final GetStorage _storage;

  /// Must be called before using GetStorage.
  static Future<void> initialize() async {
    await GetStorage.init(_containerName);
  }

  bool containsKey(String key) {
    return _storage.hasData(key);
  }

  T? read<T>(String key) {
    final dynamic value = _storage.read<dynamic>(key);

    if (value is T) {
      return value;
    }

    return null;
  }

  String? readString(String key) {
    final dynamic value = _storage.read<dynamic>(key);

    if (value is! String) {
      return null;
    }

    final String normalizedValue = value.trim();

    return normalizedValue.isEmpty ? null : normalizedValue;
  }

  bool? readBool(String key) {
    final dynamic value = _storage.read<dynamic>(key);

    if (value is bool) {
      return value;
    }

    if (value is String) {
      final String normalizedValue = value.trim().toLowerCase();

      if (normalizedValue == 'true') {
        return true;
      }

      if (normalizedValue == 'false') {
        return false;
      }
    }

    return null;
  }

  int? readInt(String key) {
    final dynamic value = _storage.read<dynamic>(key);

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    if (value is String) {
      return int.tryParse(value);
    }

    return null;
  }

  double? readDouble(String key) {
    final dynamic value = _storage.read<dynamic>(key);

    if (value is double) {
      return value;
    }

    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      return double.tryParse(value);
    }

    return null;
  }

  Map<String, dynamic>? readMap(String key) {
    final dynamic value = _storage.read<dynamic>(key);

    if (value is Map<String, dynamic>) {
      return Map<String, dynamic>.unmodifiable(value);
    }

    if (value is Map) {
      return Map<String, dynamic>.unmodifiable(
        value.map((dynamic mapKey, dynamic mapValue) {
          return MapEntry<String, dynamic>(mapKey.toString(), mapValue);
        }),
      );
    }

    return null;
  }

  List<dynamic>? readList(String key) {
    final dynamic value = _storage.read<dynamic>(key);

    if (value is List<dynamic>) {
      return List<dynamic>.unmodifiable(value);
    }

    if (value is List) {
      return List<dynamic>.unmodifiable(value);
    }

    return null;
  }

  Future<void> write<T>({required String key, required T value}) async {
    await _storage.write(key, value);
  }

  Future<void> writeMap({
    required String key,
    required Map<String, dynamic> value,
  }) async {
    await _storage.write(key, Map<String, dynamic>.from(value));
  }

  Future<void> remove(String key) async {
    await _storage.remove(key);
  }

  Future<void> removeAll(Iterable<String> keys) async {
    for (final String key in keys) {
      await _storage.remove(key);
    }
  }

  Future<void> clearAll() async {
    await _storage.erase();
  }
}
