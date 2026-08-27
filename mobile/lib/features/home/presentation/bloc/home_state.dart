import 'package:equatable/equatable.dart';
import '../../domain/entities/todo.dart';

enum HomeStatus { initial, loading, success, failure }

enum TodoFilter { all, pending, completed }

class HomeState extends Equatable {
  final HomeStatus status;
  final List<Todo> todos;
  final TodoFilter filter;
  final String searchQuery;
  final String? errorMessage;
  final String? actionMessage;
  final bool isActionLoading;

  const HomeState({
    this.status = HomeStatus.initial,
    this.todos = const [],
    this.filter = TodoFilter.all,
    this.searchQuery = '',
    this.errorMessage,
    this.actionMessage,
    this.isActionLoading = false,
  });

  List<Todo> get filteredTodos {
    return todos.where((todo) {
      // Filter by status
      if (filter == TodoFilter.pending && todo.isCompleted) return false;
      if (filter == TodoFilter.completed && !todo.isCompleted) return false;

      // Filter by search query
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        final matchTitle = todo.title.toLowerCase().contains(query);
        final matchDesc = todo.description?.toLowerCase().contains(query) ?? false;
        if (!matchTitle && !matchDesc) return false;
      }

      return true;
    }).toList();
  }

  int get totalCount => todos.length;
  int get completedCount => todos.where((t) => t.isCompleted).length;
  int get pendingCount => todos.where((t) => !t.isCompleted).length;

  HomeState copyWith({
    HomeStatus? status,
    List<Todo>? todos,
    TodoFilter? filter,
    String? searchQuery,
    String? errorMessage,
    String? actionMessage,
    bool? isActionLoading,
    bool clearActionMessage = false,
    bool clearErrorMessage = false,
  }) {
    return HomeState(
      status: status ?? this.status,
      todos: todos ?? this.todos,
      filter: filter ?? this.filter,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      actionMessage: clearActionMessage ? null : (actionMessage ?? this.actionMessage),
      isActionLoading: isActionLoading ?? this.isActionLoading,
    );
  }

  @override
  List<Object?> get props => [
        status,
        todos,
        filter,
        searchQuery,
        errorMessage,
        actionMessage,
        isActionLoading,
      ];
}
