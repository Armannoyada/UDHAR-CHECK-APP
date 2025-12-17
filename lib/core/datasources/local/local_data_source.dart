import 'package:shared_preferences/shared_preferences.dart';
import 'package:injectable/injectable.dart';
import '../../error/exceptions.dart';

abstract class LocalDataSource {
  Future<void> saveString(String key, String value);
  Future<String?> getString(String key);
  Future<void> saveBool(String key, bool value);
  Future<bool?> getBool(String key);
  Future<void> remove(String key);
  Future<void> clear();
}

@LazySingleton(as: LocalDataSource)
class LocalDataSourceImpl implements LocalDataSource {
  final SharedPreferences sharedPreferences;

  LocalDataSourceImpl(this.sharedPreferences);

  @override
  Future<void> saveString(String key, String value) async {
    try {
      await sharedPreferences.setString(key, value);
    } catch (e) {
      throw CacheException('Failed to save data: $e');
    }
  }

  @override
  Future<String?> getString(String key) async {
    try {
      return sharedPreferences.getString(key);
    } catch (e) {
      throw CacheException('Failed to retrieve data: $e');
    }
  }

  @override
  Future<void> saveBool(String key, bool value) async {
    try {
      await sharedPreferences.setBool(key, value);
    } catch (e) {
      throw CacheException('Failed to save data: $e');
    }
  }

  @override
  Future<bool?> getBool(String key) async {
    try {
      return sharedPreferences.getBool(key);
    } catch (e) {
      throw CacheException('Failed to retrieve data: $e');
    }
  }

  @override
  Future<void> remove(String key) async {
    try {
      await sharedPreferences.remove(key);
    } catch (e) {
      throw CacheException('Failed to remove data: $e');
    }
  }

  @override
  Future<void> clear() async {
    try {
      await sharedPreferences.clear();
    } catch (e) {
      throw CacheException('Failed to clear data: $e');
    }
  }
}
