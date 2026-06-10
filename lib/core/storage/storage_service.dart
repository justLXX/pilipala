import 'package:hive/hive.dart';
import 'package:pilipala/utils/storage.dart';

/// StorageService provides a type-safe wrapper around Hive storage.
///
/// This abstraction allows for:
/// - Easier testing (can be mocked)
/// - Type-safe storage operations
/// - Centralized storage logic
abstract class StorageService {
  Future<T?> get<T>(String key, {T? defaultValue});
  Future<void> set<T>(String key, T value);
  Future<void> remove(String key);
  Future<bool> contains(String key);
}

/// Implementation of StorageService using Hive.
///
/// Usage:
/// ```dart
/// final settings = HiveStorageService(GStrorage.setting);
/// final themeMode = await settings.get<int>('themeMode', defaultValue: 0);
/// ```
class HiveStorageService implements StorageService {
  final Box<dynamic> _box;

  HiveStorageService(this._box);

  @override
  Future<T?> get<T>(String key, {T? defaultValue}) async {
    final value = _box.get(key, defaultValue: defaultValue);
    return value as T?;
  }

  @override
  Future<void> set<T>(String key, T value) async {
    await _box.put(key, value);
  }

  @override
  Future<void> remove(String key) async {
    await _box.delete(key);
  }

  @override
  Future<bool> contains(String key) async {
    return _box.containsKey(key);
  }
}

/// Factory for creating storage services.
class StorageServiceFactory {
  static StorageService createSettingsStorage() {
    return HiveStorageService(GStrorage.setting);
  }

  static StorageService createUserStorage() {
    return HiveStorageService(GStrorage.userInfo);
  }

  static StorageService createLocalCacheStorage() {
    return HiveStorageService(GStrorage.localCache);
  }
}
