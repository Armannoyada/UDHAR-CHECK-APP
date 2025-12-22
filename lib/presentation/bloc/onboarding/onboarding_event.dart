part of 'onboarding_bloc.dart';

abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

/// Move to next step
class OnboardingNextStep extends OnboardingEvent {
  const OnboardingNextStep();
}

/// Move to previous step
class OnboardingPreviousStep extends OnboardingEvent {
  const OnboardingPreviousStep();
}

/// Update address information
class OnboardingAddressUpdated extends OnboardingEvent {

  const OnboardingAddressUpdated({
    required this.streetAddress,
    required this.city,
    required this.state,
    required this.pincode,
  });
  final String streetAddress;
  final String city;
  final String state;
  final String pincode;

  @override
  List<Object?> get props => [streetAddress, city, state, pincode];
}

/// Update ID verification information
class OnboardingIdUpdated extends OnboardingEvent {

  const OnboardingIdUpdated({
    required this.idType,
    required this.idNumber,
    this.documentPath,
    this.documentName,
  });
  final String idType;
  final String idNumber;
  final String? documentPath;
  final String? documentName;

  @override
  List<Object?> get props => [idType, idNumber, documentPath, documentName];
}

/// Update selfie
class OnboardingSelfieUpdated extends OnboardingEvent {

  const OnboardingSelfieUpdated({
    required this.selfiePath,
  });
  final String selfiePath;

  @override
  List<Object?> get props => [selfiePath];
}

/// Update lending preferences (for lenders only)
class OnboardingLendingPreferencesUpdated extends OnboardingEvent {

  const OnboardingLendingPreferencesUpdated({
    required this.maxLendingAmount,
    required this.termsAccepted,
  });
  final double maxLendingAmount;
  final bool termsAccepted;

  @override
  List<Object?> get props => [maxLendingAmount, termsAccepted];
}

/// Submit onboarding
class OnboardingSubmitted extends OnboardingEvent {
  const OnboardingSubmitted();
}

/// Reset onboarding state
class OnboardingReset extends OnboardingEvent {
  const OnboardingReset();
}

/// Set user role
class OnboardingUserRoleSet extends OnboardingEvent {

  const OnboardingUserRoleSet({required this.role});
  final String role;

  @override
  List<Object?> get props => [role];
}
