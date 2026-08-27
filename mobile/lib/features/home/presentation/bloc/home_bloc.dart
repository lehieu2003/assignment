import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/create_todo_usecase.dart';
import '../../domain/usecases/delete_todo_usecase.dart';
import '../../domain/usecases/get_todos_usecase.dart';
import '../../domain/usecases/update_todo_usecase.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetTodosUseCase getTodosUseCase;
  final CreateTodoUseCase createTodoUseCase;
  final UpdateTodoUseCase updateTodoUseCase;
  final DeleteTodoUseCase deleteTodoUseCase;

  HomeBloc({
    required this.getTodosUseCase,
    required this.createTodoUseCase,
    required this.updateTodoUseCase,
    required this.deleteTodoUseCase,
  }) : super(const HomeState()) {
    on<FetchTodosEvent>(_onFetchTodos);
    on<CreateTodoEvent>(_onCreateTodo);
    on<ToggleTodoStatusEvent>(_onToggleTodoStatus);
    on<UpdateTodoEvent>(_onUpdateTodo);
    on<DeleteTodoEvent>(_onDeleteTodo);
    on<ChangeFilterEvent>(_onChangeFilter);
    on<SearchTodosEvent>(_onSearchTodos);
  }

  Future<void> _onFetchTodos(
    FetchTodosEvent event,
    Emitter<HomeState> emit,
  ) async {
    if (!event.isRefresh) {
      emit(state.copyWith(status: HomeStatus.loading, clearErrorMessage: true));
    }

    final result = await getTodosUseCase(const GetTodosParams());
    result.fold(
      (failure) => emit(state.copyWith(
        status: HomeStatus.failure,
        errorMessage: failure.message,
      )),
      (todos) => emit(state.copyWith(
        status: HomeStatus.success,
        todos: todos,
        clearErrorMessage: true,
      )),
    );
  }

  Future<void> _onCreateTodo(
    CreateTodoEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(isActionLoading: true, clearActionMessage: true));

    final result = await createTodoUseCase(
      CreateTodoParams(
        title: event.title,
        description: event.description,
      ),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        isActionLoading: false,
        errorMessage: failure.message,
      )),
      (newTodo) {
        final updatedTodos = [newTodo, ...state.todos];
        emit(state.copyWith(
          isActionLoading: false,
          todos: updatedTodos,
          actionMessage: 'Đã thêm công việc mới thành công!',
        ));
      },
    );
  }

  Future<void> _onToggleTodoStatus(
    ToggleTodoStatusEvent event,
    Emitter<HomeState> emit,
  ) async {
    final updatedStatus = !event.todo.isCompleted;
    
    // Optimistic update
    final updatedList = state.todos.map((t) {
      if (t.id == event.todo.id) {
        return t.copyWith(isCompleted: updatedStatus);
      }
      return t;
    }).toList();

    emit(state.copyWith(todos: updatedList, clearActionMessage: true));

    final result = await updateTodoUseCase(
      UpdateTodoParams(
        id: event.todo.id,
        isCompleted: updatedStatus,
      ),
    );

    result.fold(
      (failure) {
        // Rollback on failure
        emit(state.copyWith(
          todos: state.todos,
          errorMessage: 'Không thể cập nhật trạng thái: ${failure.message}',
        ));
      },
      (savedTodo) {
        final syncList = state.todos.map((t) => t.id == savedTodo.id ? savedTodo : t).toList();
        emit(state.copyWith(
          todos: syncList,
          actionMessage: updatedStatus ? 'Đã hoàn thành công việc!' : 'Đã chuyển thành chưa hoàn thành',
        ));
      },
    );
  }

  Future<void> _onUpdateTodo(
    UpdateTodoEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(isActionLoading: true, clearActionMessage: true));

    final result = await updateTodoUseCase(
      UpdateTodoParams(
        id: event.id,
        title: event.title,
        description: event.description,
        isCompleted: event.isCompleted,
      ),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        isActionLoading: false,
        errorMessage: failure.message,
      )),
      (updatedTodo) {
        final updatedTodos = state.todos.map((t) => t.id == updatedTodo.id ? updatedTodo : t).toList();
        emit(state.copyWith(
          isActionLoading: false,
          todos: updatedTodos,
          actionMessage: 'Đã cập nhật công việc!',
        ));
      },
    );
  }

  Future<void> _onDeleteTodo(
    DeleteTodoEvent event,
    Emitter<HomeState> emit,
  ) async {
    final result = await deleteTodoUseCase(DeleteTodoParams(id: event.id));

    result.fold(
      (failure) => emit(state.copyWith(
        errorMessage: 'Không thể xóa: ${failure.message}',
      )),
      (_) {
        final updatedTodos = state.todos.where((t) => t.id != event.id).toList();
        emit(state.copyWith(
          todos: updatedTodos,
          actionMessage: 'Đã xóa công việc!',
        ));
      },
    );
  }

  void _onChangeFilter(
    ChangeFilterEvent event,
    Emitter<HomeState> emit,
  ) {
    emit(state.copyWith(filter: event.filter));
  }

  void _onSearchTodos(
    SearchTodosEvent event,
    Emitter<HomeState> emit,
  ) {
    emit(state.copyWith(searchQuery: event.query));
  }
}
