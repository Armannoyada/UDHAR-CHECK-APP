import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../core/error/exceptions.dart';
import '../../core/network/network_info.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../models/user_model.dart';
import '../services/onboarding_service.dart';
import '../services/storage_service.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  OnboardingRepositoryImpl({
    required OnboardingService onboardingService,
    required StorageService storageService,
    required NetworkInfo networkInfo,
  })  : _onboardingService = onboardingService,
        _storageService = storageService,
        _networkInfo = networkInfo;
  final OnboardingService _onboardingService;
  final StorageService _storageService;
  final NetworkInfo _networkInfo;

  @override
  Future<Either<Failure, User>> submitOnboarding({
    required String streetAddress,
    required String city,
    required String state,
    required String pincode,
    required String idType,
    required String idNumber,
    required String documentPath,
    required String selfiePath,
    double? maxLendingAmount,
    bool? termsAccepted,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final response = await _onboardingService.submitOnboarding(
        streetAddress: streetAddress,
        city: city,
        state: state,
        pincode: pincode,
        idType: idType,
        idNumber: idNumber,
        documentPath: documentPath,
        selfiePath: selfiePath,
        maxLendingAmount: maxLendingAmount,
        termsAccepted: termsAccepted,
      );

      if (response.success && response.user != null) {
        // Update cached user data
        await _storageService.saveUserData(response.user!);
        return Right(response.user!);
      } else {
        return Left(ServerFailure(
          response.message ?? 'Onboarding failed',
        ));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadDocument({
    required String filePath,
    required String documentType,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final url = await _onboardingService.uploadDocument(
        filePath: filePath,
        documentType: documentType,
      );
      return Right(url);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadSelfie({
    required String filePath,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final url = await _onboardingService.uploadSelfie(
        filePath: filePath,
      );
      return Right(url);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getVerificationStatus() async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final status = await _onboardingService.getVerificationStatus();
      return Right(status);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
