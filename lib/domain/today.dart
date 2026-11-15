/// Việc hôm nay: task nào phải làm, task nào đã xong. Dùng cho tab Hôm nay
/// và widget màn hình chính.
library;

import '../data/database.dart';
import 'day.dart';

/// Daily và việc cần làm: xong khi đã tick. Thói quen tốt: khi đủ số lần
/// hôm nay. Thói quen chỉ có "xấu" thì không bao giờ "xong".
bool isTaskDone(Task task, int todayCount) => switch (task.type) {
      TaskType.habit => task.habitUp && todayCount >= task.dailyTarget,
      TaskType.daily || TaskType.todo => task.completed,
      TaskType.reward => false,
    };

/// Task cần làm trong ngày [today]: daily đúng lịch, thói quen tốt, việc cần
/// làm. Không tính phần thưởng, thói quen chỉ có "xấu", daily ngày nghỉ.
bool isDueToday(Task task, DateTime today) => switch (task.type) {
      TaskType.daily => isDueOn(task.repeatDays, today),
      TaskType.habit => task.habitUp,
      TaskType.todo => true,
      TaskType.reward => false,
    };
