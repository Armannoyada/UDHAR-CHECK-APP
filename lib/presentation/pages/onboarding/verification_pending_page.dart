import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routes/app_router.dart';
import '../../bloc/auth/auth_bloc.dart';

class VerificationPendingPage extends StatelessWidget {
  const VerificationPendingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWideScreen = constraints.maxWidth > 600;
            
            return Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isWideScreen ? 48 : 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // App Logo
                      _buildAppLogo(),
                      const SizedBox(height: 40),

                      // Pending Icon
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.access_time_rounded,
                          size: 56,
                          color: AppColors.warning,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Title
                      Text(
                        'Verification Pending',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.warning,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),

                      // Description
                      Text(
                        'Your account is under review by our admin team. This usually takes 24-48 hours. We will notify you once your account is verified.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.gray600,
                              height: 1.5,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),

                      // Documents Status Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.gray50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.gray200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Documents Under Review:',
                              style: TextStyle(
                                color: AppColors.gray900,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildDocumentStatus(
                              'Identity Verification',
                              'Under Review',
                            ),
                            const SizedBox(height: 12),
                            _buildDocumentStatus(
                              'Address Verification',
                              'Under Review',
                            ),
                            const SizedBox(height: 12),
                            _buildDocumentStatus(
                              'Selfie Verification',
                              'Under Review',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Logout Button
                      TextButton.icon(
                        onPressed: () {
                          context.read<AuthBloc>().add(const AuthLogoutRequested());
                          Navigator.of(context).pushReplacementNamed(AppRouter.login);
                        },
                        icon: const Icon(
                          Icons.logout,
                          color: AppColors.gray600,
                        ),
                        label: const Text(
                          'Logout',
                          style: TextStyle(
                            color: AppColors.gray600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Support Contact
                      const Text(
                        'Need help? Contact us at',
                        style: TextStyle(
                          color: AppColors.gray500,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'support@udhar.com',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppLogo() {
    return Column(
      children: [
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'उधार',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: ' CHECK',
                style: TextStyle(
                  color: AppColors.secondary,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentStatus(String title, String status) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.gray700,
            fontSize: 14,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            status,
            style: const TextStyle(
              color: AppColors.warning,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
