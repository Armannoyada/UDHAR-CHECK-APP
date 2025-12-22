import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/repositories/onboarding_repository.dart';
import '../../../data/models/user_model.dart';

part 'onboarding_event.dart';
part 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {

  OnboardingBloc({required OnboardingRepository onboardingRepository})
      : _onboardingRepository = onboardingRepository,
        super(OnboardingState.initial()) {
    on<OnboardingNextStep>(_onNextStep);
    on<OnboardingPreviousStep>(_onPreviousStep);
    on<OnboardingAddressUpdated>(_onAddressUpdated);
    on<OnboardingIdUpdated>(_onIdUpdated);
    on<OnboardingSelfieUpdated>(_onSelfieUpdated);
    on<OnboardingLendingPreferencesUpdated>(_onLendingPreferencesUpdated);
    on<OnboardingSubmitted>(_onSubmitted);
    on<OnboardingReset>(_onReset);
    on<OnboardingUserRoleSet>(_onUserRoleSet);
  }
  final OnboardingRepository _onboardingRepository;

  /// Handle next step navigation
  void _onNextStep(
    OnboardingNextStep event,
    Emitter<OnboardingState> emit,
  ) {
    if (state.currentStep < state.totalSteps - 1) {
      emit(state.copyWith(currentStep: state.currentStep + 1));
    }
  }

  /// Handle previous step navigation
  void _onPreviousStep(
    OnboardingPreviousStep event,
    Emitter<OnboardingState> emit,
  ) {
    if (state.currentStep > 0) {
      emit(state.copyWith(currentStep: state.currentStep - 1));
    }
  }

  /// Handle address update
  void _onAddressUpdated(
    OnboardingAddressUpdated event,
    Emitter<OnboardingState> emit,
  ) {
    final isComplete = event.streetAddress.isNotEmpty &&
        event.city.isNotEmpty &&
        event.state.isNotEmpty &&
        event.pincode.length == 6;

    emit(state.copyWith(
      streetAddress: event.streetAddress,
      city: event.city,
      state: event.state,
      pincode: event.pincode,
      isAddressComplete: isComplete,
    ));
  }

  /// Handle ID verification update
  void _onIdUpdated(
    OnboardingIdUpdated event,
    Emitter<OnboardingState> emit,
  ) {
    bool isValidIdNumber = false;
    
    // Validate ID number based on type
    if (event.idType == 'aadhar') {
      isValidIdNumber = event.idNumber.length == 12 && 
          RegExp(r'^[0-9]+$').hasMatch(event.idNumber);
    } else if (event.idType == 'pan') {
      isValidIdNumber = event.idNumber.length == 10 &&
          RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$').hasMatch(event.idNumber.toUpperCase());
    } else if (event.idType == 'voter_id') {
      isValidIdNumber = event.idNumber.length >= 10;
    } else if (event.idType == 'driving_license') {
      isValidIdNumber = event.idNumber.length >= 10;
    }

    final isComplete = event.idType.isNotEmpty &&
        isValidIdNumber &&
        event.documentPath != null &&
        event.documentPath!.isNotEmpty;

    emit(state.copyWith(
      idType: event.idType,
      idNumber: event.idNumber,
      documentPath: event.documentPath,
      documentName: event.documentName,
      isIdComplete: isComplete,
    ));
  }

  /// Handle selfie update
  void _onSelfieUpdated(
    OnboardingSelfieUpdated event,
    Emitter<OnboardingState> emit,
  ) {
    final isComplete = event.selfiePath.isNotEmpty;

    emit(state.copyWith(
      selfiePath: event.selfiePath,
      isSelfieComplete: isComplete,
    ));
  }

  /// Handle lending preferences update (for lenders)
  void _onLendingPreferencesUpdated(
    OnboardingLendingPreferencesUpdated event,
    Emitter<OnboardingState> emit,
  ) {
    final isComplete = event.maxLendingAmount > 0 && event.termsAccepted;

    emit(state.copyWith(
      maxLendingAmount: event.maxLendingAmount,
      termsAccepted: event.termsAccepted,
      isLendingSetupComplete: isComplete,
    ));
  }

  /// Handle onboarding submission
  Future<void> _onSubmitted(
    OnboardingSubmitted event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(state.copyWith(status: OnboardingStatus.loading));

    try {
      final result = await _onboardingRepository.submitOnboarding(
        streetAddress: state.streetAddress,
        city: state.city,
        state: state.state,
        pincode: state.pincode,
        idType: state.idType,
        idNumber: state.idNumber,
        documentPath: state.documentPath!,
        selfiePath: state.selfiePath!,
        maxLendingAmount: state.userRole == 'lender' ? state.maxLendingAmount : null,
        termsAccepted: state.userRole == 'lender' ? state.termsAccepted : null,
      );

      result.fold(
        (failure) => emit(state.copyWith(
          status: OnboardingStatus.error,
          errorMessage: failure.message,
        )),
        (user) => emit(state.copyWith(
          status: OnboardingStatus.success,
        )),
      );
    } catch (e) {
      emit(state.copyWith(
        status: OnboardingStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Reset onboarding state
  void _onReset(
    OnboardingReset event,
    Emitter<OnboardingState> emit,
  ) {
    emit(OnboardingState.initial(role: state.userRole));
  }

  /// Set user role
  void _onUserRoleSet(
    OnboardingUserRoleSet event,
    Emitter<OnboardingState> emit,
  ) {
    emit(OnboardingState.initial(role: event.role));
  }
}
