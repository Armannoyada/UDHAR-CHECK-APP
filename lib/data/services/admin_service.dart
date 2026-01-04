import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/error/exceptions.dart';

/// Admin Dashboard Stats Model
class AdminStats {
  final int totalUsers;
  final int totalLenders;
  final int totalBorrowers;
  final int activeLoans;
  final int completedLoans;
  final int defaultedLoans;
  final int pendingReports;
  final int openDisputes;
  final double totalLentAmount;
  final double totalBorrowedAmount;

  AdminStats({
    required this.totalUsers,
    required this.totalLenders,
    required this.totalBorrowers,
    required this.activeLoans,
    required this.completedLoans,
    required this.defaultedLoans,
    required this.pendingReports,
    required this.openDisputes,
    required this.totalLentAmount,
    required this.totalBorrowedAmount,
  });

  factory AdminStats.fromJson(Map<String, dynamic> json) {
    return AdminStats(
      totalUsers: json['totalUsers'] ?? 0,
      totalLenders: json['totalLenders'] ?? 0,
      totalBorrowers: json['totalBorrowers'] ?? 0,
      activeLoans: json['activeLoans'] ?? 0,
      completedLoans: json['completedLoans'] ?? 0,
      defaultedLoans: json['defaultedLoans'] ?? 0,
      pendingReports: json['pendingReports'] ?? 0,
      openDisputes: json['openDisputes'] ?? 0,
      totalLentAmount: (json['totalLentAmount'] ?? 0).toDouble(),
      totalBorrowedAmount: (json['totalBorrowedAmount'] ?? 0).toDouble(),
    );
  }
}

/// Admin User Model (extends User with additional admin fields)
class AdminUser {
  final int id;
  final String? firstName;
  final String? lastName;
  final String email;
  final String? phone;
  final String role;
  final bool isBlocked;
  final String? blockReason;
  final bool isOnboardingComplete;
  final String verificationStatus;
  final bool isAdminVerified;
  final DateTime createdAt;
  final String? profilePhoto;
  final double trustScore;
  final double repaymentScore;
  final String? status;
  final String? profileImage;

  AdminUser({
    required this.id,
    this.firstName,
    this.lastName,
    required this.email,
    this.phone,
    required this.role,
    this.isBlocked = false,
    this.blockReason,
    this.isOnboardingComplete = false,
    this.verificationStatus = 'pending',
    this.isAdminVerified = false,
    required this.createdAt,
    this.profilePhoto,
    this.trustScore = 50,
    this.repaymentScore = 50,
    this.status,
    this.profileImage,
  });

  String get fullName => '${firstName ?? ''} ${lastName ?? ''}'.trim();
  bool get isVerified => isAdminVerified || verificationStatus == 'verified';
  double? get trustScoreValue => trustScore;
  String get initials {
    final f = firstName?.isNotEmpty == true ? firstName![0] : '';
    final l = lastName?.isNotEmpty == true ? lastName![0] : '';
    return '$f$l'.toUpperCase();
  }

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id'] ?? 0,
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'] ?? '',
      phone: json['phone'],
      role: json['role'] ?? 'borrower',
      isBlocked: json['isBlocked'] ?? false,
      blockReason: json['blockReason'],
      isOnboardingComplete: json['isOnboardingComplete'] ?? false,
      verificationStatus: json['verificationStatus'] ?? 'pending',
      isAdminVerified: json['isAdminVerified'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      profilePhoto: json['profilePhoto'],
      trustScore: (json['trustScore'] ?? 50).toDouble(),
      repaymentScore: (json['repaymentScore'] ?? 50).toDouble(),
      status: json['status'],
      profileImage: json['profilePhoto'] ?? json['profileImage'],
    );
  }
}

/// Admin Loan Model
class AdminLoan {
  final int id;
  final double amount;
  final double interestRate;
  final int durationDays;
  final String status;
  final String? purpose;
  final AdminUser? borrower;
  final AdminUser? lender;
  final DateTime createdAt;
  final double? totalRepayable;
  final double? amountPaid;
  final DateTime? dueDate;

  AdminLoan({
    required this.id,
    required this.amount,
    required this.interestRate,
    required this.durationDays,
    required this.status,
    this.purpose,
    this.borrower,
    this.lender,
    required this.createdAt,
    this.totalRepayable,
    this.amountPaid,
    this.dueDate,
  });

  // Alias for durationDays
  int get duration => durationDays;

  factory AdminLoan.fromJson(Map<String, dynamic> json) {
    return AdminLoan(
      id: json['id'] ?? 0,
      amount: (json['amount'] ?? 0).toDouble(),
      interestRate: (json['interestRate'] ?? 0).toDouble(),
      durationDays: json['durationDays'] ?? json['duration'] ?? 0,
      status: json['status'] ?? 'pending',
      purpose: json['purpose'],
      borrower: json['borrower'] != null
          ? AdminUser.fromJson(json['borrower'])
          : null,
      lender:
          json['lender'] != null ? AdminUser.fromJson(json['lender']) : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      totalRepayable: json['totalRepayable']?.toDouble(),
      amountPaid: json['amountPaid']?.toDouble(),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
    );
  }
}

/// Report Model
class AdminReport {
  final int id;
  final int? reporterId;
  final int? reportedUserId;
  final String reason;
  final String? description;
  final String status;
  final AdminUser? reporter;
  final AdminUser? reportedUser;
  final DateTime createdAt;

  AdminReport({
    required this.id,
    this.reporterId,
    this.reportedUserId,
    required this.reason,
    this.description,
    required this.status,
    this.reporter,
    this.reportedUser,
    required this.createdAt,
  });

  factory AdminReport.fromJson(Map<String, dynamic> json) {
    return AdminReport(
      id: json['id'] ?? 0,
      reporterId: json['reporterId'],
      reportedUserId: json['reportedUserId'],
      reason: json['reason'] ?? '',
      description: json['description'],
      status: json['status'] ?? 'pending',
      reporter: json['reporter'] != null
          ? AdminUser.fromJson(json['reporter'])
          : null,
      reportedUser: json['reportedUser'] != null
          ? AdminUser.fromJson(json['reportedUser'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}

/// Dispute Model
class AdminDispute {
  final int id;
  final int? loanId;
  final int? raisedById;
  final int? againstUserId;
  final String reason;
  final String? description;
  final String status;
  final AdminUser? raisedBy;
  final AdminUser? againstUser;
  final AdminLoan? loan;
  final DateTime createdAt;

  AdminDispute({
    required this.id,
    this.loanId,
    this.raisedById,
    this.againstUserId,
    required this.reason,
    this.description,
    required this.status,
    this.raisedBy,
    this.againstUser,
    this.loan,
    required this.createdAt,
  });

  factory AdminDispute.fromJson(Map<String, dynamic> json) {
    return AdminDispute(
      id: json['id'] ?? 0,
      loanId: json['loanId'],
      raisedById: json['raisedById'],
      againstUserId: json['againstUserId'],
      reason: json['reason'] ?? '',
      description: json['description'],
      status: json['status'] ?? 'open',
      raisedBy: json['raisedBy'] != null
          ? AdminUser.fromJson(json['raisedBy'])
          : null,
      againstUser: json['againstUser'] != null
          ? AdminUser.fromJson(json['againstUser'])
          : null,
      loan: json['loan'] != null ? AdminLoan.fromJson(json['loan']) : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}

/// Platform Settings Model
class PlatformSetting {
  final int id;
  final String key;
  final String value;
  final String? description;
  final String category;
  final String type;
  final String name;

  PlatformSetting({
    required this.id,
    required this.key,
    required this.value,
    this.description,
    required this.category,
    this.type = 'text',
    String? name,
  }) : name = name ?? _formatKeyToName(key);

  static String _formatKeyToName(String key) {
    return key.split('_').map((word) {
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }

  factory PlatformSetting.fromJson(Map<String, dynamic> json) {
    return PlatformSetting(
      id: json['id'] ?? 0,
      key: json['key'] ?? '',
      value: json['value'] ?? '',
      description: json['description'],
      category: json['category'] ?? 'general',
      type: json['type'] ?? 'text',
      name: json['name'],
    );
  }
}

/// Admin API Service
class AdminService {
  AdminService(this._apiClient);
  final ApiClient _apiClient;

  /// Get dashboard statistics
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await _apiClient.dio.get('/admin/dashboard');

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return {
          'stats': AdminStats.fromJson(data['stats'] ?? {}),
          'recentLoans': (data['recentLoans'] as List? ?? [])
              .map((e) => AdminLoan.fromJson(e))
              .toList(),
        };
      } else {
        throw ServerException(
          response.data['message'] ?? 'Failed to get dashboard stats',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get all users with pagination and filters
  Future<Map<String, dynamic>> getAllUsers({
    String? role,
    String? search,
    String? verificationStatus,
    bool? isBlocked,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (role != null && role.isNotEmpty) queryParams['role'] = role;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (verificationStatus != null && verificationStatus.isNotEmpty) {
        queryParams['verificationStatus'] = verificationStatus;
      }
      if (isBlocked != null) queryParams['isBlocked'] = isBlocked;

      final response = await _apiClient.dio.get(
        '/admin/users',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return {
          'users': (data['users'] as List? ?? [])
              .map((e) => AdminUser.fromJson(e))
              .toList(),
          'total': data['total'] ?? 0,
          'page': data['page'] ?? 1,
          'totalPages': data['totalPages'] ?? 1,
        };
      } else {
        throw ServerException(
          response.data['message'] ?? 'Failed to get users',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get user details
  Future<Map<String, dynamic>> getUserDetails(int userId) async {
    try {
      final response = await _apiClient.dio.get('/admin/users/$userId');

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return {
          'user': AdminUser.fromJson(data['user'] ?? {}),
          'loans': (data['loans'] as List? ?? [])
              .map((e) => AdminLoan.fromJson(e))
              .toList(),
          'reports': data['reports'] ?? {'against': 0, 'filed': 0},
        };
      } else {
        throw ServerException(
          response.data['message'] ?? 'Failed to get user details',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Block/Unblock user
  Future<void> toggleBlockUser(int userId, bool block, {String? reason}) async {
    try {
      final response = await _apiClient.dio.put(
        '/admin/users/$userId/block',
        data: {'block': block, 'reason': reason},
      );

      if (response.statusCode != 200) {
        throw ServerException(
          response.data['message'] ?? 'Failed to update user status',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Verify user
  Future<void> verifyUser(int userId, bool approve) async {
    try {
      final response = await _apiClient.dio.put(
        '/admin/users/$userId/verify',
        data: {'approve': approve},
      );

      if (response.statusCode != 200) {
        throw ServerException(
          response.data['message'] ?? 'Failed to verify user',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Delete user
  Future<void> deleteUser(int userId) async {
    try {
      final response = await _apiClient.dio.delete('/admin/users/$userId');

      if (response.statusCode != 200) {
        throw ServerException(
          response.data['message'] ?? 'Failed to delete user',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get all reports
  Future<Map<String, dynamic>> getAllReports({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (status != null && status.isNotEmpty) queryParams['status'] = status;

      final response = await _apiClient.dio.get(
        '/admin/reports',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return {
          'reports': (data['reports'] as List? ?? [])
              .map((e) => AdminReport.fromJson(e))
              .toList(),
          'total': data['total'] ?? 0,
          'page': data['page'] ?? 1,
          'totalPages': data['totalPages'] ?? 1,
        };
      } else {
        throw ServerException(
          response.data['message'] ?? 'Failed to get reports',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Resolve report
  Future<void> resolveReport(int reportId, String status) async {
    try {
      final response = await _apiClient.dio.put(
        '/admin/reports/$reportId',
        data: {'status': status},
      );

      if (response.statusCode != 200) {
        throw ServerException(
          response.data['message'] ?? 'Failed to resolve report',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get all disputes
  Future<Map<String, dynamic>> getAllDisputes({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (status != null && status.isNotEmpty) queryParams['status'] = status;

      final response = await _apiClient.dio.get(
        '/admin/disputes',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return {
          'disputes': (data['disputes'] as List? ?? [])
              .map((e) => AdminDispute.fromJson(e))
              .toList(),
          'total': data['total'] ?? 0,
          'page': data['page'] ?? 1,
          'totalPages': data['totalPages'] ?? 1,
        };
      } else {
        throw ServerException(
          response.data['message'] ?? 'Failed to get disputes',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Resolve dispute
  Future<void> resolveDispute(int disputeId, String status) async {
    try {
      final response = await _apiClient.dio.put(
        '/admin/disputes/$disputeId',
        data: {'status': status},
      );

      if (response.statusCode != 200) {
        throw ServerException(
          response.data['message'] ?? 'Failed to resolve dispute',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get all loans
  Future<Map<String, dynamic>> getAllLoans({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (status != null && status.isNotEmpty) queryParams['status'] = status;

      final response = await _apiClient.dio.get(
        '/admin/loans',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return {
          'loans': (data['loans'] as List? ?? [])
              .map((e) => AdminLoan.fromJson(e))
              .toList(),
          'total': data['total'] ?? 0,
          'page': data['page'] ?? 1,
          'totalPages': data['totalPages'] ?? 1,
        };
      } else {
        throw ServerException(
          response.data['message'] ?? 'Failed to get loans',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get platform settings
  Future<List<PlatformSetting>> getSettings() async {
    try {
      final response = await _apiClient.dio.get('/admin/settings');

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final settings = data['settings'] as List? ?? [];
        return settings.map((e) => PlatformSetting.fromJson(e)).toList();
      } else {
        throw ServerException(
          response.data['message'] ?? 'Failed to get settings',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Update setting
  Future<void> updateSetting(String key, String value) async {
    try {
      final response = await _apiClient.dio.put(
        '/admin/settings',
        data: {'key': key, 'value': value},
      );

      if (response.statusCode != 200) {
        throw ServerException(
          response.data['message'] ?? 'Failed to update setting',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Handle Dio errors
  Exception _handleDioError(DioException error) {
    print('🔥 Admin API Error: ${error.type} - ${error.message}');

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ServerException(
          'Connection timeout. Please check your connection.',
          statusCode: 408,
        );
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['message'] ??
            error.response?.data?['error'] ??
            'Request failed';
        return ServerException(message, statusCode: statusCode);
      case DioExceptionType.connectionError:
        return ServerException(
          'Cannot connect to server.',
          statusCode: 0,
        );
      default:
        return ServerException(
          error.message ?? 'An error occurred',
          statusCode: 0,
        );
    }
  }
}
