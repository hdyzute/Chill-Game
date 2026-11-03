import 'package:flutter/material.dart';

import '../../data/database.dart';
import 'task_style.dart';

/// Daily và việc cần làm: xong khi đã tick. Thói quen tốt: khi đủ số lần
/// hôm nay. Thói quen chỉ có "xấu" thì không bao giờ "xong".
bool isTaskDone(Task task, int todayCount) => switch (task.type) {
      TaskType.habit => task.habitUp && todayCount >= task.dailyTarget,
      TaskType.daily || TaskType.todo => task.completed,
      TaskType.reward => false,
    };

class TaskTile extends StatelessWidget {
  const TaskTile({
    super.key,
    required this.task,
    required this.todayCount,
    this.restDay = false,
    required this.onTap,
    required this.onCheck,
    required this.onBad,
    required this.onBuy,
  });

  final Task task;

  /// Số lần thói quen tốt đã làm hôm nay.
  final int todayCount;

  /// Daily không phải làm hôm nay theo lịch lặp: hiện mờ, vẫn tick được.
  final bool restDay;

  /// Mở form sửa.
  final VoidCallback onTap;

  /// Bấm vòng tròn: hoàn thành, hoặc bỏ tick nếu đã xong.
  final VoidCallback onCheck;

  /// Ghi nhận thói quen xấu.
  final VoidCallback onBad;

  /// Đổi xu lấy phần thưởng.
  final VoidCallback onBuy;

  bool get _hasCheck =>
      task.type == TaskType.daily ||
      task.type == TaskType.todo ||
      (task.type == TaskType.habit && task.habitUp);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final element = task.element;
    final color = element?.color ?? rewardColor;
    final done = isTaskDone(task, todayCount);

    final card = Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        onTap: onTap,
        leading: _hasCheck
            ? IconButton(
                tooltip: done ? 'Bỏ tick' : 'Hoàn thành',
                onPressed: onCheck,
                icon: _CheckMark(
                  done: done,
                  count: task.type == TaskType.habit ? todayCount : 0,
                  target: task.type == TaskType.habit ? task.dailyTarget : 1,
                  color: color,
                ),
              )
            : CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.15),
                foregroundColor: color,
                child: Icon(element?.icon ?? Icons.card_giftcard),
              ),
        title: Text(
          task.title,
          style: done
              ? TextStyle(
                  decoration: TextDecoration.lineThrough,
                  color: theme.colorScheme.onSurfaceVariant,
                )
              : null,
        ),
        subtitle: Text(_subtitle()),
        trailing: switch (task.type) {
          TaskType.habit when task.habitDown => IconButton(
              tooltip: 'Lỡ làm việc xấu',
              color: theme.colorScheme.error.withValues(alpha: 0.7),
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: onBad,
            ),
          TaskType.reward => FilledButton.tonalIcon(
              onPressed: onBuy,
              icon: const Icon(Icons.monetization_on, color: rewardColor),
              label: Text('${task.cost}'),
            ),
          _ => null,
        },
      ),
    );
    return restDay && !done ? Opacity(opacity: 0.55, child: card) : card;
  }

  String _subtitle() {
    final parts = <String>[
      if (restDay) 'Hôm nay nghỉ',
      if (task.element != null) task.element!.label,
      switch (task.type) {
        TaskType.habit when task.habitUp =>
          '$todayCount/${task.dailyTarget} lần hôm nay',
        TaskType.habit => 'Thói quen xấu',
        TaskType.daily => describeRepeatDays(task.repeatDays),
        TaskType.todo => 'Một lần',
        TaskType.reward => 'Phần thưởng',
      },
      if (task.type != TaskType.reward) task.difficulty.label,
      if (task.type == TaskType.daily && task.streak > 0)
        'Chuỗi ${task.streak} ngày',
    ];
    return parts.join(' · ');
  }
}

/// Vòng tròn tick. Với mục tiêu nhiều lần thì là vòng tiến độ có số đếm.
class _CheckMark extends StatelessWidget {
  const _CheckMark({
    required this.done,
    required this.count,
    required this.target,
    required this.color,
  });

  final bool done;
  final int count;
  final int target;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (done) return Icon(Icons.check_circle, size: 30, color: color);
    if (target <= 1) {
      return Icon(Icons.radio_button_unchecked, size: 30, color: color);
    }
    return SizedBox.square(
      dimension: 30,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: count / target,
            strokeWidth: 3,
            color: color,
            backgroundColor: color.withValues(alpha: 0.2),
          ),
          Text(
            '$count',
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
