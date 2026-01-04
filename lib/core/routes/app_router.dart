import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../../presentation/pages/splash/splash_page.dart';
import '../../presentation/pages/home/home_page.dart';
import '../../presentation/pages/home/lender_home_page.dart';
import '../../presentation/pages/auth/login_page.dart';
import '../../presentation/pages/auth/register_page.dart';
import '../../presentation/pages/onboarding/onboarding_page.dart';
import '../../presentation/pages/onboarding/verification_pending_page.dart';
import '../../presentation/pages/notifications/notifications_page.dart';
import '../../presentation/pages/history/history_page.dart';
import '../../presentation/pages/profile/profile_page.dart';
import '../../presentation/pages/admin/admin_home_page.dart';

class AppRouter {
  static const String splash = '/';
  static const String home = '/home';
  static const String lenderHome = '/lender-home';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String onboarding = '/onboarding';
  static const String verificationPending = '/verification-pending';
  static const String notifications = '/notifications';
  static const String history = '/history';
  static const String profile = '/profile';
  static const String adminHome = '/admin-home';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(
          builder: (_) => const SplashPage(),
        );

      case home:
        return MaterialPageRoute(
          builder: (_) => const HomePage(),
        );

      case lenderHome:
        return MaterialPageRoute(
          builder: (_) => const LenderHomePage(),
        );

      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
        );

      case register:
        return MaterialPageRoute(
          builder: (_) => const RegisterPage(),
        );

      case forgotPassword:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Forgot Password - To be implemented')),
          ),
        );

      case onboarding:
        return MaterialPageRoute(
          builder: (_) => const OnboardingPage(),
        );

      case verificationPending:
        return MaterialPageRoute(
          builder: (_) => const VerificationPendingPage(),
        );

      case notifications:
        return MaterialPageRoute(
          builder: (_) => const NotificationsPage(),
        );

      case history:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.white,
              elevation: 0,
              leading: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.gray700),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              title: const Text(
                'History',
                style: TextStyle(
                  color: AppColors.gray900,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              centerTitle: true,
            ),
            body: const HistoryPage(),
          ),
        );

      case profile:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.white,
              elevation: 0,
              leading: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.gray700),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              title: const Text(
                'Profile',
                style: TextStyle(
                  color: AppColors.gray900,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              centerTitle: true,
            ),
            body: const ProfilePage(),
          ),
        );

      case adminHome:
        return MaterialPageRoute(
          builder: (_) => const AdminHomePage(),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Page not found')),
          ),
        );
    }
  }
}
