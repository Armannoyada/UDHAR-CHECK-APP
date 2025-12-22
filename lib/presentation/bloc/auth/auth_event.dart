part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class AuthLoginRequested extends AuthEvent {
  const AuthLoginRequested({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

class AuthRegisterRequested extends AuthEvent {
  const AuthRegisterRequested({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.password,
    required this.confirmPassword,
    required this.role,
  });

  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String password;
  final String confirmPassword;
  final String role;

  @override
  List<Object?> get props => [firstName, lastName, email, phoneNumber, password, confirmPassword, role];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

class AuthForgotPasswordRequested extends AuthEvent {
  const AuthForgotPasswordRequested({required this.email});

  final String email;

  @override
  List<Object?> get props => [email];
}

class AuthUserUpdated extends AuthEvent {
  const AuthUserUpdated({required this.user});

  final User user;

  @override
  List<Object?> get props => [user];
}

class AuthClearError extends AuthEvent {
  const AuthClearError();
}

class AuthRoleSelected extends AuthEvent {
  const AuthRoleSelected(this.role);

  final String role;

  @override
  List<Object?> get props => [role];
}
