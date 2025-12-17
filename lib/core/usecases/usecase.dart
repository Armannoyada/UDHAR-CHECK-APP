import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../error/failures.dart';

/// Base class for all use cases
/// [Type] is the return type
/// [Params] is the parameter type for the use case
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Use case with no parameters
class NoParams extends Equatable {
  @override
  List<Object> get props => [];
}
