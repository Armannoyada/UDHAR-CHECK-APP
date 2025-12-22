import 'package:get_it/get_it.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../network/api_client.dart';
import '../network/network_info.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/storage_service.dart';
import '../../data/services/onboarding_service.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/onboarding_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../../presentation/bloc/auth/auth_bloc.dart';
import '../../presentation/bloc/onboarding/onboarding_bloc.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // External dependencies
  getIt.registerLazySingleton(() => Connectivity());
  
  // Core
  getIt.registerLazySingleton(() => ApiClient());
  getIt.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(getIt<Connectivity>()),
  );
  
  // Storage
  final storageService = await StorageService.getInstance();
  getIt.registerLazySingleton(() => storageService);
  
  // Services
  getIt.registerLazySingleton(
    () => AuthService(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton(
    () => OnboardingService(getIt<ApiClient>()),
  );
  
  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      authService: getIt<AuthService>(),
      storageService: getIt<StorageService>(),
      networkInfo: getIt<NetworkInfo>(),
    ),
  );
  getIt.registerLazySingleton<OnboardingRepository>(
    () => OnboardingRepositoryImpl(
      onboardingService: getIt<OnboardingService>(),
      storageService: getIt<StorageService>(),
      networkInfo: getIt<NetworkInfo>(),
    ),
  );
  
  // BLoCs
  getIt.registerFactory(
    () => AuthBloc(authRepository: getIt<AuthRepository>()),
  );
  getIt.registerFactory(
    () => OnboardingBloc(onboardingRepository: getIt<OnboardingRepository>()),
  );
}
