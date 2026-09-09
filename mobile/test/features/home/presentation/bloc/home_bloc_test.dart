import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_app/core/error/failures.dart';
import 'package:mobile_app/features/home/domain/entities/todo.dart';
import 'package:mobile_app/features/home/domain/usecases/create_todo_usecase.dart';
import 'package:mobile_app/features/home/domain/usecases/delete_todo_usecase.dart';
import 'package:mobile_app/features/home/domain/usecases/get_todos_usecase.dart';
import 'package:mobile_app/features/home/domain/usecases/update_todo_usecase.dart';
import 'package:mobile_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:mobile_app/features/home/presentation/bloc/home_event.dart';
import 'package:mobile_app/features/home/presentation/bloc/home_state.dart';

class MockGetTodosUseCase extends Mock implements GetTodosUseCase {}

class MockCreateTodoUseCase extends Mock implements CreateTodoUseCase {}

class MockUpdateTodoUseCase extends Mock implements UpdateTodoUseCase {}

class MockDeleteTodoUseCase extends Mock implements DeleteTodoUseCase {}

void main() {
  late HomeBloc bloc;
  late MockGetTodosUseCase mockGetTodosUseCase;
  late MockCreateTodoUseCase mockCreateTodoUseCase;
  late MockUpdateTodoUseCase mockUpdateTodoUseCase;
  late MockDeleteTodoUseCase mockDeleteTodoUseCase;

  setUpAll(() {
    registerFallbackValue(const GetTodosParams());
    registerFallbackValue(const CreateTodoParams(title: ''));
    registerFallbackValue(const UpdateTodoParams(id: 1));
    registerFallbackValue(const DeleteTodoParams(id: 1));
  });

  setUp(() {
    mockGetTodosUseCase = MockGetTodosUseCase();
    mockCreateTodoUseCase = MockCreateTodoUseCase();
    mockUpdateTodoUseCase = MockUpdateTodoUseCase();
    mockDeleteTodoUseCase = MockDeleteTodoUseCase();

    bloc = HomeBloc(
      getTodosUseCase: mockGetTodosUseCase,
      createTodoUseCase: mockCreateTodoUseCase,
      updateTodoUseCase: mockUpdateTodoUseCase,
      deleteTodoUseCase: mockDeleteTodoUseCase,
    );
  });

  tearDown(() {
    bloc.close();
  });

  const tTodo = Todo(
    id: 1,
    title: 'Test Todo',
    description: 'Test Desc',
    isCompleted: false,
    ownerId: 10,
  );

  test('initial state should be HomeState.initial', () {
    expect(bloc.state, const HomeState());
  });

  group('FetchTodosEvent', () {
    blocTest<HomeBloc, HomeState>(
      'emits [HomeStatus.loading, HomeStatus.success] when fetching todos succeeds',
      build: () {
        when(
          () => mockGetTodosUseCase(any()),
        ).thenAnswer((_) async => const Right([tTodo]));
        return bloc;
      },
      act: (bloc) => bloc.add(const FetchTodosEvent()),
      expect: () => [
        const HomeState(status: HomeStatus.loading),
        const HomeState(status: HomeStatus.success, todos: [tTodo]),
      ],
      verify: (_) {
        verify(() => mockGetTodosUseCase(any())).called(1);
      },
    );

    blocTest<HomeBloc, HomeState>(
      'emits [HomeStatus.loading, HomeStatus.failure] when fetching todos fails',
      build: () {
        when(
          () => mockGetTodosUseCase(any()),
        ).thenAnswer((_) async => const Left(ServerFailure('Fetch Failed')));
        return bloc;
      },
      act: (bloc) => bloc.add(const FetchTodosEvent()),
      expect: () => [
        const HomeState(status: HomeStatus.loading),
        const HomeState(
          status: HomeStatus.failure,
          errorMessage: 'Fetch Failed',
        ),
      ],
    );
  });

  group('CreateTodoEvent', () {
    blocTest<HomeBloc, HomeState>(
      'emits [isActionLoading: true, isActionLoading: false with new todo] on success',
      build: () {
        when(
          () => mockCreateTodoUseCase(any()),
        ).thenAnswer((_) async => const Right(tTodo));
        return bloc;
      },
      act: (bloc) => bloc.add(
        const CreateTodoEvent(title: 'Test Todo', description: 'Test Desc'),
      ),
      expect: () => [
        const HomeState(isActionLoading: true),
        const HomeState(
          isActionLoading: false,
          todos: [tTodo],
          actionMessage: 'Đã thêm công việc mới thành công!',
        ),
      ],
    );
  });
}
