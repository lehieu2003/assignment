import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_app/core/error/failures.dart';
import 'package:mobile_app/features/home/domain/entities/todo.dart';
import 'package:mobile_app/features/home/domain/repositories/todo_repository.dart';
import 'package:mobile_app/features/home/domain/usecases/get_todos_usecase.dart';

class MockTodoRepository extends Mock implements TodoRepository {}

void main() {
  late GetTodosUseCase usecase;
  late MockTodoRepository mockRepository;

  setUp(() {
    mockRepository = MockTodoRepository();
    usecase = GetTodosUseCase(mockRepository);
  });

  const tTodos = [
    Todo(id: 1, title: 'Todo 1', isCompleted: false, ownerId: 10),
    Todo(id: 2, title: 'Todo 2', isCompleted: true, ownerId: 10),
  ];

  test('should return list of Todos from repository', () async {
    // Arrange
    when(() => mockRepository.getTodos(
          isCompleted: any(named: 'isCompleted'),
          search: any(named: 'search'),
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        )).thenAnswer((_) async => const Right(tTodos));

    // Act
    final result = await usecase(const GetTodosParams());

    // Assert
    expect(result, const Right(tTodos));
    verify(() => mockRepository.getTodos(
          isCompleted: null,
          search: null,
          skip: 0,
          limit: 100,
        )).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return ServerFailure when repository fails', () async {
    // Arrange
    const tFailure = ServerFailure('Network Failure');
    when(() => mockRepository.getTodos(
          isCompleted: any(named: 'isCompleted'),
          search: any(named: 'search'),
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        )).thenAnswer((_) async => const Left(tFailure));

    // Act
    final result = await usecase(const GetTodosParams());

    // Assert
    expect(result, const Left(tFailure));
    verify(() => mockRepository.getTodos(
          isCompleted: null,
          search: null,
          skip: 0,
          limit: 100,
        )).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
