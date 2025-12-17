import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async {
  // Register third-party dependencies
  getIt.registerLazySingleton(() => Connectivity());
  
  // Initialize injectable dependencies
  // Run: flutter pub run build_runner build
  // This will generate: injection_container.config.dart
  // Uncomment the line below after running build_runner
  // await getIt.init();
}
