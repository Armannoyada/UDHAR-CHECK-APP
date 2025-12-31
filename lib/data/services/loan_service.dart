import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../core/network/api_client.dart';
import '../models/loan_model.dart';

@lazySingleton
class LoanService {
  final ApiClient _apiClient;

  LoanService(this._apiClient);

  /// Get pending loan requests for lenders
  Future<LoanListResponse> getPendingLoanRequests({
    double? minAmount,
    double? maxAmount,
    String? sortBy,
    String? order,
    int? page,
    int? limit,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (minAmount != null) queryParams['minAmount'] = minAmount;
      if (maxAmount != null) queryParams['maxAmount'] = maxAmount;
      if (sortBy != null) queryParams['sortBy'] = sortBy;
      if (order != null) queryParams['order'] = order;
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;

      final response = await _apiClient.dio.get(
        '/loans/pending',
        queryParameters: queryParams,
      );

      return LoanListResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get my lending history (for lenders)
  Future<LoanListResponse> getMyLending({
    String? status,
    int? page,
    int? limit,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null && status != 'all') queryParams['status'] = status;
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;

      final response = await _apiClient.dio.get(
        '/loans/my-lending',
        queryParameters: queryParams,
      );

      return LoanListResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get my loan requests (for borrowers)
  Future<LoanListResponse> getMyRequests({
    String? status,
    int? page,
    int? limit,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null && status != 'all') queryParams['status'] = status;
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;

      final response = await _apiClient.dio.get(
        '/loans/my-requests',
        queryParameters: queryParams,
      );

      return LoanListResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get loan by ID
  Future<LoanResponse> getLoanById(String id) async {
    try {
      final response = await _apiClient.dio.get('/loans/$id');
      return LoanResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Create a new loan request (borrower)
  Future<LoanResponse> createLoanRequest(CreateLoanRequest request) async {
    try {
      final response = await _apiClient.dio.post(
        '/loans/request',
        data: request.toJson(),
      );
      return LoanResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Accept a loan request (lender)
  Future<LoanResponse> acceptLoan(String loanId) async {
    try {
      final response = await _apiClient.dio.post('/loans/$loanId/accept');
      return LoanResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Reject a loan request (lender)
  Future<LoanResponse> rejectLoan(String loanId, String reason) async {
    try {
      final response = await _apiClient.dio.post(
        '/loans/$loanId/reject',
        data: {'reason': reason},
      );
      return LoanResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Mark loan as fulfilled (money received)
  Future<LoanResponse> fulfillLoan(String loanId) async {
    try {
      final response = await _apiClient.dio.post('/loans/$loanId/fulfill');
      return LoanResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Cancel a loan request (borrower)
  Future<LoanResponse> cancelLoan(String loanId, String reason) async {
    try {
      final response = await _apiClient.dio.post(
        '/loans/$loanId/cancel',
        data: {'reason': reason},
      );
      return LoanResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Record a repayment (lender)
  Future<LoanResponse> recordRepayment(String loanId, double amount) async {
    try {
      final response = await _apiClient.dio.post(
        '/loans/$loanId/repayment',
        data: {'amount': amount},
      );
      return LoanResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Rate user after loan completion
  Future<LoanResponse> rateLoan(
    String loanId, {
    required int rating,
    String? review,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/loans/$loanId/rate',
        data: {
          'rating': rating,
          if (review != null) 'review': review,
        },
      );
      return LoanResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get lender dashboard stats
  Future<Map<String, dynamic>> getLenderDashboardStats() async {
    try {
      final response = await _apiClient.dio.get('/loans/lender/stats');
      return response.data['data'] ?? {};
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  String _handleDioError(DioException e) {
    if (e.response?.data != null && e.response?.data['message'] != null) {
      return e.response!.data['message'];
    }
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.connectionError:
        return 'Connection error. Please check if the server is running.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
