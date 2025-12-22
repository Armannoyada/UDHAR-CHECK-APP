import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/constants.dart';
import '../../core/error/exceptions.dart';
import '../models/auth_response.dart';
import '../models/user_model.dart';

/// Authentication API Service
class AuthService {

  AuthService(this._apiClient);
  final ApiClient _apiClient;

  /// Login user with email and password
  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.login,
        data: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return LoginResponse.fromJson(response.data);
      } else {
        throw ServerException(
          response.data['message'] ?? 'Login failed',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Register new user
  Future<RegisterResponse> register(RegisterRequest request) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.register,
        data: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return RegisterResponse.fromJson(response.data);
      } else {
        throw ServerException(
          response.data['message'] ?? 'Registration failed',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      await _apiClient.dio.post(ApiConstants.logout);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Refresh access token
  Future<RefreshTokenResponse> refreshToken(String refreshToken) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.refreshToken,
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return RefreshTokenResponse.fromJson(response.data);
      } else {
        throw ServerException(
          response.data['message'] ?? 'Token refresh failed',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get current user profile
  Future<User> getCurrentUser() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.profile);

      if (response.statusCode == 200) {
        return User.fromJson(response.data['user'] ?? response.data);
      } else {
        throw ServerException(
          response.data['message'] ?? 'Failed to get user profile',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Handle Dio errors
  Exception _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ServerException(
          ErrorMessages.timeout,
          statusCode: 408,
        );
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['message'] ?? 
                       error.response?.data?['error'] ??
                       _getDefaultErrorMessage(statusCode);
        return ServerException(
          message,
          statusCode: statusCode,
        );
      case DioExceptionType.connectionError:
        return ServerException(
          ErrorMessages.noInternet,
          statusCode: 0,
        );
      default:
        return ServerException(
          error.message ?? ErrorMessages.unknown,
          statusCode: 0,
        );
    }
  }

  String _getDefaultErrorMessage(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Invalid request. Please check your input.';
      case 401:
        return 'Invalid email or password.';
      case 403:
        return 'Access denied.';
      case 404:
        return 'Resource not found.';
      case 409:
        return 'User already exists with this email.';
      case 422:
        return 'Validation error. Please check your input.';
      case 500:
        return 'Server error. Please try again later.';
      default:
        return ErrorMessages.unknown;
    }
  }
}
