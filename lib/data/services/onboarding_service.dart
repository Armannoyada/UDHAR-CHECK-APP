import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/constants.dart';
import '../../core/error/exceptions.dart';
import '../models/user_model.dart';

/// Onboarding API Service
class OnboardingService {

  OnboardingService(this._apiClient);
  final ApiClient _apiClient;

  /// Submit onboarding data with files
  Future<OnboardingResponse> submitOnboarding({
    required String streetAddress,
    required String city,
    required String state,
    required String pincode,
    required String idType,
    required String idNumber,
    required String documentPath,
    required String selfiePath,
    double? maxLendingAmount,
    bool? termsAccepted,
  }) async {
    try {
      // Create form data for multipart upload
      final formData = FormData.fromMap({
        'address': streetAddress,
        'city': city,
        'state': state,
        'pincode': pincode,
        'governmentIdType': idType,
        'governmentIdNumber': idNumber,
        if (maxLendingAmount != null) 'lendingLimit': maxLendingAmount,
        if (termsAccepted != null) 'termsAccepted': termsAccepted,
      });

      // Add document file
      if (documentPath.isNotEmpty) {
        final documentFile = File(documentPath);
        if (await documentFile.exists()) {
          final fileName = documentPath.split(Platform.pathSeparator).last;
          final extension = fileName.split('.').last.toLowerCase();
          
          MediaType? mediaType;
          if (extension == 'pdf') {
            mediaType = MediaType('application', 'pdf');
          } else if (extension == 'jpg' || extension == 'jpeg') {
            mediaType = MediaType('image', 'jpeg');
          } else if (extension == 'png') {
            mediaType = MediaType('image', 'png');
          }

          formData.files.add(MapEntry(
            'governmentId',
            await MultipartFile.fromFile(
              documentPath,
              filename: fileName,
              contentType: mediaType,
            ),
          ));
        }
      }

      // Add selfie file
      if (selfiePath.isNotEmpty) {
        final selfieFile = File(selfiePath);
        if (await selfieFile.exists()) {
          final fileName = selfiePath.split(Platform.pathSeparator).last;
          final extension = fileName.split('.').last.toLowerCase();
          
          MediaType? mediaType;
          if (extension == 'jpg' || extension == 'jpeg') {
            mediaType = MediaType('image', 'jpeg');
          } else if (extension == 'png') {
            mediaType = MediaType('image', 'png');
          }

          formData.files.add(MapEntry(
            'selfie',
            await MultipartFile.fromFile(
              selfiePath,
              filename: fileName,
              contentType: mediaType,
            ),
          ));
        }
      }

      final response = await _apiClient.dio.post(
        '/auth/onboarding',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return OnboardingResponse.fromJson(response.data);
      } else {
        throw ServerException(
          response.data['message'] ?? 'Onboarding failed',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Upload document separately
  Future<String> uploadDocument({
    required String filePath,
    required String documentType,
  }) async {
    try {
      final file = File(filePath);
      final fileName = filePath.split(Platform.pathSeparator).last;

      final formData = FormData.fromMap({
        'documentType': documentType,
        'file': await MultipartFile.fromFile(
          filePath,
          filename: fileName,
        ),
      });

      final response = await _apiClient.dio.post(
        ApiConstants.uploadDocument,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data['url'] ?? response.data['path'] ?? '';
      } else {
        throw ServerException(
          response.data['message'] ?? 'Document upload failed',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Upload selfie separately
  Future<String> uploadSelfie({
    required String filePath,
  }) async {
    try {
      final file = File(filePath);
      final fileName = filePath.split(Platform.pathSeparator).last;

      final formData = FormData.fromMap({
        'selfie': await MultipartFile.fromFile(
          filePath,
          filename: fileName,
        ),
      });

      final response = await _apiClient.dio.post(
        '${ApiConstants.onboarding}/selfie',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data['url'] ?? response.data['path'] ?? '';
      } else {
        throw ServerException(
          response.data['message'] ?? 'Selfie upload failed',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get verification status
  Future<Map<String, dynamic>> getVerificationStatus() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.verificationStatus);

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw ServerException(
          response.data['message'] ?? 'Failed to get verification status',
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
            'Request failed';
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
}

/// Onboarding Response Model
class OnboardingResponse {

  OnboardingResponse({
    required this.success,
    this.message,
    this.user,
  });

  factory OnboardingResponse.fromJson(Map<String, dynamic> json) {
    return OnboardingResponse(
      success: json['success'] ?? false,
      message: json['message'],
      user: json['data'] != null ? User.fromJson(json['data']) : null,
    );
  }
  final bool success;
  final String? message;
  final User? user;
}
