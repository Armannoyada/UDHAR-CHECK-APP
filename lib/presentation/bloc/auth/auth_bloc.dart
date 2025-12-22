import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/user_model.dart';
import '../../../domain/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthState.initial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthClearError>(_onClearAuthError);
    on<AuthRoleSelected>(_onRoleSelected);
    on<AuthUserUpdated>(_onUserUpdated);
  }
  final AuthRepository _authRepository;

  /// Handle login request
  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWithLoading());

    final result = await _authRepository.login(
      email: event.email,
      password: event.password,
    );

    result.fold(
      (failure) => emit(state.copyWithError(failure.message)),
      (user) => emit(state.copyWithAuthenticated(user)),
    );
  }

  /// Handle register request
  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWithLoading());

    final result = await _authRepository.register(
      firstName: event.firstName,
      lastName: event.lastName,
      email: event.email,
      phoneNumber: event.phoneNumber,
      password: event.password,
      confirmPassword: event.confirmPassword,
      role: event.role,
    );

    result.fold(
      (failure) => emit(state.copyWithError(failure.message)),
      (user) => emit(state.copyWithAuthenticated(user)),
    );
  }

  /// Handle logout request
  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWithLoading());

    final result = await _authRepository.logout();

    result.fold(
      (failure) => emit(state.copyWithError(failure.message)),
      (_) => emit(state.copyWithUnauthenticated()),
    );
  }

  /// Check authentication status
  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final isLoggedIn = await _authRepository.isLoggedIn();

    if (isLoggedIn) {
      final result = await _authRepository.getCurrentUser();
      result.fold(
        (failure) => emit(state.copyWithUnauthenticated()),
        (user) => emit(state.copyWithAuthenticated(user)),
      );
    } else {
      emit(state.copyWithUnauthenticated());
    }
  }

  /// Clear error
  void _onClearAuthError(
    AuthClearError event,
    Emitter<AuthState> emit,
  ) {
    emit(state.copyWith(errorMessage: null, status: AuthStatus.initial));
  }

  /// Handle role selection
  void _onRoleSelected(
    AuthRoleSelected event,
    Emitter<AuthState> emit,
  ) {
    emit(state.copyWith(selectedRole: event.role));
  }

  /// Handle user updated
  void _onUserUpdated(
    AuthUserUpdated event,
    Emitter<AuthState> emit,
  ) {
    emit(state.copyWithAuthenticated(event.user));
  }
}
