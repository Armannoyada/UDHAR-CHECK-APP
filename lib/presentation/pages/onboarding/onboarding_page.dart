import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/di/injection_container.dart';
import '../../../data/models/user_model.dart';
import '../../../domain/repositories/onboarding_repository.dart';
import '../../bloc/onboarding/onboarding_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import 'steps/address_step_page.dart';
import 'steps/id_verification_step_page.dart';
import 'steps/selfie_step_page.dart';
import 'steps/lending_setup_step_page.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get user role from auth state
    final authState = context.read<AuthBloc>().state;
    final userRole = authState.user?.role.name ?? 'borrower';

    return BlocProvider(
      create: (context) => OnboardingBloc(
        onboardingRepository: getIt<OnboardingRepository>(),
      )..add(OnboardingUserRoleSet(role: userRole)),
      child: const OnboardingContent(),
    );
  }
}

class OnboardingContent extends StatelessWidget {
  const OnboardingContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: BlocConsumer<OnboardingBloc, OnboardingState>(
        listener: (context, state) {
          if (state.status == OnboardingStatus.error &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.danger,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state.status == OnboardingStatus.success) {
            // Update auth bloc with the updated user from onboarding response
            final completedUser = state.completedUser;
            if (completedUser != null) {
              context
                  .read<AuthBloc>()
                  .add(AuthUserUpdated(user: completedUser));
              print(
                  '✅ Auth bloc updated with completed user: ${completedUser.email}');
              print(
                  '   - isOnboardingComplete: ${completedUser.isOnboardingComplete}');
              print(
                  '   - verificationStatus: ${completedUser.verificationStatus}');
            } else {
              // Fallback: Update the existing user with onboarding complete status
              final authState = context.read<AuthBloc>().state;
              if (authState.user != null) {
                final updatedUser = authState.user!.copyWith(
                  isOnboardingComplete: true,
                  verificationStatus: VerificationStatus.pending,
                );
                context
                    .read<AuthBloc>()
                    .add(AuthUserUpdated(user: updatedUser));
              }
            }

            // Navigate to verification pending page
            Navigator.of(context)
                .pushReplacementNamed(AppRouter.verificationPending);
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Column(
              children: [
                // Header with stepper
                _buildHeader(context, state),

                // Content area
                Expanded(
                  child: _buildCurrentStep(state),
                ),

                // Navigation buttons
                _buildNavigationButtons(context, state),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, OnboardingState state) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.gray200.withValues(alpha: 0.5),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // App Logo
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: 'उधार',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: ' CHECK',
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Complete your profile to get started',
            style: TextStyle(
              color: AppColors.gray500,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),

          // Step Indicator
          _buildStepIndicator(state),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(OnboardingState state) {
    return Row(
      children: List.generate(state.totalSteps, (index) {
        final isCompleted = index < state.currentStep;
        final isCurrent = index == state.currentStep;
        final stepTitle = state.stepTitles[index];

        return Expanded(
          child: Row(
            children: [
              // Step circle
              Column(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? AppColors.secondary
                          : isCurrent
                              ? AppColors.secondary
                              : AppColors.gray200,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(
                              Icons.check,
                              color: AppColors.white,
                              size: 20,
                            )
                          : Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: isCurrent
                                    ? AppColors.white
                                    : AppColors.gray500,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    stepTitle,
                    style: TextStyle(
                      color: isCompleted
                          ? AppColors.secondary
                          : isCurrent
                              ? AppColors.secondary
                              : AppColors.gray400,
                      fontSize: 12,
                      fontWeight: isCompleted || isCurrent
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              // Connector line
              if (index < state.totalSteps - 1)
                Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.only(bottom: 28),
                    color:
                        isCompleted ? AppColors.secondary : AppColors.gray200,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCurrentStep(OnboardingState state) {
    switch (state.currentStep) {
      case 0:
        return const AddressStepPage();
      case 1:
        return const IdVerificationStepPage();
      case 2:
        return const SelfieStepPage();
      case 3:
        return const LendingSetupStepPage();
      default:
        return const AddressStepPage();
    }
  }

  Widget _buildNavigationButtons(BuildContext context, OnboardingState state) {
    final isLastStep = state.isLastStep;
    final isFirstStep = state.isFirstStep;
    final isLoading = state.status == OnboardingStatus.loading;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.gray200.withValues(alpha: 0.5),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back button
          if (!isFirstStep)
            TextButton.icon(
              onPressed: isLoading
                  ? null
                  : () {
                      context
                          .read<OnboardingBloc>()
                          .add(const OnboardingPreviousStep());
                    },
              icon: const Icon(Icons.arrow_back, color: AppColors.gray600),
              label: const Text(
                'Back',
                style: TextStyle(
                  color: AppColors.gray600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

          const Spacer(),

          // Next/Complete button
          Flexible(
            child: SizedBox(
              width: isLastStep ? 200 : 120,
              height: 48,
              child: ElevatedButton(
                onPressed: isLoading || !state.isCurrentStepComplete
                    ? null
                    : () {
                        if (isLastStep) {
                          context
                              .read<OnboardingBloc>()
                              .add(const OnboardingSubmitted());
                        } else {
                          context
                              .read<OnboardingBloc>()
                              .add(const OnboardingNextStep());
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isLastStep ? AppColors.secondary : AppColors.primary,
                  foregroundColor: AppColors.white,
                  disabledBackgroundColor: AppColors.gray300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(AppColors.white),
                        ),
                      )
                    : FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isLastStep ? 'Complete Setup' : 'Next',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.arrow_forward,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
