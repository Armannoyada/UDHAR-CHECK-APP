/// API Constants
class ApiConstants {
  // API base URL - Local development server
  // API Docs available at: http://localhost:5000/api-docs
  static const String baseUrl = 'http://10.0.2.2:5000/api';

  // API Endpoints - Authentication
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String profile = '/auth/profile';
  static const String updateProfile = '/auth/profile';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String verifyEmail = '/auth/verify-email';

  // User Endpoints
  static const String users = '/users';
  static const String uploadProfilePhoto = '/users/profile-photo';

  // Onboarding & Verification
  static const String onboarding = '/users/onboarding';
  static const String uploadDocument = '/users/documents';
  static const String verificationStatus = '/users/verification-status';

  // Loan Endpoints
  static const String loans = '/loans';
  static const String loanRequests = '/loans/requests';
  static const String myLoans = '/loans/my-loans';
  static const String loanHistory = '/loans/history';

  // Repayments - GET /loans/{id}/repayments, POST /loans/{id}/repayments
  static String loanRepayments(String loanId) => '/loans/$loanId/repayments';

  // Notifications
  static const String notifications = '/notifications';
  static String markNotificationRead(String notificationId) =>
      '/notifications/$notificationId/read';

  // Reports
  static const String reports = '/reports';

  // Disputes
  static const String disputes = '/disputes';

  // Admin Endpoints
  static const String adminUsers = '/admin/users';
  static String adminVerifyUser(String userId) => '/admin/users/$userId/verify';
  static String adminBlockUser(String userId) => '/admin/users/$userId/block';
  static const String adminDashboard = '/admin/dashboard';
}

/// App Constants
class AppConstants {
  static const String appName = 'उधार Check';
  static const String appTagline = 'Trusted Peer-to-Peer Lending';
  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;

  // Loan Constants
  static const double minLoanAmount = 500;
  static const double maxLoanAmount = 100000;
  static const double defaultInterestRate = 10;
  static const List<int> loanDurations = [7, 15, 30, 60, 90];

  // Loan Purposes
  static const List<String> loanPurposes = [
    'Medical Emergency',
    'Education',
    'Business',
    'Personal',
    'Home Repair',
    'Travel',
    'Other',
  ];
}

/// Storage Keys
class StorageKeys {
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String userRole = 'user_role';
  static const String userData = 'user_data';
  static const String isLoggedIn = 'is_logged_in';
  static const String isOnboarded = 'is_onboarded';
  static const String isVerified = 'is_verified';
  static const String theme = 'theme';
  static const String language = 'language';
  static const String fcmToken = 'fcm_token';
}

/// Error Messages
class ErrorMessages {
  static const String noInternet = 'No internet connection';
  static const String serverError = 'Server error occurred';
  static const String timeout = 'Request timeout';
  static const String unauthorized = 'Unauthorized access';
  static const String notFound = 'Resource not found';
  static const String unknown = 'Unknown error occurred';
  static const String cacheError = 'Cache error occurred';
  static const String validationError = 'Validation error';
  static const String invalidCredentials = 'Invalid email or password';
  static const String userExists = 'User already exists with this email';
  static const String weakPassword = 'Password is too weak';
  static const String passwordMismatch = 'Passwords do not match';
}
