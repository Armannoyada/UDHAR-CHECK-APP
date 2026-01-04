import 'package:json_annotation/json_annotation.dart';
import 'user_model.dart';

part 'loan_model.g.dart';

/// Loan Status Enum
enum LoanStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('accepted')
  accepted,
  @JsonValue('rejected')
  rejected,
  @JsonValue('fulfilled')
  fulfilled,
  @JsonValue('in_progress')
  inProgress,
  @JsonValue('completed')
  completed,
  @JsonValue('defaulted')
  defaulted,
  @JsonValue('disputed')
  disputed,
  @JsonValue('cancelled')
  cancelled,
}

/// Helper to safely convert id to String
String? _idFromJson(dynamic value) {
  if (value == null) return null;
  return value.toString();
}

/// Read loan ID from JSON
dynamic _readLoanId(Map<dynamic, dynamic> json, String key) {
  final value = json['_id'] ?? json['id'];
  if (value == null) return '';
  return value.toString();
}

/// Helper to safely convert dynamic to double
double _doubleFromDynamic(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

/// Helper to safely convert dynamic to nullable double
double? _nullableDoubleFromDynamic(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

/// Helper to safely convert dynamic to int
int _intFromDynamic(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

/// Safely decode LoanStatus from JSON
LoanStatus _loanStatusFromJson(dynamic value) {
  if (value == null) return LoanStatus.pending;
  if (value is String) {
    final normalized = value.toLowerCase().trim();
    switch (normalized) {
      case 'pending':
        return LoanStatus.pending;
      case 'accepted':
        return LoanStatus.accepted;
      case 'rejected':
        return LoanStatus.rejected;
      case 'fulfilled':
        return LoanStatus.fulfilled;
      case 'in_progress':
        return LoanStatus.inProgress;
      case 'completed':
        return LoanStatus.completed;
      case 'defaulted':
        return LoanStatus.defaulted;
      case 'disputed':
        return LoanStatus.disputed;
      case 'cancelled':
        return LoanStatus.cancelled;
      default:
        return LoanStatus.pending;
    }
  }
  return LoanStatus.pending;
}

/// Helper to parse User from JSON
User? _userFromJson(dynamic value) {
  if (value == null) return null;
  if (value is Map<String, dynamic>) {
    return User.fromJson(value);
  }
  return null;
}

@JsonSerializable()
class Loan {
  @JsonKey(readValue: _readLoanId)
  final String id;

  @JsonKey(fromJson: _userFromJson)
  final User? borrower;

  @JsonKey(fromJson: _idFromJson)
  final String? borrowerId;

  @JsonKey(fromJson: _userFromJson)
  final User? lender;

  @JsonKey(fromJson: _idFromJson)
  final String? lenderId;

  @JsonKey(fromJson: _doubleFromDynamic)
  final double amount;

  @JsonKey(fromJson: _doubleFromDynamic)
  final double interestRate;

  @JsonKey(fromJson: _intFromDynamic)
  final int durationDays;

  final String? purpose;
  final String? description;

  @JsonKey(fromJson: _loanStatusFromJson)
  final LoanStatus status;

  @JsonKey(fromJson: _nullableDoubleFromDynamic)
  final double? totalRepayable;

  @JsonKey(fromJson: _nullableDoubleFromDynamic)
  final double? amountPaid;

  @JsonKey(fromJson: _nullableDoubleFromDynamic)
  final double? remainingAmount;

  final DateTime? dueDate;
  final DateTime? acceptedAt;
  final DateTime? fulfilledAt;
  final DateTime? completedAt;
  final DateTime? defaultedAt;

  final bool? isOverdue;
  final int? daysOverdue;

  final String? rejectionReason;
  final String? cancellationReason;

  @JsonKey(fromJson: _nullableDoubleFromDynamic)
  final double? lenderRating;
  final String? lenderReview;

  @JsonKey(fromJson: _nullableDoubleFromDynamic)
  final double? borrowerRating;
  final String? borrowerReview;

  final bool? isRatedByLender;
  final bool? isRatedByBorrower;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Loan({
    required this.id,
    this.borrower,
    this.borrowerId,
    this.lender,
    this.lenderId,
    required this.amount,
    required this.interestRate,
    required this.durationDays,
    this.purpose,
    this.description,
    required this.status,
    this.totalRepayable,
    this.amountPaid,
    this.remainingAmount,
    this.dueDate,
    this.acceptedAt,
    this.fulfilledAt,
    this.completedAt,
    this.defaultedAt,
    this.isOverdue,
    this.daysOverdue,
    this.rejectionReason,
    this.cancellationReason,
    this.lenderRating,
    this.lenderReview,
    this.borrowerRating,
    this.borrowerReview,
    this.isRatedByLender,
    this.isRatedByBorrower,
    this.createdAt,
    this.updatedAt,
  });

  factory Loan.fromJson(Map<String, dynamic> json) => _$LoanFromJson(json);
  Map<String, dynamic> toJson() => _$LoanToJson(this);

  /// Get formatted amount
  String get formattedAmount => '₹${amount.toStringAsFixed(0)}';

  /// Get formatted total repayable
  String get formattedTotalRepayable =>
      '₹${(totalRepayable ?? amount).toStringAsFixed(0)}';

  /// Get status display text
  String get statusText {
    switch (status) {
      case LoanStatus.pending:
        return 'Pending';
      case LoanStatus.accepted:
        return 'Accepted';
      case LoanStatus.rejected:
        return 'Rejected';
      case LoanStatus.fulfilled:
        return 'Fulfilled';
      case LoanStatus.inProgress:
        return 'In Progress';
      case LoanStatus.completed:
        return 'Completed';
      case LoanStatus.defaulted:
        return 'Defaulted';
      case LoanStatus.disputed:
        return 'Disputed';
      case LoanStatus.cancelled:
        return 'Cancelled';
    }
  }

  /// Check if loan is active
  bool get isActive =>
      status == LoanStatus.accepted ||
      status == LoanStatus.fulfilled ||
      status == LoanStatus.inProgress;

  /// Get borrower name
  String get borrowerName {
    if (borrower != null) {
      return '${borrower!.firstName} ${borrower!.lastName}'.trim();
    }
    return 'Unknown';
  }

  /// Get lender name
  String get lenderName {
    if (lender != null) {
      return '${lender!.firstName} ${lender!.lastName}'.trim();
    }
    return 'Not assigned';
  }
}

/// Loan list response
@JsonSerializable()
class LoanListResponse {
  final bool success;
  final String? message;
  final List<Loan>? data;
  final int? total;
  final int? page;
  final int? limit;

  const LoanListResponse({
    required this.success,
    this.message,
    this.data,
    this.total,
    this.page,
    this.limit,
  });

  factory LoanListResponse.fromJson(Map<String, dynamic> json) {
    // Handle nested structure from backend: data.requests or data.loans
    final responseData = json['data'];
    List<Loan>? loans;
    
    if (responseData is Map) {
      // Backend returns { data: { requests: [...] } } or { data: { loans: [...] } }
      final requestsList = responseData['requests'] ?? responseData['loans'];
      if (requestsList is List) {
        loans = requestsList.map((e) => Loan.fromJson(e as Map<String, dynamic>)).toList();
      }
    } else if (responseData is List) {
      // Direct array
      loans = responseData.map((e) => Loan.fromJson(e as Map<String, dynamic>)).toList();
    }

    return LoanListResponse(
      success: json['success'] ?? true,
      message: json['message'],
      data: loans,
      total: responseData is Map ? responseData['total'] : null,
      page: responseData is Map ? responseData['page'] : null,
      limit: responseData is Map ? responseData['limit'] : null,
    );
  }
  
  Map<String, dynamic> toJson() => _$LoanListResponseToJson(this);
}

/// Single loan response
@JsonSerializable()
class LoanResponse {
  final bool success;
  final String? message;
  final Loan? data;

  const LoanResponse({
    required this.success,
    this.message,
    this.data,
  });

  factory LoanResponse.fromJson(Map<String, dynamic> json) =>
      _$LoanResponseFromJson(json);
  Map<String, dynamic> toJson() => _$LoanResponseToJson(this);
}

/// Create loan request DTO
class CreateLoanRequest {
  final double amount;
  final String purpose;
  final int durationDays;
  final double interestRate;
  final String? description;

  const CreateLoanRequest({
    required this.amount,
    required this.purpose,
    required this.durationDays,
    required this.interestRate,
    this.description,
  });

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'purpose': purpose,
        'duration': durationDays, // Backend expects 'duration' not 'durationDays'
        'interestRate': interestRate,
        if (description != null) 'description': description,
      };
}
