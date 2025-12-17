// Example repository interface
// This is an abstract class that defines what operations can be performed
// The actual implementation is in the data layer

import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';

abstract class ExampleRepository {
  Future<Either<Failure, String>> exampleMethod();
  
  // Add your repository methods here
  // Example:
  // Future<Either<Failure, User>> login(String email, String password);
  // Future<Either<Failure, List<Item>>> getItems();
  // Future<Either<Failure, void>> deleteItem(String id);
}
