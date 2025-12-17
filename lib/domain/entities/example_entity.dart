// Example entity
// Entities are pure Dart classes with business logic
// They don't depend on any external packages

import 'package:equatable/equatable.dart';

class ExampleEntity extends Equatable {
  final String id;
  final String name;
  final String? description;
  final DateTime createdAt;

  const ExampleEntity({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, description, createdAt];
}

// User Entity Example
class User extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? profileImage;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.profileImage,
  });

  @override
  List<Object?> get props => [id, name, email, phone, profileImage];
}
