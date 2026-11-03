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
    final counts = ref.watch(todayCountsProvider).value ?? const {};

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hôm nay'),
        actions: const [_CoinBadge(), SizedBox(width: 12)],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Thêm task',
        onPressed: () => _openForm(context),
        child: const Icon(Icons.add),
      ),
      body: tasks.when(
        data: (list) => list.isEmpty
            ? const _EmptyView()
            : _TaskList(
                tasks: list,
                tileBuilder: (task) {
                  final count = counts[task.id] ?? 0;
                  return TaskTile(
                    task: task,
                    todayCount: count,
                    onTap: () => _openForm(context, task),
                    onCheck: () => _check(context, ref, task, count),
                    onBad: () => _bad(context, ref, task),
                    onBuy: () => _buy(context, ref, task),
                  );
                },
              ),
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

  /// Bấm vòng tròn: chưa xong thì hoàn thành một lần, xong rồi thì bỏ tick.
  Future<void> _check(
      BuildContext context, WidgetRef ref, Task task, int todayCount) async {
    final service = ref.read(scoreServiceProvider);
    if (isTaskDone(task, todayCount)) {
      await service.uncheck(task.id);
      return;
    }
    final log = await _guard(() => service.score(task.id));
    if (log == null || !context.mounted) return;
    final extra = switch (task.type) {
      TaskType.daily => ' · chuỗi ${task.streak + log.streakDelta} ngày',
      TaskType.habit => ' · ${todayCount + 1}/${task.dailyTarget} hôm nay',
      _ => '',
    };
    _showUndoable(context, ref, log, '${_coinsText(log)}$extra');
  }

  Future<void> _bad(BuildContext context, WidgetRef ref, Task task) async {
    final log = await _guard(
        () => ref.read(scoreServiceProvider).score(task.id, up: false));
    if (log == null || !context.mounted) return;
    _showUndoable(
        context, ref, log, 'Đã ghi nhận "${task.title}". Lần sau cố lên nhé!');
  }

  Future<void> _buy(BuildContext context, WidgetRef ref, Task task) async {
    final log = await ref.read(scoreServiceProvider).buyReward(task.id);
    if (!context.mounted) return;
    if (log == null) {
      final coins = ref.read(coinsProvider).value ?? 0;
      _messenger(context).showSnackBar(SnackBar(
        content: Text('Chưa đủ xu: cần ${task.cost}, bạn đang có $coins'),
      ));
      return;
    }
    _showUndoable(
        context, ref, log, 'Đã đổi "${task.title}" (−${task.cost} xu)');
  }

  /// Bấm hai lần quá nhanh có thể chấm một task đã xong: bỏ qua lần thứ hai.
  Future<TaskLog?> _guard(Future<TaskLog> Function() action) async {
    try {
      return await action();
    } on StateError {
      return null;
    }
  }

  String _coinsText(TaskLog log) => log.critical
      ? 'Linh khí bạo phát! +${log.coinsDelta} xu'
      : '+${log.coinsDelta} xu';

  ScaffoldMessengerState _messenger(BuildContext context) =>
      ScaffoldMessenger.of(context)..hideCurrentSnackBar();

  void _showUndoable(
      BuildContext context, WidgetRef ref, TaskLog log, String text) {
    final service = ref.read(scoreServiceProvider);
    _messenger(context).showSnackBar(SnackBar(
      content: Text(text),
      duration: const Duration(seconds: 3),
      // Snackbar có nút mặc định không tự ẩn.
      persist: false,
      action: SnackBarAction(
        label: 'Hoàn tác',
        onPressed: () => service.undo(log.id),
      ),
    ));
  }
}

class _CoinBadge extends ConsumerWidget {
  const _CoinBadge();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coins = ref.watch(coinsProvider).value ?? 0;
    return Chip(
      avatar: const Icon(Icons.monetization_on, color: rewardColor),
      label: Text('$coins', key: const Key('coins')),
    );
  }
}

class _TaskList extends StatelessWidget {
  const _TaskList({required this.tasks, required this.tileBuilder});

  final List<Task> tasks;
  final Widget Function(Task) tileBuilder;

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
              tileBuilder(task),
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
