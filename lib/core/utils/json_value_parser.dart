abstract final class JsonValueParser {
  JsonValueParser._();

  static String string(dynamic value, {String fallback = ''}) {
    if (value == null || value is Map || value is List) {
      return fallback;
    }

    final String normalizedValue = value.toString().trim();

    return normalizedValue.isEmpty ? fallback : normalizedValue;
  }

  static String? nullableString(dynamic value) {
    if (value == null) {
      return null;
    }

    final String normalizedValue = value.toString().trim();

    return normalizedValue.isEmpty ? null : normalizedValue;
  }

  static int integer(dynamic value, {int fallback = 0}) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    if (value is String) {
      return int.tryParse(value.trim()) ??
          double.tryParse(value.trim())?.toInt() ??
          fallback;
    }

    return fallback;
  }

  static int? nullableInteger(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    if (value is String) {
      final String normalizedValue = value.trim();

      if (normalizedValue.isEmpty) {
        return null;
      }

      return int.tryParse(normalizedValue) ??
          double.tryParse(normalizedValue)?.toInt();
    }

    return null;
  }

  static double decimal(dynamic value, {double fallback = 0}) {
    if (value is double) {
      return value;
    }

    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      return double.tryParse(value.trim()) ?? fallback;
    }

    return fallback;
  }

  static double? nullableDecimal(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is double) {
      return value;
    }

    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      final String normalizedValue = value.trim();

      if (normalizedValue.isEmpty) {
        return null;
      }

      return double.tryParse(normalizedValue);
    }

    return null;
  }

  static bool boolean(dynamic value, {bool fallback = false}) {
    if (value is bool) {
      return value;
    }

    if (value is num) {
      return value != 0;
    }

    if (value is String) {
      final String normalizedValue = value.trim().toLowerCase();

      if (normalizedValue == 'true' ||
          normalizedValue == '1' ||
          normalizedValue == 'yes') {
        return true;
      }

      if (normalizedValue == 'false' ||
          normalizedValue == '0' ||
          normalizedValue == 'no') {
        return false;
      }
    }

    return fallback;
  }

  static DateTime? dateTime(dynamic value) {
    final String? normalizedValue = nullableString(value);

    if (normalizedValue == null) {
      return null;
    }

    return DateTime.tryParse(normalizedValue);
  }

  static Map<String, dynamic>? map(dynamic value) {
    if (value is Map<String, dynamic>) {
      return Map<String, dynamic>.from(value);
    }

    if (value is Map) {
      return value.map<String, dynamic>((dynamic key, dynamic item) {
        return MapEntry<String, dynamic>(key.toString(), item);
      });
    }

    return null;
  }

  static List<dynamic> list(dynamic value) {
    if (value is List<dynamic>) {
      return List<dynamic>.from(value);
    }

    if (value is List) {
      return List<dynamic>.from(value);
    }

    return const <dynamic>[];
  }

  static List<String> stringList(dynamic value) {
    return list(value)
        .map<String>((dynamic item) => string(item))
        .where((String item) => item.isNotEmpty)
        .toList(growable: false);
  }
}
