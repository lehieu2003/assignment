import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/usecase.dart';
import '../entities/todo.dart';
import '../repositories/todo_repository.dart';

class GetTodosParams extends Equatable {
  final bool? isCompleted;
  final String? search;
  final int skip;
  final int limit;

  const GetTodosParams({
    this.isCompleted,
    this.search,
    this.skip = 0,
    this.limit = 100,
  });

  @override
  List<Object?> get props => [isCompleted, search, skip, limit];
}

class GetTodosUseCase implements UseCase<List<Todo>, GetTodosParams> {
  final TodoRepository repository;

  GetTodosUseCase(this.repository);

  @override
  Future<Either<Failure, List<Todo>>> call(GetTodosParams params) {
    return repository.getTodos(
      isCompleted: params.isCompleted,
      search: params.search,
      skip: params.skip,
      limit: params.limit,
    );
  }
}
