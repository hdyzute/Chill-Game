import 'package:flutter/material.dart';

import '../../data/task_enums.dart';

extension TaskElementStyle on TaskElement {
  Color get color => switch (this) {
        TaskElement.fire => const Color(0xFFE5533D),
        TaskElement.water => const Color(0xFF2F7FD8),
        TaskElement.wood => const Color(0xFF3E9B4F),
      };

  IconData get icon => switch (this) {
        TaskElement.fire => Icons.local_fire_department,
        TaskElement.water => Icons.water_drop,
        TaskElement.wood => Icons.eco,
      };
}

extension TaskTypeStyle on TaskType {
  IconData get icon => switch (this) {
        TaskType.habit => Icons.repeat,
        TaskType.daily => Icons.today,
        TaskType.todo => Icons.checklist,
        TaskType.reward => Icons.card_giftcard,
      };
}

const rewardColor = Color(0xFFE0A100);
