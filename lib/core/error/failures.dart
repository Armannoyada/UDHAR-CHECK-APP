import 'package:equatable/equatable.dart';

/// Base class for all failures in the application
abstract class Failure extends Equatable {
  final String message;
  
  const Failure(this.message);
  
  @override
  List<Object> get props => [message];
}

/// Server-related failures
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// Cache-related failures
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// Network-related failures
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Authentication failures
class AuthenticationFailure extends Failure {
  const AuthenticationFailure(super.message);
}

/// Validation failures
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Generic failures
class GeneralFailure extends Failure {
  const GeneralFailure(super.message);
}
