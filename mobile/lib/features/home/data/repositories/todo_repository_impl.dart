import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/todo.dart';
import '../../domain/repositories/todo_repository.dart';
import '../datasources/todo_remote_data_source.dart';

class TodoRepositoryImpl implements TodoRepository {
  final TodoRemoteDataSource remoteDataSource;

  TodoRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Todo>>> getTodos({
    bool? isCompleted,
    String? search,
    int skip = 0,
    int limit = 100,
  }) async {
    try {
      final todos = await remoteDataSource.getTodos(
        isCompleted: isCompleted,
        search: search,
        skip: skip,
        limit: limit,
      );
      return Right(todos);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Todo>> createTodo({
    required String title,
    String? description,
    bool isCompleted = false,
  }) async {
    try {
      final todo = await remoteDataSource.createTodo(
        title: title,
        description: description,
        isCompleted: isCompleted,
      );
      return Right(todo);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Todo>> updateTodo({
    required int id,
    String? title,
    String? description,
    bool? isCompleted,
  }) async {
    try {
      final todo = await remoteDataSource.updateTodo(
        id: id,
        title: title,
        description: description,
        isCompleted: isCompleted,
      );
      return Right(todo);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTodo(int id) async {
    try {
      await remoteDataSource.deleteTodo(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
