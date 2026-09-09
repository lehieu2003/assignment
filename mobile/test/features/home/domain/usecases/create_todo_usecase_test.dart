import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_app/core/error/failures.dart';
import 'package:mobile_app/features/home/domain/entities/todo.dart';
import 'package:mobile_app/features/home/domain/repositories/todo_repository.dart';
import 'package:mobile_app/features/home/domain/usecases/create_todo_usecase.dart';

class MockTodoRepository extends Mock implements TodoRepository {}

void main() {
  late CreateTodoUseCase usecase;
  late MockTodoRepository mockRepository;

  setUp(() {
    mockRepository = MockTodoRepository();
    usecase = CreateTodoUseCase(mockRepository);
  });

  const tTodo = Todo(
    id: 1,
    title: 'Test Todo',
    description: 'Test Description',
    isCompleted: false,
    ownerId: 10,
  );

  const tParams = CreateTodoParams(
    title: 'Test Todo',
    description: 'Test Description',
    isCompleted: false,
  );

  test('should return created Todo from repository when call is successful', () async {
    // Arrange
    when(() => mockRepository.createTodo(
          title: any(named: 'title'),
          description: any(named: 'description'),
          isCompleted: any(named: 'isCompleted'),
        )).thenAnswer((_) async => const Right(tTodo));

    // Act
    final result = await usecase(tParams);

    // Assert
    expect(result, const Right(tTodo));
    verify(() => mockRepository.createTodo(
          title: 'Test Todo',
          description: 'Test Description',
          isCompleted: false,
        )).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return ServerFailure when repository fails', () async {
    // Arrange
    const tFailure = ServerFailure('Server Error');
    when(() => mockRepository.createTodo(
          title: any(named: 'title'),
          description: any(named: 'description'),
          isCompleted: any(named: 'isCompleted'),
        )).thenAnswer((_) async => const Left(tFailure));

    // Act
    final result = await usecase(tParams);

    // Assert
    expect(result, const Left(tFailure));
    verify(() => mockRepository.createTodo(
          title: 'Test Todo',
          description: 'Test Description',
          isCompleted: false,
        )).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
