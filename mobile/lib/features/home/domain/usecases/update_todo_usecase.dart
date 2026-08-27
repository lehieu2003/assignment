import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/usecase.dart';
import '../entities/todo.dart';
import '../repositories/todo_repository.dart';

class UpdateTodoParams extends Equatable {
  final int id;
  final String? title;
  final String? description;
  final bool? isCompleted;

  const UpdateTodoParams({
    required this.id,
    this.title,
    this.description,
    this.isCompleted,
  });

  @override
  List<Object?> get props => [id, title, description, isCompleted];
}

class UpdateTodoUseCase implements UseCase<Todo, UpdateTodoParams> {
  final TodoRepository repository;

  UpdateTodoUseCase(this.repository);

  @override
  Future<Either<Failure, Todo>> call(UpdateTodoParams params) {
    return repository.updateTodo(
      id: params.id,
      title: params.title,
      description: params.description,
      isCompleted: params.isCompleted,
    );
  }
}
