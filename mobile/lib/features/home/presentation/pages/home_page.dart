import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../auth/domain/entities/user.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../widgets/add_edit_todo_dialog.dart';
import '../widgets/todo_filter_bar.dart';
import '../widgets/todo_item_tile.dart';
import '../widgets/user_profile_header.dart';

class HomePage extends StatelessWidget {
  final User user;

  const HomePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<HomeBloc>()..add(const FetchTodosEvent()),
      child: _HomePageView(user: user),
    );
  }
}

class _HomePageView extends StatelessWidget {
  final User user;

  const _HomePageView({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách công việc'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Làm mới',
            onPressed: () {
              context.read<HomeBloc>().add(const FetchTodosEvent(isRefresh: true));
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          AddEditTodoDialog.show(
            context,
            onSave: (title, description) {
              context.read<HomeBloc>().add(
                    CreateTodoEvent(title: title, description: description),
                  );
            },
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Thêm việc'),
      ),
      body: BlocConsumer<HomeBloc, HomeState>(
        listener: (context, state) {
          if (state.actionMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.actionMessage!),
                backgroundColor: Colors.green.shade700,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
              ),
            );
          }
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red.shade700,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<HomeBloc>().add(const FetchTodosEvent(isRefresh: true));
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        UserProfileHeader(user: user),
                        const SizedBox(height: 16),
                        const TodoFilterBar(),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
                if (state.status == HomeStatus.loading && state.todos.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (state.filteredTodos.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildEmptyState(context, state),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final todo = state.filteredTodos[index];
                          return TodoItemTile(
                            key: ValueKey(todo.id),
                            todo: todo,
                            onToggle: () {
                              context.read<HomeBloc>().add(
                                    ToggleTodoStatusEvent(todo: todo),
                                  );
                            },
                            onEdit: () {
                              AddEditTodoDialog.show(
                                context,
                                todo: todo,
                                onSave: (title, description) {
                                  context.read<HomeBloc>().add(
                                        UpdateTodoEvent(
                                          id: todo.id,
                                          title: title,
                                          description: description,
                                          isCompleted: todo.isCompleted,
                                        ),
                                      );
                                },
                              );
                            },
                            onDelete: () {
                              context.read<HomeBloc>().add(
                                    DeleteTodoEvent(id: todo.id),
                                  );
                            },
                          );
                        },
                        childCount: state.filteredTodos.length,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, HomeState state) {
    String title = 'Chưa có công việc nào';
    String message = 'Bấm nút "Thêm việc" bên dưới để tạo công việc đầu tiên!';

    if (state.searchQuery.isNotEmpty) {
      title = 'Không tìm thấy kết quả';
      message = 'Không có công việc nào khớp với từ khóa "${state.searchQuery}".';
    } else if (state.filter == TodoFilter.completed) {
      title = 'Chưa có việc hoàn thành';
      message = 'Hãy bắt đầu hoàn thành các mục tiêu công việc của bạn!';
    } else if (state.filter == TodoFilter.pending) {
      title = 'Tuyệt vời!';
      message = 'Bạn đã hoàn thành tất cả công việc được giao!';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              state.filter == TodoFilter.completed
                  ? Icons.task_alt_rounded
                  : (state.searchQuery.isNotEmpty ? Icons.search_off_rounded : Icons.checklist_rtl_rounded),
              size: 72,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
