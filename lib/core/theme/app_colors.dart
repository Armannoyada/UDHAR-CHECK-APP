import 'package:flutter/material.dart';

/// App Color Palette based on the Udhar design system
class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFF4F46E5);
  static const Color primaryDark = Color(0xFF4338CA);
  static const Color primaryLight = Color(0xFF818CF8);

  // Secondary Colors
  static const Color secondary = Color(0xFF10B981);
  static const Color secondaryDark = Color(0xFF059669);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color danger = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Gray Scale
  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray900 = Color(0xFF111827);

  // Basic Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color background = Color(0xFFF9FAFB);
  static const Color surface = Color(0xFFFFFFFF);

  // Status Badge Colors
  static const Color statusPending = Color(0xFFF59E0B);
  static const Color statusAccepted = Color(0xFF3B82F6);
  static const Color statusInProgress = Color(0xFF4F46E5);
  static const Color statusCompleted = Color(0xFF10B981);
  static const Color statusRejected = Color(0xFFEF4444);
  static const Color statusDefaulted = Color(0xFF991B1B);
  static const Color statusOverdue = Color(0xFFEF4444);

  // Trust Score Colors
  static const Color scoreLow = Color(0xFFEF4444);
  static const Color scoreMedium = Color(0xFFF59E0B);
  static const Color scoreHigh = Color(0xFF10B981);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF60A5FA), Color(0xFF3B82F6)],
  );

  /// Get score color based on value (0-100)
  static Color getScoreColor(double score) {
    if (score < 40) return scoreLow;
    if (score < 70) return scoreMedium;
    return scoreHigh;
  }

  /// Get status color based on loan status
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return statusPending;
      case 'accepted':
        return statusAccepted;
      case 'in_progress':
      case 'in progress':
        return statusInProgress;
      case 'completed':
        return statusCompleted;
      case 'rejected':
        return statusRejected;
      case 'defaulted':
        return statusDefaulted;
      case 'overdue':
        return statusOverdue;
      default:
        return gray500;
    }
  }

  /// Get status background color (lighter version)
  static Color getStatusBackgroundColor(String status) {
    return getStatusColor(status).withValues(alpha: 0.1);
  }
}
