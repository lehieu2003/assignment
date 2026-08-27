import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/usecase.dart';
import '../entities/todo.dart';
import '../repositories/todo_repository.dart';

class CreateTodoParams extends Equatable {
  final String title;
  final String? description;
  final bool isCompleted;

  const CreateTodoParams({
    required this.title,
    this.description,
    this.isCompleted = false,
  });

  @override
  List<Object?> get props => [title, description, isCompleted];
}

class CreateTodoUseCase implements UseCase<Todo, CreateTodoParams> {
  final TodoRepository repository;

  CreateTodoUseCase(this.repository);

  @override
  Future<Either<Failure, Todo>> call(CreateTodoParams params) {
    return repository.createTodo(
      title: params.title,
      description: params.description,
      isCompleted: params.isCompleted,
    );
  }
}
