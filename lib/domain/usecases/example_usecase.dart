// Example use case
// Each use case should have a single responsibility
// Use cases contain the business logic

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../repositories/example_repository.dart';

class ExampleUseCase implements UseCase<String, ExampleParams> {
  final ExampleRepository repository;

  ExampleUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(ExampleParams params) async {
    return await repository.exampleMethod();
  }
}

class ExampleParams extends Equatable {
  final String id;

  const ExampleParams({required this.id});

  @override
  List<Object> get props => [id];
}

// Example: Login Use Case
// class LoginUseCase implements UseCase<User, LoginParams> {
//   final AuthRepository repository;
//
//   LoginUseCase(this.repository);
//
//   @override
//   Future<Either<Failure, User>> call(LoginParams params) async {
//     return await repository.login(params.email, params.password);
//   }
// }
//
// class LoginParams extends Equatable {
//   final String email;
//   final String password;
//
//   const LoginParams({required this.email, required this.password});
//
//   @override
//   List<Object> get props => [email, password];
// }
