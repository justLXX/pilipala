/// 接口数据解析工具类
/// 以兼容方式处理 API 返回的数据，支持 String/int/double/bool 等多种类型转换
class ParseUtils {
  ParseUtils._();

  /// 解析为 int?
  static int? toInt(dynamic value, {int? defaultValue}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is String) {
      final result = int.tryParse(value);
      return result ?? defaultValue;
    }
    if (value is double) return value.toInt();
    return defaultValue;
  }

  /// 解析为 int（非空）
  static int toIntNonNull(dynamic value, {int defaultValue = 0}) {
    return toInt(value, defaultValue: defaultValue) ?? defaultValue;
  }

  /// 解析为 String?
  static String? toStr(dynamic value, {String? defaultValue}) {
    if (value == null) return defaultValue;
    if (value is String) return value;
    return value.toString();
  }

  /// 解析为 String（非空）
  static String toStringNonNull(dynamic value, {String defaultValue = ''}) {
    return toStr(value, defaultValue: defaultValue) ?? defaultValue;
  }

  /// 解析为 double?
  static double? toDouble(dynamic value, {double? defaultValue}) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      final result = double.tryParse(value);
      return result ?? defaultValue;
    }
    return defaultValue;
  }

  /// 解析为 bool?
  /// 支持: true/false, 1/0, "1"/"0", "true"/"false"
  static bool? toBool(dynamic value, {bool? defaultValue}) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      if (value == '1' || value.toLowerCase() == 'true') return true;
      if (value == '0' || value.toLowerCase() == 'false') return false;
      return defaultValue;
    }
    return defaultValue;
  }

  /// 解析为 bool（非空）
  static bool toBoolNonNull(dynamic value, {bool defaultValue = false}) {
    return toBool(value, defaultValue: defaultValue) ?? defaultValue;
  }

  /// 解析为 List<T>
  static List<T>? toList<T>(
    dynamic value, {
    required T Function(dynamic) parser,
  }) {
    if (value == null) return null;
    if (value is List) {
      return value.map((e) => parser(e)).toList();
    }
    return null;
  }

  /// 解析为 Map
  static Map<K, V>? toMap<K, V>(dynamic value) {
    if (value == null) return null;
    if (value is Map) {
      return value as Map<K, V>;
    }
    return null;
  }
}
