import 'package:json_annotation/json_annotation.dart';
import 'user_model.dart';

part 'auth_response.g.dart';

/// Login Response Model
@JsonSerializable()
class LoginResponse {
  LoginResponse({
    required this.success,
    this.message,
    this.accessToken,
    this.refreshToken,
    this.user,
  });

  /// Custom fromJson to handle nested 'data' structure from backend
  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    return LoginResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
      // Backend sends 'token' inside 'data', not 'accessToken'
      accessToken: data?['token'] as String?,
      refreshToken: data?['refreshToken'] as String?,
      user: data?['user'] == null
          ? null
          : User.fromJson(data!['user'] as Map<String, dynamic>),
    );
  }
  final bool success;
  final String? message;
  final String? accessToken;
  final String? refreshToken;
  final User? user;
  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
}

/// Register Response Model
@JsonSerializable()
class RegisterResponse {
  RegisterResponse({
    required this.success,
    this.message,
    this.accessToken,
    this.refreshToken,
    this.user,
  });

  /// Custom fromJson to handle nested 'data' structure from backend
  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    
    String? token;
    User? user;
    
    if (data != null) {
      token = data['token'] as String?;
      
      if (data['user'] != null) {
        try {
          user = User.fromJson(data['user'] as Map<String, dynamic>);
        } catch (e) {
          print('❌ Error parsing user in RegisterResponse: $e');
        }
      }
    }
    
    return RegisterResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
      accessToken: token,
      refreshToken: data?['refreshToken'] as String?,
      user: user,
    );
  }
  final bool success;
  final String? message;
  final String? accessToken;
  final String? refreshToken;
  final User? user;
  Map<String, dynamic> toJson() => _$RegisterResponseToJson(this);
}

/// Login Request Model
@JsonSerializable()
class LoginRequest {
  LoginRequest({
    required this.email,
    required this.password,
  });

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);
  final String email;
  final String password;
  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}

/// Register Request Model
@JsonSerializable()
class RegisterRequest {
  // 'borrower' or 'lender'

  RegisterRequest({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.password,
    required this.confirmPassword,
    required this.role,
  });

  factory RegisterRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestFromJson(json);
  final String firstName;
  final String lastName;
  final String email;
  @JsonKey(name: 'phone')
  final String phoneNumber;
  final String password;
  final String confirmPassword;
  final String role;
  Map<String, dynamic> toJson() => _$RegisterRequestToJson(this);
}

/// Refresh Token Response Model
@JsonSerializable()
class RefreshTokenResponse {
  RefreshTokenResponse({
    required this.success,
    this.accessToken,
    this.refreshToken,
    this.message,
  });

  factory RefreshTokenResponse.fromJson(Map<String, dynamic> json) =>
      _$RefreshTokenResponseFromJson(json);
  final bool success;
  final String? accessToken;
  final String? refreshToken;
  final String? message;
  Map<String, dynamic> toJson() => _$RefreshTokenResponseToJson(this);
}
