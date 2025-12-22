import 'package:equatable/equatable.dart';
import 'user_model.dart';

class AuthResponse extends Equatable {
  const AuthResponse({
    required this.success,
    required this.user,
    required this.accessToken,
    this.refreshToken,
    this.message,
  });

  final bool success;
  final User user;
  final String accessToken;
  final String? refreshToken;
  final String? message;

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] ?? true,
      user: User.fromJson(json['user'] ?? json['data']?['user'] ?? {}),
      accessToken: json['accessToken'] ?? json['access_token'] ?? json['token'] ?? '',
      refreshToken: json['refreshToken'] ?? json['refresh_token'],
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'user': user.toJson(),
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'message': message,
    };
  }

  @override
  List<Object?> get props => [success, user, accessToken, refreshToken, message];
}

class ApiResponse<T> extends Equatable {
  const ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.errors,
  });

  final bool success;
  final T? data;
  final String? message;
  final List<String>? errors;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse(
      success: json['success'] ?? false,
      data: fromJsonT != null && json['data'] != null
          ? fromJsonT(json['data'])
          : json['data'],
      message: json['message'],
      errors: json['errors'] != null ? List<String>.from(json['errors']) : null,
    );
  }

  @override
  List<Object?> get props => [success, data, message, errors];
}

class PaginatedResponse<T> extends Equatable {
  const PaginatedResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  final List<T> items;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  bool get hasMore => page < totalPages;

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final itemsList = json['items'] ?? json['data'] ?? [];
    return PaginatedResponse(
      items: (itemsList as List).map((e) => fromJsonT(e)).toList(),
      total: json['total'] ?? json['totalCount'] ?? 0,
      page: json['page'] ?? json['currentPage'] ?? 1,
      limit: json['limit'] ?? json['perPage'] ?? 10,
      totalPages: json['totalPages'] ?? json['total_pages'] ?? 1,
    );
  }

  @override
  List<Object?> get props => [items, total, page, limit, totalPages];
}

class DashboardStats extends Equatable {
  const DashboardStats({
    this.totalLent = 0,
    this.availableBalance = 0,
    this.activeLoansCount = 0,
    this.completedLoansCount = 0,
    this.totalBorrowed = 0,
    this.activeBorrowingsCount = 0,
    this.pendingRequestsCount = 0,
    this.totalRepaid = 0,
    this.overdueCount = 0,
    this.totalUsers = 0,
    this.pendingVerifications = 0,
    this.totalActiveLoans = 0,
    this.totalDisputes = 0,
  });

  final double totalLent;
  final double availableBalance;
  final int activeLoansCount;
  final int completedLoansCount;
  final double totalBorrowed;
  final int activeBorrowingsCount;
  final int pendingRequestsCount;
  final double totalRepaid;
  final int overdueCount;
  final int totalUsers;
  final int pendingVerifications;
  final int totalActiveLoans;
  final int totalDisputes;

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalLent: (json['totalLent'] ?? json['total_lent'] ?? 0).toDouble(),
      availableBalance: (json['availableBalance'] ?? json['available_balance'] ?? 0).toDouble(),
      activeLoansCount: json['activeLoansCount'] ?? json['active_loans_count'] ?? 0,
      completedLoansCount: json['completedLoansCount'] ?? json['completed_loans_count'] ?? 0,
      totalBorrowed: (json['totalBorrowed'] ?? json['total_borrowed'] ?? 0).toDouble(),
      activeBorrowingsCount: json['activeBorrowingsCount'] ?? json['active_borrowings_count'] ?? 0,
      pendingRequestsCount: json['pendingRequestsCount'] ?? json['pending_requests_count'] ?? 0,
      totalRepaid: (json['totalRepaid'] ?? json['total_repaid'] ?? 0).toDouble(),
      overdueCount: json['overdueCount'] ?? json['overdue_count'] ?? 0,
      totalUsers: json['totalUsers'] ?? json['total_users'] ?? 0,
      pendingVerifications: json['pendingVerifications'] ?? json['pending_verifications'] ?? 0,
      totalActiveLoans: json['totalActiveLoans'] ?? json['total_active_loans'] ?? 0,
      totalDisputes: json['totalDisputes'] ?? json['total_disputes'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [
        totalLent,
        availableBalance,
        activeLoansCount,
        completedLoansCount,
        totalBorrowed,
        activeBorrowingsCount,
        pendingRequestsCount,
        totalRepaid,
        overdueCount,
        totalUsers,
        pendingVerifications,
        totalActiveLoans,
        totalDisputes,
      ];
}
