# Setup Guide - Udhar Check App

## Initial Setup Steps

### 1. Install Dependencies
Run the following command to install all packages:
```bash
flutter pub get
```

### 2. Run Code Generation
This project uses code generation for JSON serialization, dependency injection, and more:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Or for watch mode (automatically regenerates on file changes):
```bash
flutter pub run build_runner watch --delete-conflicting-outputs
```

### 3. Configure API Base URL
Update the API base URL in `lib/core/utils/constants.dart`:
```dart
static const String baseUrl = 'https://your-api-url.com/api/v1';
```

### 4. Add API Endpoints
Add your Node.js API endpoints in `lib/core/utils/constants.dart`:
```dart
static const String login = '/auth/login';
static const String getItems = '/items';
// Add more endpoints as needed
```

## Project Structure Explained

```
lib/
├── core/                           # Core functionality
│   ├── di/                        # Dependency injection
│   ├── error/                     # Error handling
│   ├── network/                   # API client & network utilities
│   ├── routes/                    # App routing
│   ├── theme/                     # App theming
│   ├── usecases/                  # Base usecase
│   ├── utils/                     # Constants & validators
│   └── widgets/                   # Common widgets
│
├── data/                          # Data layer
│   ├── datasources/
│   │   ├── local/                # Local storage (SharedPreferences)
│   │   └── remote/               # API calls (Retrofit + Dio)
│   ├── models/                   # Data models with JSON serialization
│   └── repositories/             # Repository implementations
│
├── domain/                        # Business logic layer
│   ├── entities/                 # Business objects
│   ├── repositories/             # Repository interfaces
│   └── usecases/                 # Business logic operations
│
└── presentation/                  # UI layer
    ├── bloc/                     # State management (BLoC)
    ├── pages/                    # Screen widgets
    └── widgets/                  # Reusable UI components
```

## How to Implement a New Feature

### Example: Creating a Login Feature

#### Step 1: Create Entity (Domain Layer)
`lib/domain/entities/user.dart`
```dart
class User extends Equatable {
  final String id;
  final String email;
  final String name;
  
  const User({required this.id, required this.email, required this.name});
  
  @override
  List<Object> get props => [id, email, name];
}
```

#### Step 2: Create Repository Interface (Domain Layer)
`lib/domain/repositories/auth_repository.dart`
```dart
abstract class AuthRepository {
  Future<Either<Failure, User>> login(String email, String password);
}
```

#### Step 3: Create Use Case (Domain Layer)
`lib/domain/usecases/login_usecase.dart`
```dart
class LoginUseCase implements UseCase<User, LoginParams> {
  final AuthRepository repository;
  
  LoginUseCase(this.repository);
  
  @override
  Future<Either<Failure, User>> call(LoginParams params) async {
    return await repository.login(params.email, params.password);
  }
}

class LoginParams extends Equatable {
  final String email;
  final String password;
  
  const LoginParams({required this.email, required this.password});
  
  @override
  List<Object> get props => [email, password];
}
```

#### Step 4: Create Model (Data Layer)
`lib/data/models/user_model.dart`
```dart
@JsonSerializable()
class UserModel {
  final String id;
  final String email;
  final String name;
  
  UserModel({required this.id, required this.email, required this.name});
  
  factory UserModel.fromJson(Map<String, dynamic> json) => 
      _$UserModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
  
  User toEntity() => User(id: id, email: email, name: name);
}
```

#### Step 5: Create Remote Data Source (Data Layer)
`lib/data/datasources/remote/auth_remote_data_source.dart`
```dart
@RestApi()
abstract class AuthRemoteDataSource {
  factory AuthRemoteDataSource(Dio dio) = _AuthRemoteDataSource;
  
  @POST('/auth/login')
  Future<UserModel> login(@Body() Map<String, dynamic> data);
}
```

#### Step 6: Implement Repository (Data Layer)
`lib/data/repositories/auth_repository_impl.dart`
```dart
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  
  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });
  
  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure('No internet connection'));
    }
    
    try {
      final result = await remoteDataSource.login({
        'email': email,
        'password': password,
      });
      return Right(result.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
```

#### Step 7: Create BLoC (Presentation Layer)
`lib/presentation/bloc/auth/auth_bloc.dart`
```dart
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  
  AuthBloc({required this.loginUseCase}) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
  }
  
  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    final result = await loginUseCase(
      LoginParams(email: event.email, password: event.password),
    );
    
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthSuccess(user)),
    );
  }
}
```

#### Step 8: Create UI (Presentation Layer)
`lib/presentation/pages/login/login_page.dart`
```dart
class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AuthBloc>(),
      child: LoginView(),
    );
  }
}
```

#### Step 9: Register Dependencies (Core Layer)
Add to `lib/core/di/injection_container.dart` after setting up injectable:
```dart
@module
abstract class AppModule {
  @lazySingleton
  AuthRemoteDataSource authRemoteDataSource(ApiClient client) =>
      AuthRemoteDataSource(client.dio);
      
  @LazySingleton(as: AuthRepository)
  AuthRepositoryImpl authRepository(
    AuthRemoteDataSource remoteDataSource,
    NetworkInfo networkInfo,
  ) => AuthRepositoryImpl(
    remoteDataSource: remoteDataSource,
    networkInfo: networkInfo,
  );
  
  @lazySingleton
  LoginUseCase loginUseCase(AuthRepository repository) =>
      LoginUseCase(repository);
      
  @lazySingleton
  AuthBloc authBloc(LoginUseCase loginUseCase) =>
      AuthBloc(loginUseCase: loginUseCase);
}
```

## Running the App

### Development Mode
```bash
flutter run
```

### Build APK (Android)
```bash
flutter build apk --release
```

### Build App Bundle (Android)
```bash
flutter build appbundle --release
```

### Build iOS
```bash
flutter build ios --release
```

## Testing

### Run all tests
```bash
flutter test
```

### Run with coverage
```bash
flutter test --coverage
```

## Common Commands

```bash
# Clean build
flutter clean

# Get dependencies
flutter pub get

# Run code generation
flutter pub run build_runner build --delete-conflicting-outputs

# Check for outdated packages
flutter pub outdated

# Upgrade packages
flutter pub upgrade

# Analyze code
flutter analyze

# Format code
dart format .
```

## Next Steps

1. **Update API Base URL** in `lib/core/utils/constants.dart`
2. **Configure Android permissions** in `android/app/src/main/AndroidManifest.xml`
3. **Configure iOS permissions** in `ios/Runner/Info.plist`
4. **Add app icons** and splash screens
5. **Implement your features** following the clean architecture pattern
6. **Write tests** for business logic
7. **Configure Firebase** (if needed)
8. **Set up CI/CD** pipeline

## Helpful Tips

- Always run code generation after creating/modifying models or data sources
- Use `const` constructors whenever possible for better performance
- Follow the dependency rule: dependencies should point inward
- Keep business logic in use cases, not in BLoCs
- Use `Either<Failure, Success>` for error handling
- Write unit tests for use cases and repositories

## Need Help?

- Check the example files in each layer for reference
- Follow the pattern shown in the example implementations
- Make sure to register all dependencies in the DI container
- Run `flutter pub run build_runner build` after any changes to generated files

---

**Your clean architecture foundation is ready! Start building your features now.** 🚀
