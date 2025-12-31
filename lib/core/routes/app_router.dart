import 'package:flutter/material.dart';
import '../../presentation/pages/splash/splash_page.dart';
import '../../presentation/pages/home/home_page.dart';
import '../../presentation/pages/home/lender_home_page.dart';
import '../../presentation/pages/auth/login_page.dart';
import '../../presentation/pages/auth/register_page.dart';
import '../../presentation/pages/onboarding/onboarding_page.dart';
import '../../presentation/pages/onboarding/verification_pending_page.dart';

class AppRouter {
  static const String splash = '/';
  static const String home = '/home';
  static const String lenderHome = '/lender-home';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String onboarding = '/onboarding';
  static const String verificationPending = '/verification-pending';
  
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
      
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Page not found')),
          ),
        );
    }
  }
}
