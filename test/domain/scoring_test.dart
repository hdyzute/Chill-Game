import 'package:flutter_test/flutter_test.dart';
import 'package:linh_thu_ky_luat/data/task_enums.dart';
import 'package:linh_thu_ky_luat/domain/scoring.dart';

ScoreOutcome _score({
  TaskType type = TaskType.todo,
  Difficulty difficulty = Difficulty.easy,
  double value = 0,
  int streak = 0,
  bool up = true,
  double critRoll = 0.5,
}) =>
    Scoring.score(
      type: type,
      difficulty: difficulty,
      value: value,
      streak: streak,
      up: up,
      critRoll: critRoll,
    );

void main() {
  test('task Dễ ở value 0 được 10 xu', () {
    final o = _score();
    expect(o.valueDelta, 1);
    expect(o.coinsDelta, 10);
    expect(o.streakDelta, 0);
    expect(o.critical, isFalse);
  });

  test('độ khó nhân vào xu', () {
    expect(_score(difficulty: Difficulty.medium).coinsDelta, 15);
    expect(_score(difficulty: Difficulty.hard).coinsDelta, 20);
  });

  test('daily cộng streak và thưởng 1% mỗi ngày streak', () {
    final first = _score(type: TaskType.daily);
    expect(first.streakDelta, 1);
    expect(first.coinsDelta, 10); // 10 × 1.01

    // Tick ngày thứ 10: 20 × 1.10 = 22.
    expect(
        _score(type: TaskType.daily, difficulty: Difficulty.hard, streak: 9)
            .coinsDelta,
        22);
  });

  test('bạo kích nhân đôi xu', () {
    final o = _score(critRoll: 0);
    expect(o.critical, isTrue);
    expect(o.coinsDelta, 20);
    expect(_score(critRoll: Scoring.critChance).critical, isFalse);
  });

  test('làm task liên tục thì thưởng giảm, bỏ bê lâu thì thưởng tăng', () {
    expect(_score(value: 10).coinsDelta, 8);
    expect(_score(value: -10).coinsDelta, 13);
  });

  test('value bị giới hạn khi tính', () {
    expect(_score(value: 100).coinsDelta,
        _score(value: Scoring.maxValue).coinsDelta);
  });

  test('thói quen xấu làm task đỏ đi, không trừ xu', () {
    final o = _score(type: TaskType.habit, up: false);
    expect(o.valueDelta, -1);
    expect(o.coinsDelta, 0);
    expect(o.critical, isFalse);
  });
}
