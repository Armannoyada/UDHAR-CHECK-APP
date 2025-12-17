# Udhar Check App

A Flutter application built with Clean Architecture principles.

## Architecture Overview

This project follows Clean Architecture pattern with three main layers:

### 1. Presentation Layer (`lib/presentation/`)
- **Pages**: Screen-level widgets
- **Widgets**: Reusable UI components
- **Bloc/Cubit**: State management using flutter_bloc

### 2. Domain Layer (`lib/domain/`)
- **Entities**: Business objects (pure Dart classes)
- **Repositories**: Abstract repository interfaces
- **Usecases**: Business logic operations

### 3. Data Layer (`lib/data/`)
- **Models**: Data transfer objects with JSON serialization
- **Repositories**: Concrete implementations of domain repositories
- **Datasources**: 
  - Remote: API calls using Retrofit + Dio
  - Local: Local storage using SharedPreferences/Secure Storage

### Core (`lib/core/`)
- **DI**: Dependency injection setup (get_it + injectable)
- **Error**: Error handling and failures
- **Network**: Network utilities and interceptors
- **Routes**: App navigation
- **Theme**: App theming
- **Utils**: Constants, validators, helpers
- **Widgets**: Common widgets used across the app

## Project Structure

```
lib/
├── core/
│   ├── di/
│   │   └── injection_container.dart
│   ├── error/
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   ├── network/
│   │   ├── api_client.dart
│   │   └── network_info.dart
│   ├── routes/
│   │   └── app_router.dart
│   ├── theme/
│   │   └── app_theme.dart
│   ├── usecases/
│   │   └── usecase.dart
│   ├── utils/
│   │   ├── constants.dart
│   │   └── validators.dart
│   └── widgets/
│       ├── custom_button.dart
│       └── loading_indicator.dart
├── data/
│   ├── datasources/
│   │   ├── local/
│   │   └── remote/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
├── presentation/
│   ├── pages/
│   │   └── splash/
│   ├── widgets/
│   └── bloc/
└── main.dart
```

## Getting Started

### Prerequisites
- Flutter SDK (>=3.0.0)
- Dart SDK
- Android Studio / VS Code

### Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run code generation:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. Run the app:
   ```bash
   flutter run
   ```

## Key Dependencies

- **flutter_bloc**: State management
- **get_it**: Dependency injection
- **dio**: HTTP client
- **retrofit**: Type-safe REST client
- **dartz**: Functional programming (Either for error handling)
- **freezed**: Code generation for immutable classes
- **json_serializable**: JSON serialization

## Clean Architecture Benefits

✅ **Separation of Concerns**: Each layer has a clear responsibility  
✅ **Testability**: Easy to write unit tests for business logic  
✅ **Maintainability**: Changes in one layer don't affect others  
✅ **Scalability**: Easy to add new features  
✅ **Independence**: Framework and UI independent business logic  

## Development Guidelines

1. **Data Flow**: Presentation → Domain → Data
2. **Dependency Rule**: Inner layers should not depend on outer layers
3. **Use Cases**: Each use case should do one thing
4. **Error Handling**: Use Either<Failure, Success> pattern
5. **State Management**: Use BLoC pattern for complex state, Cubit for simple state

## Next Steps

Ready to implement features! The clean architecture foundation is set up.
You can now add:
- API endpoints in `data/datasources/remote/`
- Business entities in `domain/entities/`
- Use cases in `domain/usecases/`
- UI screens in `presentation/pages/`
- State management in `presentation/bloc/`
