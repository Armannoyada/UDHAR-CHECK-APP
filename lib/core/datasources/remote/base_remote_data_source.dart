// Example base remote data source
// This file shows the structure for API calls

import 'package:dio/dio.dart';
import '../../error/exceptions.dart';

abstract class BaseRemoteDataSource {
  Future<T> handleApiCall<T>(Future<Response<T>> Function() apiCall);
}

class BaseRemoteDataSourceImpl implements BaseRemoteDataSource {
  @override
  Future<T> handleApiCall<T>(Future<Response<T>> Function() apiCall) async {
    try {
      final response = await apiCall();
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as T;
      } else {
        throw ServerException(
          'Server returned ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  AppException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException('Request timeout');
      
      case DioExceptionType.connectionError:
        return NetworkException('No internet connection');
      
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        switch (statusCode) {
          case 401:
            return UnauthorizedException('Unauthorized');
          case 403:
            return ForbiddenException('Access forbidden');
          case 404:
            return NotFoundException('Resource not found');
          default:
            return ServerException(
              error.response?.data['message'] ?? 'Server error',
              statusCode: statusCode,
            );
        }
      
      default:
        return ServerException('Unexpected error occurred');
    }
  }
}
