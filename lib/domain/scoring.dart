import 'dart:math';

import '../data/task_enums.dart';

/// Công thức chấm điểm, học từ Habitica (scoreTask.js), số liệu chỉnh sau.
///
/// Mỗi task có `value`. Làm task thì value tăng, nên phần thưởng lần sau
/// giảm dần (0.9747^value). Task bị bỏ bê (value âm) làm lại được thưởng nhiều.
class Scoring {
  static const maxValue = 21.27;
  static const minValue = -47.27;

  /// Xu cơ bản cho một task Dễ ở value 0.
  static const coinScale = 10;
  static const critChance = 0.03;
  static const critMultiplier = 2.0;

  static double clampValue(double v) => v.clamp(minValue, maxValue);

  /// Độ thay đổi value cho một lần chấm, dương khi [up].
  static double delta(double value, {required bool up}) =>
      pow(0.9747, clampValue(value)).toDouble() * (up ? 1 : -1);

  /// Tính kết quả khi làm xong (up) hoặc làm việc xấu (down) một task.
  /// [critRoll] là số ngẫu nhiên trong [0, 1), truyền vào để test được.
  static ScoreOutcome score({
    required TaskType type,
    required Difficulty difficulty,
    required double value,
    required int streak,
    required bool up,
    required double critRoll,
  }) {
    assert(type != TaskType.reward, 'Phần thưởng dùng buyReward');
    final d = delta(value, up: up);
    if (!up) {
      // Việc xấu: task đỏ dần, không trừ xu. Sau này ảnh hưởng tâm trạng pet.
      return ScoreOutcome(valueDelta: d, coinsDelta: 0, streakDelta: 0);
    }

    final critical = critRoll < critChance;
    final isDaily = type == TaskType.daily;
    // Streak tính cả lần tick này: tick ngày thứ 3 liên tiếp được +3%.
    final newStreak = isDaily ? streak + 1 : 0;
    final streakBonus = 1 + newStreak / 100;
    final coins = d *
        difficulty.multiplier *
        (critical ? critMultiplier : 1) *
        streakBonus *
        coinScale;

    return ScoreOutcome(
      valueDelta: d,
      coinsDelta: max(1, coins.round()),
      streakDelta: isDaily ? 1 : 0,
      critical: critical,
    );
  }
}

class ScoreOutcome {
  const ScoreOutcome({
    required this.valueDelta,
    required this.coinsDelta,
    required this.streakDelta,
    this.critical = false,
  });

  final double valueDelta;
  final int coinsDelta;
  final int streakDelta;
  final bool critical;
}
