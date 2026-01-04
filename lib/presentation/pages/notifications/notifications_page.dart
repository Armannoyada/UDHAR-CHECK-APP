import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/notification_model.dart';
import '../../../core/di/injection_container.dart';
import '../../../data/services/notification_service.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _isLoading = true;
  List<AppNotification> _notifications = [];
  String? _errorMessage;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    _loadUnreadCount();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final service = getIt<NotificationService>();
      final response = await service.getNotifications();
      
      setState(() {
        _notifications = response.data ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
        _notifications = [];
      });
    }
  }

  Future<void> _loadUnreadCount() async {
    try {
      final service = getIt<NotificationService>();
      final response = await service.getUnreadCount();
      
      setState(() {
        _unreadCount = response.data?.count ?? 0;
      });
    } catch (e) {
      // Silently fail for unread count
    }
  }

  Future<void> _markAsRead(String id) async {
    try {
      final service = getIt<NotificationService>();
      await service.markAsRead(id);
      
      setState(() {
        final index = _notifications.indexWhere((n) => n.id == id);
        if (index != -1) {
          _notifications[index] = AppNotification(
            id: _notifications[index].id,
            userId: _notifications[index].userId,
            type: _notifications[index].type,
            title: _notifications[index].title,
            message: _notifications[index].message,
            relatedId: _notifications[index].relatedId,
            relatedType: _notifications[index].relatedType,
            read: true,
            createdAt: _notifications[index].createdAt,
            updatedAt: DateTime.now(),
          );
        }
      });
      _loadUnreadCount();
    } catch (e) {
      // Silently fail
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      final service = getIt<NotificationService>();
      await service.markAllAsRead();
      
      setState(() {
        _notifications = _notifications.map((n) => AppNotification(
          id: n.id,
          userId: n.userId,
          type: n.type,
          title: n.title,
          message: n.message,
          relatedId: n.relatedId,
          relatedType: n.relatedType,
          read: true,
          createdAt: n.createdAt,
          updatedAt: DateTime.now(),
        )).toList();
        _unreadCount = 0;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error marking all as read: ${e.toString()}'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  Future<void> _deleteNotification(String id) async {
    try {
      final service = getIt<NotificationService>();
      await service.deleteNotification(id);
      
      setState(() {
        _notifications.removeWhere((n) => n.id == id);
      });
      _loadUnreadCount();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting notification: ${e.toString()}'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.gray700),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: AppColors.gray900,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text(
                'Mark all read',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorState()
              : _notifications.isEmpty
                  ? _buildEmptyState()
                  : _buildNotificationsList(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.gray400,
            ),
            const SizedBox(height: 16),
            const Text(
              'Error loading notifications',
              style: TextStyle(
                color: AppColors.gray900,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.gray500,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadNotifications,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.gray100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_none,
                size: 40,
                color: AppColors.gray400,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No notifications',
              style: TextStyle(
                color: AppColors.gray900,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You\'re all caught up!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.gray500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsList() {
    return RefreshIndicator(
      onRefresh: _loadNotifications,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          return _buildNotificationCard(_notifications[index]);
        },
      ),
    );
  }

  Widget _buildNotificationCard(AppNotification notification) {
    final isUnread = notification.read == false;
    
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: AppColors.danger,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete,
          color: AppColors.white,
        ),
      ),
      onDismissed: (_) => _deleteNotification(notification.id),
      child: InkWell(
        onTap: () {
          if (isUnread) {
            _markAsRead(notification.id);
          }
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isUnread ? AppColors.primary.withValues(alpha: 0.05) : AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isUnread ? AppColors.primary.withValues(alpha: 0.2) : AppColors.gray200,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getNotificationColor(notification.type).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getNotificationIcon(notification.type),
                  color: _getNotificationColor(notification.type),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              color: AppColors.gray900,
                              fontSize: 15,
                              fontWeight: isUnread ? FontWeight.w600 : FontWeight.w500,
                            ),
                          ),
                        ),
                        if (isUnread)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: TextStyle(
                        color: AppColors.gray600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatDate(notification.createdAt),
                      style: TextStyle(
                        color: AppColors.gray400,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.loanRequest:
        return Icons.request_quote;
      case NotificationType.loanAccepted:
        return Icons.check_circle_outline;
      case NotificationType.loanRejected:
        return Icons.cancel_outlined;
      case NotificationType.loanFulfilled:
        return Icons.money;
      case NotificationType.paymentReminder:
        return Icons.alarm;
      case NotificationType.paymentReceived:
        return Icons.payments;
      case NotificationType.paymentOverdue:
        return Icons.warning_amber_outlined;
      case NotificationType.reportFiled:
        return Icons.report_problem_outlined;
      case NotificationType.reportResolved:
        return Icons.verified_outlined;
      case NotificationType.accountBlocked:
        return Icons.block;
      case NotificationType.accountUnblocked:
        return Icons.lock_open;
      case NotificationType.general:
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.loanAccepted:
      case NotificationType.loanFulfilled:
      case NotificationType.paymentReceived:
      case NotificationType.reportResolved:
      case NotificationType.accountUnblocked:
        return AppColors.success;
      case NotificationType.loanRejected:
      case NotificationType.accountBlocked:
        return AppColors.danger;
      case NotificationType.paymentReminder:
      case NotificationType.paymentOverdue:
      case NotificationType.reportFiled:
        return AppColors.warning;
      case NotificationType.loanRequest:
      case NotificationType.general:
      default:
        return AppColors.primary;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
