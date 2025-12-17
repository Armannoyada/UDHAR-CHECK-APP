// Example model structure
// This is a template - replace with your actual models

import 'package:json_annotation/json_annotation.dart';

// Run: flutter pub run build_runner build
// This will generate: example_model.g.dart

part 'example_model.g.dart';

@JsonSerializable()
class ExampleModel {
  final String id;
  final String name;
  final String? description;
  
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  ExampleModel({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
  });

  factory ExampleModel.fromJson(Map<String, dynamic> json) =>
      _$ExampleModelFromJson(json);

  Map<String, dynamic> toJson() => _$ExampleModelToJson(this);
}

// Response wrapper model
@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$ApiResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) =>
      _$ApiResponseToJson(this, toJsonT);
}
