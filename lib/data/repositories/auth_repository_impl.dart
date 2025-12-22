import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../core/error/exceptions.dart';
import '../../core/network/network_info.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/auth_response.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

class AuthRepositoryImpl implements AuthRepository {

  AuthRepositoryImpl({
    required AuthService authService,
    required StorageService storageService,
    required NetworkInfo networkInfo,
  })  : _authService = authService,
        _storageService = storageService,
        _networkInfo = networkInfo;
  final AuthService _authService;
  final StorageService _storageService;
  final NetworkInfo _networkInfo;

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final request = LoginRequest(email: email, password: password);
      final response = await _authService.login(request);

      if (response.success && response.user != null) {
        // Save tokens
        if (response.accessToken != null) {
          await _storageService.saveAccessToken(response.accessToken!);
        }
        if (response.refreshToken != null) {
          await _storageService.saveRefreshToken(response.refreshToken!);
        }

        // Save user data
        await _storageService.saveUserData(response.user!);
        await _storageService.saveUserId(response.user!.id);
        await _storageService.saveUserRole(response.user!.role.name);
        await _storageService.setLoggedIn(true);

        return Right(response.user!);
      } else {
        return Left(ServerFailure(
          response.message ?? 'Login failed',
        ));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String password,
    required String confirmPassword,
    required String role,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final request = RegisterRequest(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phoneNumber,
        password: password,
        confirmPassword: confirmPassword,
        role: role,
      );

      final response = await _authService.register(request);

      if (response.success && response.user != null) {
        // Save tokens
        if (response.accessToken != null) {
          await _storageService.saveAccessToken(response.accessToken!);
        }
        if (response.refreshToken != null) {
          await _storageService.saveRefreshToken(response.refreshToken!);
        }

        // Save user data
        await _storageService.saveUserData(response.user!);
        await _storageService.saveUserId(response.user!.id);
        await _storageService.saveUserRole(response.user!.role.name);
        await _storageService.setLoggedIn(true);

        return Right(response.user!);
      } else {
        return Left(ServerFailure(
          response.message ?? 'Registration failed',
        ));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _authService.logout();
      await _storageService.clearSession();
      return const Right(null);
    } catch (e) {
      // Even if logout fails on server, clear local session
      await _storageService.clearSession();
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      // First try to get from local storage
      final cachedUser = _storageService.getUserData();
      if (cachedUser != null) {
        return Right(cachedUser);
      }

      // If not available, fetch from API
      if (!await _networkInfo.isConnected) {
        return const Left(NetworkFailure('No internet connection'));
      }

      final user = await _authService.getCurrentUser();
      await _storageService.saveUserData(user);
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    return _storageService.isLoggedIn();
  }

  @override
  Future<String?> getAccessToken() async {
    return await _storageService.getAccessToken();
  }

  @override
  Future<Either<Failure, void>> refreshToken() async {
    try {
      final refreshToken = await _storageService.getRefreshToken();
      if (refreshToken == null) {
        return const Left(AuthenticationFailure('No refresh token available'));
      }

      final response = await _authService.refreshToken(refreshToken);
      
      if (response.success && response.accessToken != null) {
        await _storageService.saveAccessToken(response.accessToken!);
        if (response.refreshToken != null) {
          await _storageService.saveRefreshToken(response.refreshToken!);
        }
        return const Right(null);
      } else {
        return const Left(AuthenticationFailure('Token refresh failed'));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
