import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/usecase.dart';
import '../repositories/todo_repository.dart';

class DeleteTodoParams extends Equatable {
  final int id;

  const DeleteTodoParams({required this.id});

  @override
  List<Object?> get props => [id];
}

class DeleteTodoUseCase implements UseCase<void, DeleteTodoParams> {
  final TodoRepository repository;

  DeleteTodoUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteTodoParams params) {
    return repository.deleteTodo(params.id);
  }
}
