/// API Constants
class ApiConstants {
  // TODO: Update with your actual API base URL
  static const String baseUrl = 'https://your-api-url.com/api/v1';
  
  // API Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  
  // Add your API endpoints here
  // Example:
  // static const String users = '/users';
  // static const String profile = '/profile';
}

/// App Constants
class AppConstants {
  static const String appName = 'Udhar Check App';
  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;
}

/// Storage Keys
class StorageKeys {
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String isLoggedIn = 'is_logged_in';
  static const String theme = 'theme';
  static const String language = 'language';
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
}
