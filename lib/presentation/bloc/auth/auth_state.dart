part of 'auth_bloc.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthState extends Equatable {

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.selectedRole = 'borrower',
    this.isLoading = false,
  });

  /// Initial state
  factory AuthState.initial() => const AuthState();
  final AuthStatus status;
  final User? user;
  final String? errorMessage;
  final String selectedRole;
  final bool isLoading;

  /// Loading state
  AuthState copyWithLoading() => copyWith(
        status: AuthStatus.loading,
        isLoading: true,
        errorMessage: null,
      );

  /// Authenticated state
  AuthState copyWithAuthenticated(User user) => copyWith(
        status: AuthStatus.authenticated,
        user: user,
        isLoading: false,
        errorMessage: null,
      );

  /// Unauthenticated state
  AuthState copyWithUnauthenticated() => copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
        isLoading: false,
        errorMessage: null,
      );

  /// Error state
  AuthState copyWithError(String message) => copyWith(
        status: AuthStatus.error,
        errorMessage: message,
        isLoading: false,
      );

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
    String? selectedRole,
    bool? isLoading,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
      selectedRole: selectedRole ?? this.selectedRole,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [status, user, errorMessage, selectedRole, isLoading];
}
