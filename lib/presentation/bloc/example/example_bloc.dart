// Example BLoC structure
// This shows how to implement state management using BLoC pattern

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class ExampleEvent extends Equatable {
  const ExampleEvent();

  @override
  List<Object> get props => [];
}

class LoadDataEvent extends ExampleEvent {}

class RefreshDataEvent extends ExampleEvent {}

// States
abstract class ExampleState extends Equatable {
  const ExampleState();

  @override
  List<Object> get props => [];
}

class ExampleInitial extends ExampleState {}

class ExampleLoading extends ExampleState {}

class ExampleLoaded extends ExampleState {
  final String data;

  const ExampleLoaded(this.data);

  @override
  List<Object> get props => [data];
}

class ExampleError extends ExampleState {
  final String message;

  const ExampleError(this.message);

  @override
  List<Object> get props => [message];
}

// BLoC
class ExampleBloc extends Bloc<ExampleEvent, ExampleState> {
  // Add your use cases here
  // final ExampleUseCase exampleUseCase;

  ExampleBloc() : super(ExampleInitial()) {
    on<LoadDataEvent>(_onLoadData);
    on<RefreshDataEvent>(_onRefreshData);
  }

  Future<void> _onLoadData(
    LoadDataEvent event,
    Emitter<ExampleState> emit,
  ) async {
    emit(ExampleLoading());
    
    try {
      // Call use case
      // final result = await exampleUseCase(ExampleParams(id: '123'));
      
      // Handle result
      // result.fold(
      //   (failure) => emit(ExampleError(failure.message)),
      //   (data) => emit(ExampleLoaded(data)),
      // );
      
      // Temporary success state
      await Future.delayed(const Duration(seconds: 1));
      emit(const ExampleLoaded('Data loaded successfully'));
    } catch (e) {
      emit(ExampleError(e.toString()));
    }
  }

  Future<void> _onRefreshData(
    RefreshDataEvent event,
    Emitter<ExampleState> emit,
  ) async {
    // Similar to load but with refresh logic
    await _onLoadData(LoadDataEvent(), emit);
  }
}
