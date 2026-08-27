import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_state.dart';

class UserProfileHeader extends StatelessWidget {
  final User user;

  const UserProfileHeader({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Card(
          elevation: 0,
          color: colorScheme.primaryContainer.withAlpha(90),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: colorScheme.primary,
                  child: Text(
                    (user.fullName != null && user.fullName!.isNotEmpty)
                        ? user.fullName![0].toUpperCase()
                        : user.email[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullName?.isNotEmpty == true ? user.fullName! : 'Người dùng',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user.email,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  icon: const Icon(Icons.logout_rounded, size: 20),
                  tooltip: 'Đăng xuất',
                  onPressed: () {
                    _showLogoutConfirmDialog(context);
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            return Row(
              children: [
                _buildStatCard(
                  context,
                  title: 'Tổng số',
                  count: state.totalCount,
                  color: Colors.blue.shade600,
                  icon: Icons.list_alt_rounded,
                ),
                const SizedBox(width: 10),
                _buildStatCard(
                  context,
                  title: 'Đang làm',
                  count: state.pendingCount,
                  color: Colors.orange.shade700,
                  icon: Icons.pending_actions_rounded,
                ),
                const SizedBox(width: 10),
                _buildStatCard(
                  context,
                  title: 'Hoàn thành',
                  count: state.completedCount,
                  color: Colors.green.shade600,
                  icon: Icons.task_alt_rounded,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required int count,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withAlpha(50)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 4),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Xác nhận đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất khỏi ứng dụng không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              context.read<AuthBloc>().add(LogoutEvent());
            },
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }
}
