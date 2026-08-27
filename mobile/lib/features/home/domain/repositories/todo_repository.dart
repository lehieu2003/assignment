import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/todo.dart';

abstract class TodoRepository {
  Future<Either<Failure, List<Todo>>> getTodos({
    bool? isCompleted,
    String? search,
    int skip = 0,
    int limit = 100,
  });

  Future<Either<Failure, Todo>> createTodo({
    required String title,
    String? description,
    bool isCompleted = false,
  });

  Future<Either<Failure, Todo>> updateTodo({
    required int id,
    String? title,
    String? description,
    bool? isCompleted,
  });

  Future<Either<Failure, void>> deleteTodo(int id);
}
