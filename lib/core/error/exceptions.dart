/// Base exception class
class AppException implements Exception {
  final String message;
  final int? statusCode;

  AppException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

/// Server exception - thrown when API returns an error
class ServerException extends AppException {
  ServerException(super.message, {super.statusCode});
}

/// Cache exception - thrown when local storage operations fail
class CacheException extends AppException {
  CacheException(super.message);
}

/// Network exception - thrown when there's no internet connection
class NetworkException extends AppException {
  NetworkException(super.message);
}

/// Authentication exception - thrown when auth fails
class AuthenticationException extends AppException {
  AuthenticationException(super.message, {super.statusCode});
}

/// Validation exception - thrown when input validation fails
class ValidationException extends AppException {
  ValidationException(super.message);
}

/// Timeout exception
class TimeoutException extends AppException {
  TimeoutException(super.message);
}

/// Unauthorized exception
class UnauthorizedException extends AppException {
  UnauthorizedException(super.message) : super(statusCode: 401);
}

/// Forbidden exception
class ForbiddenException extends AppException {
  ForbiddenException(super.message) : super(statusCode: 403);
}

/// Not found exception
class NotFoundException extends AppException {
  NotFoundException(super.message) : super(statusCode: 404);
}
