import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

/// User Role Enum
enum UserRole {
  @JsonValue('borrower')
  borrower,
  @JsonValue('lender')
  lender,
  @JsonValue('admin')
  admin,
}

/// Verification Status Enum
enum VerificationStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('verified')
  verified,
  @JsonValue('rejected')
  rejected,
  @JsonValue('not_submitted')
  notSubmitted,
}

/// Helper to safely convert id to String (handles int, String, or null)
String _idFromJson(dynamic value) {
  if (value == null) return '';
  return value.toString();
}

/// Read user ID from JSON, checking for both 'id' and '_id' fields
dynamic _readUserId(Map<dynamic, dynamic> json, String key) {
  // Check for MongoDB's _id first, then regular id
  final value = json['_id'] ?? json['id'];
  if (value == null) return '';
  return value.toString();
}

/// Helper to safely convert dynamic value to int
int? _intFromDynamic(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is String) return int.tryParse(value);
  if (value is num) return value.toInt();
  return null;
}

/// Safely decode UserRole from JSON
UserRole _userRoleFromJson(dynamic value) {
  if (value == null) return UserRole.borrower; // default
  if (value is String) {
    final normalized = value.toLowerCase().trim();
    switch (normalized) {
      case 'borrower':
        return UserRole.borrower;
      case 'lender':
        return UserRole.lender;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.borrower;
    }
  }
  // Handle int/index
  if (value is int) {
    if (value == 0) return UserRole.borrower;
    if (value == 1) return UserRole.lender;
    if (value == 2) return UserRole.admin;
  }
  return UserRole.borrower;
}

/// Safely decode VerificationStatus from JSON  
VerificationStatus? _verificationStatusFromJson(dynamic value) {
  if (value == null) return null;
  if (value is String) {
    final normalized = value.toLowerCase().trim();
    switch (normalized) {
      case 'pending':
        return VerificationStatus.pending;
      case 'verified':
        return VerificationStatus.verified;
      case 'rejected':
        return VerificationStatus.rejected;
      case 'not_submitted':
      case 'notsubmitted':
        return VerificationStatus.notSubmitted;
      default:
        return null;
    }
  }
  return null;
}

/// Helper to safely convert string to double (handles "0.00" format from API)
double? _doubleFromString(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  if (value is num) return value.toDouble();
  return null;
}

/// User Model
@JsonSerializable()
class User {

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role, this.phoneNumber,
    this.whatsapp,
    this.profilePhoto,
    this.selfiePhoto,
    this.governmentId,
    this.governmentIdType,
    this.governmentIdNumber,
    this.isIdVerified,
    this.isFaceVerified,
    this.isOnboardingComplete,
    this.isAdminVerified,
    this.trustScore,
    this.repaymentScore,
    this.averageRating,
    this.totalRatings,
    this.verificationStatus,
    this.verificationRejectionReason,
    this.rejectedDocuments,
    this.isEmailVerified,
    this.isPhoneVerified,
    this.isActive,
    this.isBlocked,
    this.blockReason,
    this.lendingLimit,
    this.availableBalance,
    this.totalLent,
    this.totalBorrowed,
    this.termsAccepted,
    this.termsAcceptedAt,
    this.createdAt,
    this.updatedAt,
    this.dateOfBirth,
    this.gender,
    this.address,
    this.city,
    this.state,
    this.pincode,
    this.aadhaarNumber,
    this.panNumber,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  @JsonKey(name: 'id', readValue: _readUserId)
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  @JsonKey(name: 'phone')
  final String? phoneNumber;
  final String? whatsapp;
  @JsonKey(fromJson: _userRoleFromJson)
  final UserRole role;
  final String? profilePhoto;
  final String? selfiePhoto;
  final String? governmentId;
  final String? governmentIdType;
  final String? governmentIdNumber;
  final bool? isIdVerified;
  final bool? isFaceVerified;
  final bool? isOnboardingComplete;
  final bool? isAdminVerified;
  @JsonKey(fromJson: _doubleFromString)
  final double? trustScore;
  @JsonKey(fromJson: _doubleFromString)
  final double? repaymentScore;
  @JsonKey(fromJson: _doubleFromString)
  final double? averageRating;
  @JsonKey(fromJson: _intFromDynamic)
  final int? totalRatings;
  @JsonKey(fromJson: _verificationStatusFromJson)
  final VerificationStatus? verificationStatus;
  @JsonKey(name: 'rejectionReason')
  final String? verificationRejectionReason;
  final List<String>? rejectedDocuments;
  @JsonKey(name: 'emailVerified')
  final bool? isEmailVerified;
  @JsonKey(name: 'phoneVerified')
  final bool? isPhoneVerified;
  final bool? isActive;
  final bool? isBlocked;
  final String? blockReason;
  @JsonKey(fromJson: _doubleFromString)
  final double? lendingLimit;
  @JsonKey(fromJson: _doubleFromString)
  final double? availableBalance;
  @JsonKey(fromJson: _doubleFromString)
  final double? totalLent;
  @JsonKey(fromJson: _doubleFromString)
  final double? totalBorrowed;
  final bool? termsAccepted;
  final DateTime? termsAcceptedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Onboarding fields
  final DateTime? dateOfBirth;
  final String? gender;
  final String? address;
  final String? city;
  final String? state;
  final String? pincode;
  final String? aadhaarNumber;
  final String? panNumber;

  String get fullName => '$firstName $lastName';

  bool get isVerified => verificationStatus == VerificationStatus.verified;

  bool get needsOnboarding =>
      isOnboardingComplete == false ||
      (verificationStatus == VerificationStatus.notSubmitted) ||
      (verificationStatus == null && isOnboardingComplete != true);

  bool get isPendingVerification =>
      verificationStatus == VerificationStatus.pending;

  bool get isRejected => verificationStatus == VerificationStatus.rejected;
  Map<String, dynamic> toJson() => _$UserToJson(this);

  User copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? whatsapp,
    UserRole? role,
    String? profilePhoto,
    String? selfiePhoto,
    String? governmentId,
    String? governmentIdType,
    String? governmentIdNumber,
    bool? isIdVerified,
    bool? isFaceVerified,
    bool? isOnboardingComplete,
    bool? isAdminVerified,
    double? trustScore,
    double? repaymentScore,
    double? averageRating,
    int? totalRatings,
    VerificationStatus? verificationStatus,
    String? verificationRejectionReason,
    List<String>? rejectedDocuments,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    bool? isActive,
    bool? isBlocked,
    String? blockReason,
    double? lendingLimit,
    double? availableBalance,
    double? totalLent,
    double? totalBorrowed,
    bool? termsAccepted,
    DateTime? termsAcceptedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? dateOfBirth,
    String? gender,
    String? address,
    String? city,
    String? state,
    String? pincode,
    String? aadhaarNumber,
    String? panNumber,
  }) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      whatsapp: whatsapp ?? this.whatsapp,
      role: role ?? this.role,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      selfiePhoto: selfiePhoto ?? this.selfiePhoto,
      governmentId: governmentId ?? this.governmentId,
      governmentIdType: governmentIdType ?? this.governmentIdType,
      governmentIdNumber: governmentIdNumber ?? this.governmentIdNumber,
      isIdVerified: isIdVerified ?? this.isIdVerified,
      isFaceVerified: isFaceVerified ?? this.isFaceVerified,
      isOnboardingComplete: isOnboardingComplete ?? this.isOnboardingComplete,
      isAdminVerified: isAdminVerified ?? this.isAdminVerified,
      trustScore: trustScore ?? this.trustScore,
      repaymentScore: repaymentScore ?? this.repaymentScore,
      averageRating: averageRating ?? this.averageRating,
      totalRatings: totalRatings ?? this.totalRatings,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      verificationRejectionReason:
          verificationRejectionReason ?? this.verificationRejectionReason,
      rejectedDocuments: rejectedDocuments ?? this.rejectedDocuments,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      isActive: isActive ?? this.isActive,
      isBlocked: isBlocked ?? this.isBlocked,
      blockReason: blockReason ?? this.blockReason,
      lendingLimit: lendingLimit ?? this.lendingLimit,
      availableBalance: availableBalance ?? this.availableBalance,
      totalLent: totalLent ?? this.totalLent,
      totalBorrowed: totalBorrowed ?? this.totalBorrowed,
      termsAccepted: termsAccepted ?? this.termsAccepted,
      termsAcceptedAt: termsAcceptedAt ?? this.termsAcceptedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      aadhaarNumber: aadhaarNumber ?? this.aadhaarNumber,
      panNumber: panNumber ?? this.panNumber,
    );
  }
}
