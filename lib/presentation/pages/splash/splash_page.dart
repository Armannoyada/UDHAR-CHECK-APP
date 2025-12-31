import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routes/app_router.dart';
import '../../../data/models/user_model.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../widgets/auth_widgets.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _checkAuthStatus();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  Future<void> _checkAuthStatus() async {
    // Wait for animation and splash display
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      // Wait for auth check to be completed
      await Future.delayed(const Duration(milliseconds: 500));
      _navigateBasedOnAuthState();
    }
  }

  void _navigateBasedOnAuthState() {
    if (!mounted) return;

    final authState = context.read<AuthBloc>().state;
    final user = authState.user;

    print('🔍 Splash - Auth state: ${authState.status}');
    if (user != null) {
      print('   - isOnboardingComplete: ${user.isOnboardingComplete}');
      print('   - isAdminVerified: ${user.isAdminVerified}');
      print('   - verificationStatus: ${user.verificationStatus}');
      print('   - needsOnboarding: ${user.needsOnboarding}');
      print('   - isPendingVerification: ${user.isPendingVerification}');
      print('   - role: ${user.role}');
    }

    if (authState.status == AuthStatus.authenticated && user != null) {
      // Route based on user's verification state
      if (user.needsOnboarding) {
        // User hasn't completed onboarding
        print('📝 Routing to onboarding...');
        Navigator.pushReplacementNamed(context, AppRouter.onboarding);
      } else if (user.isPendingVerification ||
          (user.isOnboardingComplete == true && user.isAdminVerified != true)) {
        // User completed onboarding but waiting for admin verification
        print('⏳ Routing to verification pending...');
        Navigator.pushReplacementNamed(context, AppRouter.verificationPending);
      } else if (user.isAdminVerified == true) {
        // User is fully verified - go to dashboard based on role
        print('🏠 Routing to home... Role: ${user.role}');
        if (user.role == UserRole.lender) {
          Navigator.pushReplacementNamed(context, AppRouter.lenderHome);
        } else {
          Navigator.pushReplacementNamed(context, AppRouter.home);
        }
      } else {
        // Fallback to home based on role
        print('🏠 Routing to home (default)... Role: ${user.role}');
        if (user.role == UserRole.lender) {
          Navigator.pushReplacementNamed(context, AppRouter.lenderHome);
        } else {
          Navigator.pushReplacementNamed(context, AppRouter.home);
        }
      }
    } else if (authState.status == AuthStatus.unauthenticated ||
        authState.status == AuthStatus.error) {
      // Not logged in
      print('🔐 Routing to login...');
      Navigator.pushReplacementNamed(context, AppRouter.login);
    } else if (authState.status == AuthStatus.initial) {
      // Still checking auth - wait a bit more
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _navigateBasedOnAuthState();
      });
    } else {
      // Default to login
      Navigator.pushReplacementNamed(context, AppRouter.login);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Auth state changes are handled in _checkAuthStatus
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primary.withValues(alpha: 0.1),
                AppColors.white,
              ],
            ),
          ),
          child: Center(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // App Logo
                        AppLogo(size: 80),
                        SizedBox(height: 48),

                        // Loading Indicator
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                          ),
                        ),
                        SizedBox(height: 24),

                        // Loading Text
                        Text(
                          'Loading...',
                          style: TextStyle(
                            color: AppColors.gray500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
