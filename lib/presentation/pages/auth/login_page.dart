import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/routes/app_router.dart';
import '../../../data/models/user_model.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../widgets/auth_widgets.dart';

/// User role enum for demo access
enum DemoRole { admin, lender, borrower }

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            AuthLoginRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ),
          );
    }
  }

  /// Handle quick demo access with pre-filled credentials
  void _handleDemoAccess(DemoRole role) {
    String email;
    String password;

    switch (role) {
      case DemoRole.admin:
        email = 'admin@udharcheck.com';
        password = 'admin123';
        break;
      case DemoRole.lender:
        email = 'lender@udharcheck.com';
        password = 'lender123';
        break;
      case DemoRole.borrower:
        email = 'borrower@udharcheck.com';
        password = 'borrower123';
        break;
    }

    context.read<AuthBloc>().add(
          AuthLoginRequested(
            email: email,
            password: password,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: BlocConsumer<AuthBloc, AuthState>(
        listenWhen: (previous, current) {
          // Only listen when status changes
          return previous.status != current.status;
        },
        listener: (context, state) {
          if (state.status == AuthStatus.error && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Login Failed',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            state.errorMessage!,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                backgroundColor: AppColors.danger,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 5),
                action: SnackBarAction(
                  label: 'DISMISS',
                  textColor: AppColors.white,
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  },
                ),
              ),
            );
          } else if (state.status == AuthStatus.authenticated) {
            // Check if user needs onboarding
            final user = state.user;
            print('🔍 User logged in:');
            print('   - isOnboardingComplete: ${user?.isOnboardingComplete}');
            print('   - verificationStatus: ${user?.verificationStatus}');
            print('   - needsOnboarding: ${user?.needsOnboarding}');
            print('   - isPendingVerification: ${user?.isPendingVerification}');

            // Navigate after frame is complete
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!context.mounted) return;

              if (user != null && user.needsOnboarding) {
                // Navigate to onboarding
                print('📝 Navigating to onboarding...');
                Navigator.of(context)
                    .pushReplacementNamed(AppRouter.onboarding);
              } else if (user != null && user.isPendingVerification) {
                // Navigate to verification pending
                print('⏳ Navigating to verification pending...');
                Navigator.of(context)
                    .pushReplacementNamed(AppRouter.verificationPending);
              } else {
                // Navigate to home based on role
                print('🏠 Navigating to home... Role: ${user?.role}');
                if (user?.role == UserRole.lender) {
                  Navigator.of(context).pushReplacementNamed(AppRouter.lenderHome);
                } else {
                  Navigator.of(context).pushReplacementNamed(AppRouter.home);
                }
              }
            });
          }
        },
        builder: (context, state) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final isWideScreen = constraints.maxWidth > 800;

              if (isWideScreen) {
                return _buildWideLayout(state);
              } else {
                return _buildNarrowLayout(state);
              }
            },
          );
        },
      ),
    );
  }

  /// Wide screen layout (tablet/desktop) - Split view
  Widget _buildWideLayout(AuthState state) {
    return Row(
      children: [
        // Left Section - Login Form
        Expanded(
          flex: 2,
          child: Container(
            color: AppColors.white,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(48),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: _buildLoginForm(state),
                ),
              ),
            ),
          ),
        ),
        // Right Section - Branding
        const Expanded(
          flex: 3,
          child: AuthBrandingSection(),
        ),
      ],
    );
  }

  /// Narrow screen layout (mobile) - Single column
  Widget _buildNarrowLayout(AuthState state) {
    return Container(
      color: AppColors.white,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: _buildLoginForm(state),
        ),
      ),
    );
  }

  /// Login form widget
  Widget _buildLoginForm(AuthState state) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo - Centered
          const Center(child: AppLogo()),
          const SizedBox(height: 40),

          // Welcome Text
          Text(
            'Welcome Back',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.gray900,
                  fontSize: 28,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sign in to continue to your account',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.gray500,
                  fontSize: 15,
                ),
          ),
          const SizedBox(height: 32),

          // Email Field
          AuthTextField(
            controller: _emailController,
            label: 'EMAIL',
            hintText: 'Enter your email',
            keyboardType: TextInputType.emailAddress,
            validator: Validators.validateEmail,
          ),
          const SizedBox(height: 20),

          // Password Field
          AuthTextField(
            controller: _passwordController,
            label: 'PASSWORD',
            hintText: 'Enter your password',
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppColors.gray400,
                size: 20,
              ),
              onPressed: () {
                setState(() => _obscurePassword = !_obscurePassword);
              },
            ),
            validator: Validators.validatePassword,
          ),
          const SizedBox(height: 8),

          // Forgot Password
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed(AppRouter.forgotPassword);
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Forgot password?',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Sign In Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: state.isLoading ? null : _handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: state.isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 32),

          // Quick Demo Access Section
          _buildQuickDemoAccess(state),
          const SizedBox(height: 32),

          // Sign Up Link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Don't have an account? ",
                style: TextStyle(
                  color: AppColors.gray500,
                  fontSize: 14,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRouter.register);
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Sign up',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Quick Demo Access section with role buttons
  Widget _buildQuickDemoAccess(AuthState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Demo Access',
          style: TextStyle(
            color: AppColors.gray900,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Explore the platform without registration',
          style: TextStyle(
            color: AppColors.gray500,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 16),
        // Role Buttons
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildDemoRoleButton(
              role: DemoRole.admin,
              icon: '🔥',
              label: 'Admin',
              subtitle: 'Manage platform',
              isLoading: state.isLoading,
            ),
            _buildDemoRoleButton(
              role: DemoRole.lender,
              icon: '💰',
              label: 'Lender',
              subtitle: 'Lend money',
              isLoading: state.isLoading,
            ),
            _buildDemoRoleButton(
              role: DemoRole.borrower,
              icon: '📋',
              label: 'Borrower',
              subtitle: 'Request loans',
              isLoading: state.isLoading,
            ),
          ],
        ),
      ],
    );
  }

  /// Demo role button widget
  Widget _buildDemoRoleButton({
    required DemoRole role,
    required String icon,
    required String label,
    required String subtitle,
    required bool isLoading,
  }) {
    return InkWell(
      onTap: isLoading ? null : () => _handleDemoAccess(role),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.gray50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.gray200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.gray900,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.gray500,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
