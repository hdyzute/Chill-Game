import 'package:flutter/material.dart';

import '../../data/database.dart';
import 'task_style.dart';

class TaskTile extends StatelessWidget {
  const TaskTile({super.key, required this.task, required this.onTap});

  final Task task;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final element = task.element;
    final color = element?.color ?? rewardColor;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          foregroundColor: color,
          child: Icon(element?.icon ?? Icons.card_giftcard),
        ),
        title: Text(task.title),
        subtitle: Text(_subtitle()),
      ),
    );
  }

  String _subtitle() {
    final parts = <String>[
      if (task.element != null) task.element!.label,
      switch (task.type) {
        TaskType.habit => [
            if (task.habitUp) '+ Tốt',
            if (task.habitDown) '− Xấu',
          ].join(' / '),
        TaskType.daily => describeRepeatDays(task.repeatDays),
        TaskType.todo => 'Một lần',
        TaskType.reward => '${task.cost} xu',
      },
      if (task.type != TaskType.reward) task.difficulty.label,
    ];
    return parts.join(' · ');
  }
}
