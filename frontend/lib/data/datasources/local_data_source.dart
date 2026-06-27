import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocalDataSource {
  final FlutterSecureStorage _storage;

  LocalDataSource(this._storage);

  Future<void> saveString(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> getString(String key) async {
    return _storage.read(key: key);
  }

  Future<void> saveMap(String key, Map<String, dynamic> value) async {
    await _storage.write(key: key, value: jsonEncode(value));
  }

  Future<Map<String, dynamic>?> getMap(String key) async {
    final value = await _storage.read(key: key);
    if (value == null) return null;
    return jsonDecode(value) as Map<String, dynamic>;
  }

  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
