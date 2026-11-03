import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/providers.dart';
import 'task_form_screen.dart';
import 'task_style.dart';
import 'task_tile.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(tasksProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Hôm nay')),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Thêm task',
        onPressed: () => _openForm(context),
        child: const Icon(Icons.add),
      ),
      body: tasks.when(
        data: (list) => list.isEmpty
            ? const _EmptyView()
            : _TaskList(tasks: list, onTap: (t) => _openForm(context, t)),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Lỗi tải dữ liệu: $e')),
      ),
    );
  }

  void _openForm(BuildContext context, [Task? task]) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TaskFormScreen(task: task)),
    );
  }
}

class _TaskList extends StatelessWidget {
  const _TaskList({required this.tasks, required this.onTap});

  final List<Task> tasks;
  final void Function(Task) onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.only(bottom: 96),
      children: [
        for (final type in TaskType.values)
          if (tasks.any((t) => t.type == type)) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Row(
                children: [
                  Icon(type.icon, size: 18, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(type.label, style: theme.textTheme.titleSmall),
                ],
              ),
            ),
            for (final task in tasks.where((t) => t.type == type))
              TaskTile(task: task, onTap: () => onTap(task)),
          ],
      ],
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.egg_outlined, size: 72, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              'Chưa có thói quen nào.\nBấm + để tạo thói quen đầu tiên.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
