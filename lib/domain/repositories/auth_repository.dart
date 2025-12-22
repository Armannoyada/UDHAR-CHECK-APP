import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../data/models/user_model.dart';

/// Authentication Repository Interface
abstract class AuthRepository {
  /// Login user with email and password
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });

  /// Register new user
  Future<Either<Failure, User>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String password,
    required String confirmPassword,
    required String role,
  });

  /// Logout user
  Future<Either<Failure, void>> logout();

  /// Get current user
  Future<Either<Failure, User>> getCurrentUser();

  /// Check if user is logged in
  Future<bool> isLoggedIn();

  /// Get access token
  Future<String?> getAccessToken();

  /// Refresh access token
  Future<Either<Failure, void>> refreshToken();
}
