import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/routes/app_router.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../widgets/auth_widgets.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _selectedRole = 'borrower';

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            AuthRegisterRequested(
              firstName: _firstNameController.text.trim(),
              lastName: _lastNameController.text.trim(),
              email: _emailController.text.trim(),
              phoneNumber: _phoneController.text.trim(),
              password: _passwordController.text,
              confirmPassword: _confirmPasswordController.text,
              role: _selectedRole,
            ),
          );
    }
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.error && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.danger,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state.status == AuthStatus.authenticated) {
            // Check if user needs onboarding
            final user = state.user;
            if (user != null && user.needsOnboarding) {
              // Navigate to onboarding
              Navigator.of(context).pushReplacementNamed(AppRouter.onboarding);
            } else if (user != null && user.isPendingVerification) {
              // Navigate to verification pending
              Navigator.of(context).pushReplacementNamed(AppRouter.verificationPending);
            } else {
              // Navigate to home
              Navigator.of(context).pushReplacementNamed(AppRouter.home);
            }
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
        // Left Section - Registration Form
        Expanded(
          flex: 2,
          child: Container(
            color: AppColors.white,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(48),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: _buildRegistrationForm(state),
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
          padding: const EdgeInsets.all(24),
          child: _buildRegistrationForm(state),
        ),
      ),
    );
  }

  /// Registration form widget
  Widget _buildRegistrationForm(AuthState state) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo
          const AppLogo(),
          const SizedBox(height: 32),
          
          // Create Account Text
          Text(
            'Create Account',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.gray900,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Join our trusted lending community',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.gray500,
                ),
          ),
          const SizedBox(height: 24),
          
          // Role Selection
          _buildRoleSelector(),
          const SizedBox(height: 24),
          
          // Name Fields (Side by Side)
          Row(
            children: [
              Expanded(
                child: AuthTextField(
                  controller: _firstNameController,
                  label: 'FIRST NAME',
                  hintText: 'First name',
                  prefixIcon: Icons.person_outline,
                  validator: (value) => Validators.validateName(value),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AuthTextField(
                  controller: _lastNameController,
                  label: 'LAST NAME',
                  hintText: 'Last name',
                  prefixIcon: Icons.person_outline,
                  validator: (value) => Validators.validateName(value),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Email Field
          AuthTextField(
            controller: _emailController,
            label: 'EMAIL',
            hintText: 'Enter your email',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
            validator: Validators.validateEmail,
          ),
          const SizedBox(height: 16),
          
          // Phone Field
          AuthTextField(
            controller: _phoneController,
            label: 'PHONE NUMBER',
            hintText: 'Enter your phone number',
            keyboardType: TextInputType.phone,
            prefixIcon: Icons.phone_outlined,
            validator: Validators.validatePhone,
          ),
          const SizedBox(height: 16),
          
          // Password Field
          AuthTextField(
            controller: _passwordController,
            label: 'PASSWORD',
            hintText: 'Create a password',
            obscureText: _obscurePassword,
            prefixIcon: Icons.lock_outline,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: AppColors.gray400,
              ),
              onPressed: () {
                setState(() => _obscurePassword = !_obscurePassword);
              },
            ),
            validator: Validators.validatePassword,
          ),
          const SizedBox(height: 16),
          
          // Confirm Password Field
          AuthTextField(
            controller: _confirmPasswordController,
            label: 'CONFIRM PASSWORD',
            hintText: 'Confirm your password',
            obscureText: _obscureConfirmPassword,
            prefixIcon: Icons.lock_outline,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                color: AppColors.gray400,
              ),
              onPressed: () {
                setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
              },
            ),
            validator: _validateConfirmPassword,
          ),
          const SizedBox(height: 32),
          
          // Create Account Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: state.isLoading ? null : _handleRegister,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
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
                      'Create Account',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Sign In Link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Already have an account? ',
                style: TextStyle(
                  color: AppColors.gray500,
                  fontSize: 14,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Sign in',
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

  /// Role selector widget
  Widget _buildRoleSelector() {
    return Row(
      children: [
        Expanded(
          child: _RoleCard(
            title: 'Borrower',
            subtitle: 'I need money',
            icon: '💰',
            isSelected: _selectedRole == 'borrower',
            onTap: () => setState(() => _selectedRole = 'borrower'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _RoleCard(
            title: 'Lender',
            subtitle: 'I want to lend',
            icon: '💵',
            isSelected: _selectedRole == 'lender',
            onTap: () => setState(() => _selectedRole = 'lender'),
          ),
        ),
      ],
    );
  }
}

/// Role selection card widget
class _RoleCard extends StatelessWidget {

  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });
  final String title;
  final String subtitle;
  final String icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.05) : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.gray200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.primary : AppColors.gray700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.gray500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
