import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/utils/constants.dart';
import '../models/user_model.dart';

class StorageService {

  StorageService._();
  static StorageService? _instance;
  static SharedPreferences? _prefs;
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  static Future<StorageService> getInstance() async {
    _instance ??= StorageService._();
    _prefs ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  // Secure Storage Methods (for sensitive data)
  Future<void> saveAccessToken(String token) async {
    await _secureStorage.write(key: StorageKeys.accessToken, value: token);
  }

  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: StorageKeys.accessToken);
  }

  Future<void> saveRefreshToken(String token) async {
    await _secureStorage.write(key: StorageKeys.refreshToken, value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: StorageKeys.refreshToken);
  }

  Future<void> clearTokens() async {
    await _secureStorage.delete(key: StorageKeys.accessToken);
    await _secureStorage.delete(key: StorageKeys.refreshToken);
  }

  // Shared Preferences Methods
  Future<void> saveUserId(String id) async {
    await _prefs?.setString(StorageKeys.userId, id);
  }

  String? getUserId() {
    return _prefs?.getString(StorageKeys.userId);
  }

  Future<void> saveUserRole(String role) async {
    await _prefs?.setString(StorageKeys.userRole, role);
  }

  String? getUserRole() {
    return _prefs?.getString(StorageKeys.userRole);
  }

  Future<void> setLoggedIn(bool value) async {
    await _prefs?.setBool(StorageKeys.isLoggedIn, value);
  }

  bool isLoggedIn() {
    return _prefs?.getBool(StorageKeys.isLoggedIn) ?? false;
  }

  Future<void> setOnboarded(bool value) async {
    await _prefs?.setBool(StorageKeys.isOnboarded, value);
  }

  bool isOnboarded() {
    return _prefs?.getBool(StorageKeys.isOnboarded) ?? false;
  }

  Future<void> setVerified(bool value) async {
    await _prefs?.setBool(StorageKeys.isVerified, value);
  }

  bool isVerified() {
    return _prefs?.getBool(StorageKeys.isVerified) ?? false;
  }

  Future<void> saveUserData(User user) async {
    await _prefs?.setString(StorageKeys.userData, jsonEncode(user.toJson()));
  }

  User? getUserData() {
    final data = _prefs?.getString(StorageKeys.userData);
    if (data != null) {
      return User.fromJson(jsonDecode(data));
    }
    return null;
  }

  Future<void> saveTheme(String theme) async {
    await _prefs?.setString(StorageKeys.theme, theme);
  }

  String getTheme() {
    return _prefs?.getString(StorageKeys.theme) ?? 'system';
  }

  // Clear all data
  Future<void> clearAll() async {
    await clearTokens();
    await _prefs?.clear();
  }

  // Clear user session
  Future<void> clearSession() async {
    await clearTokens();
    await _prefs?.remove(StorageKeys.userId);
    await _prefs?.remove(StorageKeys.userRole);
    await _prefs?.remove(StorageKeys.userData);
    await _prefs?.setBool(StorageKeys.isLoggedIn, false);
  }
}
