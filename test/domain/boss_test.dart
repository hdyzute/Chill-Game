import 'package:flutter_test/flutter_test.dart';
import 'package:linh_thu_ky_luat/data/task_enums.dart';
import 'package:linh_thu_ky_luat/domain/boss.dart';

void main() {
  final started = DateTime(2026, 11, 10, 8);
  final today = DateTime(2026, 11, 12);
  Deed deed(int day, int coins, [TaskElement? element = TaskElement.fire]) =>
      (at: DateTime(2026, 11, day, 12), element: element, coins: coins);

  BossProgress progress(List<Deed> deeds,
          {Set<DateTime> missed = const {},
          BossKind kind = BossKind.fireWolf,
          int tier = 1}) =>
      bossProgress(
        kind: kind,
        tier: tier,
        startedAt: started,
        deeds: deeds,
        missedDays: missed,
        today: today,
        dayStartHour: 0,
      );

  test('boss lần lượt, hết vòng thì mạnh hơn', () {
    expect([for (var i = 0; i < 4; i++) BossStats.nextKind(i)], [
      BossKind.fireWolf,
      BossKind.iceDragon,
      BossKind.treeDemon,
      BossKind.fireWolf,
    ]);
    expect(BossStats.nextTier(2), 1);
    expect(BossStats.nextTier(3), 2);
    expect(BossStats.maxHp(BossKind.iceDragon, 2), 600);
    expect(BossStats.rewardCoins(BossKind.treeDemon, 1), 150);
  });

  test('sát thương bằng xu, gấp rưỡi khi cùng hệ khắc chế', () {
    expect(deedDamage(20, TaskElement.fire, BossKind.fireWolf), 20);
    expect(deedDamage(20, TaskElement.water, BossKind.fireWolf), 30);
    expect(deedDamage(15, null, BossKind.fireWolf), 15);
  });

  test('việc tốt các ngày trước đánh vào boss, hôm nay còn tích lũy', () {
    final p = progress([
      deed(9, 50), // trước khi khiêu chiến: không tính
      deed(10, 20),
      deed(11, 20, TaskElement.water),
      deed(12, 25),
    ]);
    expect(p.dealt, 50);
    expect(p.pending, 25);
    expect(p.hp, 100);
    expect(p.defeated, isFalse);
  });

  test('đủ sát thương các ngày trước thì đánh bại', () {
    final p = progress([deed(10, 100), deed(11, 60)]);
    expect(p.hp, 0);
    expect(p.defeated, isTrue);
  });

  test('bỏ lỡ hôm qua thì boss tấn công; bỏ lỡ trước khi khiêu chiến thì không',
      () {
    expect(progress([], missed: {DateTime(2026, 11, 11)}).attacked, isTrue);
    expect(progress([], missed: {DateTime(2026, 11, 10)}).attacked, isFalse);
    final early = bossProgress(
      kind: BossKind.fireWolf,
      tier: 1,
      startedAt: DateTime(2026, 11, 12, 8),
      deeds: const [],
      missedDays: {DateTime(2026, 11, 11)},
      today: today,
      dayStartHour: 0,
    );
    expect(early.attacked, isFalse);
    // Boss đã bị đánh bại thì không tấn công nữa.
    expect(
        progress([deed(10, 200)], missed: {DateTime(2026, 11, 11)}).attacked,
        isFalse);
  });
}
