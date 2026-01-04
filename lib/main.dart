import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udhar_check_app/data/models/loan_model.dart';
import 'package:udhar_check_app/presentation/pages/home/lender_home_page.dart';
import 'package:udhar_check_app/presentation/pages/loans/loan_requests_page.dart';
import 'package:udhar_check_app/presentation/pages/loans/my_lending_page.dart';
import 'package:udhar_check_app/presentation/pages/loans/my_requests_page.dart';
import 'package:udhar_check_app/presentation/pages/loans/new_request_page.dart';
import 'package:udhar_check_app/presentation/pages/notifications/notifications_page.dart';
import 'package:udhar_check_app/presentation/pages/profile/profile_page.dart';
import 'core/di/injection_container.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'presentation/bloc/auth/auth_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection
  await configureDependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) =>
              getIt<AuthBloc>()..add(const AuthCheckRequested()),
        ),
      ],
      child: MaterialApp(
        title: 'उधार Check',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        onGenerateRoute: AppRouter.onGenerateRoute,
        initialRoute: AppRouter.splash,
      ),
    );
  }
}
