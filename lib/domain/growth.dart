/// Linh thú lớn lên: EXP và điểm hệ từ linh vật hấp thụ, cấp, và điều kiện
/// tiến hóa kép (đủ cấp và đủ chuỗi ngày, xem PLAN.md).
library;

import '../data/task_enums.dart';

class Growth {
  static const commonExp = 10;
  static const rareExp = 30;
  static const commonPoints = 1;
  static const rarePoints = 3;

  /// Ấu thú tiến hóa khi đạt cấp này...
  static const evolveLevel = 5;

  /// ...và có chuỗi ngày liên tiếp làm việc tốt dài chừng này.
  static const evolveStreak = 7;

  static int expOf(SpiritItem item) => item.rare ? rareExp : commonExp;

  static int pointsOf(SpiritItem item) =>
      item.rare ? rarePoints : commonPoints;

  /// Tổng EXP cần để đạt [level]: cấp 2 = 20, 3 = 60, 4 = 120, 5 = 200.
  /// Mỗi cấp tốn hơn cấp trước 20 EXP.
  static int expForLevel(int level) => 10 * level * (level - 1);

  static int levelFor(int exp) {
    var level = 1;
    while (exp >= expForLevel(level + 1)) {
      level++;
    }
    return level;
  }

  /// Hệ có điểm cao nhất, hòa thì theo thứ tự Hỏa, Thủy, Mộc. Null khi chưa
  /// có điểm nào.
  static TaskElement? leadingElement(Map<TaskElement, int> points) {
    TaskElement? best;
    for (final element in TaskElement.values) {
      final p = points[element] ?? 0;
      if (p > 0 && (best == null || p > points[best]!)) best = element;
    }
    return best;
  }
}

/// Tiến độ tiến hóa của ấu thú.
class EvolveCheck {
  EvolveCheck({
    required this.level,
    required this.streak,
    required Map<TaskElement, int> points,
  }) : branch = Growth.leadingElement(points);

  final int level;
  final int streak;

  /// Nhánh sẽ tiến hóa theo nếu tiến hóa bây giờ.
  final TaskElement? branch;

  bool get levelOk => level >= Growth.evolveLevel;
  bool get streakOk => streak >= Growth.evolveStreak;
  bool get ready => levelOk && streakOk && branch != null;
}
