import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../core/network/api_client.dart';
import '../models/notification_model.dart';

@lazySingleton
class NotificationService {
  final ApiClient _apiClient;

  NotificationService(this._apiClient);

  Future<NotificationListResponse> getNotifications({
    int? page,
    int? limit,
    bool? unreadOnly,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;
      if (unreadOnly != null) queryParams['unreadOnly'] = unreadOnly;

      final response = await _apiClient.dio.get(
        '/notifications',
        queryParameters: queryParams,
      );

      return NotificationListResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<UnreadCountResponse> getUnreadCount() async {
    try {
      final response = await _apiClient.dio.get('/notifications/unread-count');
      return UnreadCountResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> markAsRead(String id) async {
    try {
      final response = await _apiClient.dio.put('/notifications/$id/read');
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> markAllAsRead() async {
    try {
      final response = await _apiClient.dio.put('/notifications/read-all');
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> deleteNotification(String id) async {
    try {
      final response = await _apiClient.dio.delete('/notifications/$id');
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      if (data is Map && data['message'] != null) {
        return Exception(data['message']);
      }
      return Exception('Request failed with status: ${e.response!.statusCode}');
    }
    return Exception(e.message ?? 'Network error occurred');
  }
}
