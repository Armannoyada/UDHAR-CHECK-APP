import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../data/models/user_model.dart';

/// Onboarding Repository Interface
abstract class OnboardingRepository {
  /// Submit onboarding data
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
  });

  /// Upload document
  Future<Either<Failure, String>> uploadDocument({
    required String filePath,
    required String documentType,
  });

  /// Upload selfie
  Future<Either<Failure, String>> uploadSelfie({
    required String filePath,
  });

  /// Get verification status
  Future<Either<Failure, Map<String, dynamic>>> getVerificationStatus();
}
