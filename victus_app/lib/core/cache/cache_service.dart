import 'package:hive_flutter/hive_flutter.dart';

class CacheService<T> {
  final String boxName;

  CacheService(this.boxName);

  Future<void> init() async {
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox<Map<dynamic, dynamic>>(boxName);
    }
  }

  Box<Map<dynamic, dynamic>> get _box => Hive.box<Map<dynamic, dynamic>>(boxName);

  Future<void> put(String key, T value, {Duration? duration}) async {
    final expiryTime = duration != null ? DateTime.now().add(duration).millisecondsSinceEpoch : null;
    await _box.put(key, {
      'value': value,
      'expiry': expiryTime,
    });
  }

  T? get(String key) {
    if (isExpired(key)) {
      remove(key);
      return null;
    }
    final data = _box.get(key);
    return data?['value'] as T?;
  }

  Future<void> remove(String key) async {
    await _box.delete(key);
  }

  Future<void> clear() async {
    await _box.clear();
  }

  bool isExpired(String key) {
    final data = _box.get(key);
    if (data == null) return true;
    final expiry = data['expiry'] as int?;
    if (expiry == null) return false;
    return DateTime.now().millisecondsSinceEpoch > expiry;
  }
}
