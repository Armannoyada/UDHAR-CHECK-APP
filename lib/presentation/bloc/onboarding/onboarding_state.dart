part of 'onboarding_bloc.dart';

enum OnboardingStatus {
  initial,
  loading,
  success,
  error,
}

class OnboardingState extends Equatable {
  const OnboardingState({
    this.status = OnboardingStatus.initial,
    this.currentStep = 0,
    this.totalSteps = 3,
    this.userRole = 'borrower',
    this.streetAddress = '',
    this.city = '',
    this.state = '',
    this.pincode = '',
    this.idType = 'aadhar',
    this.idNumber = '',
    this.documentPath,
    this.documentName,
    this.selfiePath,
    this.maxLendingAmount,
    this.termsAccepted = false,
    this.isAddressComplete = false,
    this.isIdComplete = false,
    this.isSelfieComplete = false,
    this.isLendingSetupComplete = false,
    this.errorMessage,
    this.completedUser,
  });

  factory OnboardingState.initial({String role = 'borrower'}) {
    return OnboardingState(
      userRole: role,
      totalSteps: role == 'lender' ? 4 : 3,
    );
  }
  final OnboardingStatus status;
  final int currentStep;
  final int totalSteps;
  final String userRole; // 'borrower' or 'lender'

  // Address fields
  final String streetAddress;
  final String city;
  final String state;
  final String pincode;

  // ID Verification fields
  final String idType;
  final String idNumber;
  final String? documentPath;
  final String? documentName;

  // Selfie field
  final String? selfiePath;

  // Lending preferences (lender only)
  final double? maxLendingAmount;
  final bool termsAccepted;

  // Step completion flags
  final bool isAddressComplete;
  final bool isIdComplete;
  final bool isSelfieComplete;
  final bool isLendingSetupComplete;

  // Error message
  final String? errorMessage;

  // Completed user data (returned after successful onboarding)
  final User? completedUser;

  /// Get step titles based on role
  List<String> get stepTitles {
    if (userRole == 'lender') {
      return ['Address', 'ID Verification', 'Selfie', 'Setup'];
    }
    return ['Address', 'ID Verification', 'Selfie'];
  }

  /// Check if current step is complete
  bool get isCurrentStepComplete {
    switch (currentStep) {
      case 0:
        return isAddressComplete;
      case 1:
        return isIdComplete;
      case 2:
        return isSelfieComplete;
      case 3:
        return isLendingSetupComplete;
      default:
        return false;
    }
  }

  /// Check if all steps are complete
  bool get isAllStepsComplete {
    if (userRole == 'lender') {
      return isAddressComplete &&
          isIdComplete &&
          isSelfieComplete &&
          isLendingSetupComplete;
    }
    return isAddressComplete && isIdComplete && isSelfieComplete;
  }

  /// Check if on last step
  bool get isLastStep {
    return currentStep == totalSteps - 1;
  }

  /// Check if on first step
  bool get isFirstStep {
    return currentStep == 0;
  }

  OnboardingState copyWith({
    OnboardingStatus? status,
    int? currentStep,
    int? totalSteps,
    String? userRole,
    String? streetAddress,
    String? city,
    String? state,
    String? pincode,
    String? idType,
    String? idNumber,
    String? documentPath,
    String? documentName,
    String? selfiePath,
    double? maxLendingAmount,
    bool? termsAccepted,
    bool? isAddressComplete,
    bool? isIdComplete,
    bool? isSelfieComplete,
    bool? isLendingSetupComplete,
    String? errorMessage,
    User? completedUser,
  }) {
    return OnboardingState(
      status: status ?? this.status,
      currentStep: currentStep ?? this.currentStep,
      totalSteps: totalSteps ?? this.totalSteps,
      userRole: userRole ?? this.userRole,
      streetAddress: streetAddress ?? this.streetAddress,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      idType: idType ?? this.idType,
      idNumber: idNumber ?? this.idNumber,
      documentPath: documentPath ?? this.documentPath,
      documentName: documentName ?? this.documentName,
      selfiePath: selfiePath ?? this.selfiePath,
      maxLendingAmount: maxLendingAmount ?? this.maxLendingAmount,
      termsAccepted: termsAccepted ?? this.termsAccepted,
      isAddressComplete: isAddressComplete ?? this.isAddressComplete,
      isIdComplete: isIdComplete ?? this.isIdComplete,
      isSelfieComplete: isSelfieComplete ?? this.isSelfieComplete,
      isLendingSetupComplete:
          isLendingSetupComplete ?? this.isLendingSetupComplete,
      errorMessage: errorMessage,
      completedUser: completedUser ?? this.completedUser,
    );
  }

  @override
  List<Object?> get props => [
        status,
        currentStep,
        totalSteps,
        userRole,
        streetAddress,
        city,
        state,
        pincode,
        idType,
        idNumber,
        documentPath,
        documentName,
        selfiePath,
        maxLendingAmount,
        termsAccepted,
        isAddressComplete,
        isIdComplete,
        isSelfieComplete,
        isLendingSetupComplete,
        errorMessage,
        completedUser,
      ];
}
