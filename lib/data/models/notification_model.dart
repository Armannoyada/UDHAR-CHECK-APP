import 'package:json_annotation/json_annotation.dart';

part 'notification_model.g.dart';

/// Notification Type Enum
enum NotificationType {
  @JsonValue('loan_request')
  loanRequest,
  @JsonValue('loan_accepted')
  loanAccepted,
  @JsonValue('loan_rejected')
  loanRejected,
  @JsonValue('loan_fulfilled')
  loanFulfilled,
  @JsonValue('payment_reminder')
  paymentReminder,
  @JsonValue('payment_received')
  paymentReceived,
  @JsonValue('payment_overdue')
  paymentOverdue,
  @JsonValue('report_filed')
  reportFiled,
  @JsonValue('report_resolved')
  reportResolved,
  @JsonValue('account_blocked')
  accountBlocked,
  @JsonValue('account_unblocked')
  accountUnblocked,
  @JsonValue('general')
  general,
}

/// Helper to safely convert id to String
String? _idFromJson(dynamic value) {
  if (value == null) return null;
  return value.toString();
}

/// Read notification ID from JSON
dynamic _readNotificationId(Map<dynamic, dynamic> json, String key) {
  final value = json['_id'] ?? json['id'];
  if (value == null) return '';
  return value.toString();
}

/// Safely decode NotificationType from JSON
NotificationType _notificationTypeFromJson(dynamic value) {
  if (value == null) return NotificationType.general;
  if (value is String) {
    final normalized = value.toLowerCase().trim();
    switch (normalized) {
      case 'loan_request':
        return NotificationType.loanRequest;
      case 'loan_accepted':
        return NotificationType.loanAccepted;
      case 'loan_rejected':
        return NotificationType.loanRejected;
      case 'loan_fulfilled':
        return NotificationType.loanFulfilled;
      case 'payment_reminder':
        return NotificationType.paymentReminder;
      case 'payment_received':
        return NotificationType.paymentReceived;
      case 'payment_overdue':
        return NotificationType.paymentOverdue;
      case 'report_filed':
        return NotificationType.reportFiled;
      case 'report_resolved':
        return NotificationType.reportResolved;
      case 'account_blocked':
        return NotificationType.accountBlocked;
      case 'account_unblocked':
        return NotificationType.accountUnblocked;
      case 'general':
        return NotificationType.general;
      default:
        return NotificationType.general;
    }
  }
  return NotificationType.general;
}

@JsonSerializable()
class AppNotification {
  @JsonKey(readValue: _readNotificationId)
  final String id;

  @JsonKey(fromJson: _idFromJson)
  final String? userId;

  @JsonKey(fromJson: _notificationTypeFromJson)
  final NotificationType type;

  final String title;
  final String message;

  @JsonKey(fromJson: _idFromJson)
  final String? relatedId;

  final String? relatedType;

  @JsonKey(name: 'isRead')
  final bool? read;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AppNotification({
    required this.id,
    this.userId,
    required this.type,
    required this.title,
    required this.message,
    this.relatedId,
    this.relatedType,
    this.read,
    this.createdAt,
    this.updatedAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      _$AppNotificationFromJson(json);

  Map<String, dynamic> toJson() => _$AppNotificationToJson(this);
}

@JsonSerializable()
class NotificationListResponse {
  final bool success;
  final String? message;
  final List<AppNotification>? data;

  const NotificationListResponse({
    required this.success,
    this.message,
    this.data,
  });

  factory NotificationListResponse.fromJson(Map<String, dynamic> json) =>
      _$NotificationListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationListResponseToJson(this);
}

@JsonSerializable()
class UnreadCountResponse {
  final bool success;
  final String? message;
  final UnreadCountData? data;

  const UnreadCountResponse({
    required this.success,
    this.message,
    this.data,
  });

  factory UnreadCountResponse.fromJson(Map<String, dynamic> json) =>
      _$UnreadCountResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UnreadCountResponseToJson(this);
}

@JsonSerializable()
class UnreadCountData {
  final int count;

  const UnreadCountData({required this.count});

  factory UnreadCountData.fromJson(Map<String, dynamic> json) =>
      _$UnreadCountDataFromJson(json);

  Map<String, dynamic> toJson() => _$UnreadCountDataToJson(this);
}
