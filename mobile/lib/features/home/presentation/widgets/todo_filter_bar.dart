import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';

class TodoFilterBar extends StatefulWidget {
  const TodoFilterBar({super.key});

  @override
  State<TodoFilterBar> createState() => _TodoFilterBarState();
}

class _TodoFilterBarState extends State<TodoFilterBar> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Tìm kiếm công việc...',
            prefixIcon: const Icon(Icons.search_rounded, size: 20),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      context.read<HomeBloc>().add(const SearchTodosEvent(query: ''));
                    },
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: (value) {
            context.read<HomeBloc>().add(SearchTodosEvent(query: value));
            setState(() {});
          },
        ),
        const SizedBox(height: 10),
        BlocBuilder<HomeBloc, HomeState>(
          buildWhen: (previous, current) => previous.filter != current.filter,
          builder: (context, state) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(
                    context,
                    label: 'Tất cả',
                    filter: TodoFilter.all,
                    currentFilter: state.filter,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    context,
                    label: 'Đang làm',
                    filter: TodoFilter.pending,
                    currentFilter: state.filter,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    context,
                    label: 'Đã hoàn thành',
                    filter: TodoFilter.completed,
                    currentFilter: state.filter,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required TodoFilter filter,
    required TodoFilter currentFilter,
  }) {
    final isSelected = currentFilter == filter;
    final colorScheme = Theme.of(context).colorScheme;

    return FilterChip(
      selected: isSelected,
      label: Text(label),
      labelStyle: TextStyle(
        fontSize: 13,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        color: isSelected ? colorScheme.onPrimary : Colors.grey.shade800,
      ),
      selectedColor: colorScheme.primary,
      backgroundColor: Colors.grey.shade100,
      checkmarkColor: colorScheme.onPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? colorScheme.primary : Colors.grey.shade300,
        ),
      ),
      onSelected: (_) {
        context.read<HomeBloc>().add(ChangeFilterEvent(filter: filter));
      },
    );
  }
}
