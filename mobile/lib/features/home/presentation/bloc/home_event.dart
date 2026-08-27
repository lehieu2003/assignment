import 'package:equatable/equatable.dart';
import '../../domain/entities/todo.dart';
import 'home_state.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class FetchTodosEvent extends HomeEvent {
  final bool isRefresh;

  const FetchTodosEvent({this.isRefresh = false});

  @override
  List<Object?> get props => [isRefresh];
}

class CreateTodoEvent extends HomeEvent {
  final String title;
  final String? description;

  const CreateTodoEvent({required this.title, this.description});

  @override
  List<Object?> get props => [title, description];
}

class ToggleTodoStatusEvent extends HomeEvent {
  final Todo todo;

  const ToggleTodoStatusEvent({required this.todo});

  @override
  List<Object?> get props => [todo];
}

class UpdateTodoEvent extends HomeEvent {
  final int id;
  final String title;
  final String? description;
  final bool isCompleted;

  const UpdateTodoEvent({
    required this.id,
    required this.title,
    this.description,
    required this.isCompleted,
  });

  @override
  List<Object?> get props => [id, title, description, isCompleted];
}

class DeleteTodoEvent extends HomeEvent {
  final int id;

  const DeleteTodoEvent({required this.id});

  @override
  List<Object?> get props => [id];
}

class ChangeFilterEvent extends HomeEvent {
  final TodoFilter filter;

  const ChangeFilterEvent({required this.filter});

  @override
  List<Object?> get props => [filter];
}

class SearchTodosEvent extends HomeEvent {
  final String query;

  const SearchTodosEvent({required this.query});

  @override
  List<Object?> get props => [query];
}
