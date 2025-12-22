import 'dart:io';
import 'package:dio/dio.dart';
import '../../core/utils/constants.dart';
import '../models/api_response.dart';
import '../models/user_model.dart';
import 'storage_service.dart';

class ApiService {
  ApiService._();
  static ApiService? _instance;
  late final Dio _dio;
  late final StorageService _storageService;

  static Future<ApiService> getInstance() async {
    if (_instance == null) {
      _instance = ApiService._();
      await _instance!._init();
    }
    return _instance!;
  }

  Future<void> _init() async {
    _storageService = await StorageService.getInstance();

    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storageService.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          await _storageService.clearSession();
        }
        return handler.next(error);
      },
    ));
  }

  // Auth API calls
  Future<AuthResponse> login(String email, String password) async {
    final response = await _dio.post(
      ApiConstants.login,
      data: {'email': email, 'password': password},
    );
    return AuthResponse.fromJson(response.data);
  }

  Future<AuthResponse> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    final response = await _dio.post(
      ApiConstants.register,
      data: {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phone': phone,
        'password': password,
        'role': role,
      },
    );
    return AuthResponse.fromJson(response.data);
  }

  Future<void> logout() async {
    try {
      await _dio.post(ApiConstants.logout);
    } finally {
      await _storageService.clearSession();
    }
  }

  Future<ApiResponse> forgotPassword(String email) async {
    final response = await _dio.post(
      ApiConstants.forgotPassword,
      data: {'email': email},
    );
    return ApiResponse.fromJson(response.data, null);
  }

  // User Profile
  Future<User> getProfile() async {
    final response = await _dio.get(ApiConstants.profile);
    return User.fromJson(response.data['user'] ?? response.data['data'] ?? response.data);
  }

  Future<User> updateProfile(Map<String, dynamic> data) async {
    final response = await _dio.put(
      ApiConstants.updateProfile,
      data: data,
    );
    return User.fromJson(response.data['user'] ?? response.data['data'] ?? response.data);
  }

  Future<String> uploadProfilePhoto(File file) async {
    final formData = FormData.fromMap({
      'photo': await MultipartFile.fromFile(file.path),
    });
    final response = await _dio.post(
      ApiConstants.uploadProfilePhoto,
      data: formData,
    );
    return response.data['url'] ?? response.data['photoUrl'] ?? '';
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _dio.post(
      '${ApiConstants.profile}/change-password',
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );
  }

  // Onboarding/KYC
  Future<ApiResponse> submitOnboarding({
    required String dateOfBirth,
    required String gender,
    required String city,
    required String state,
    required String pincode,
    required String aadhaarNumber,
    required String panNumber,
  }) async {
    final response = await _dio.post(
      '${ApiConstants.baseUrl}/onboarding/submit',
      data: {
        'dateOfBirth': dateOfBirth,
        'gender': gender,
        'city': city,
        'state': state,
        'pincode': pincode,
        'aadhaarNumber': aadhaarNumber,
        'panNumber': panNumber,
      },
    );
    return ApiResponse.fromJson(response.data, null);
  }

  Future<String> uploadDocument(File file, String documentType) async {
    final formData = FormData.fromMap({
      'document': await MultipartFile.fromFile(file.path),
      'type': documentType,
    });
    final response = await _dio.post(
      ApiConstants.uploadDocument,
      data: formData,
    );
    return response.data['url'] ?? '';
  }

  Future<Map<String, dynamic>> getVerificationStatus() async {
    final response = await _dio.get(ApiConstants.verificationStatus);
    return response.data;
  }

  // Dashboard Stats
  Future<DashboardStats> getDashboardStats() async {
    final response = await _dio.get('/api/dashboard/stats');
    return DashboardStats.fromJson(response.data);
  }

  // TODO: Add loan, notification, report, and admin methods when models are implemented
}
