import 'package:flutter_test/flutter_test.dart';
import 'package:linh_thu_ky_luat/data/database.dart';
import 'package:linh_thu_ky_luat/domain/battle.dart';
import 'package:linh_thu_ky_luat/domain/boss.dart';

void main() {
  final start = DateTime(2026, 11, 1, 10);
  final day = DateTime(2026, 11, 3);
  var nextId = 1;

  TaskLog log(
    LogKind kind,
    DateTime at, {
    int coins = 0,
    TaskElement? element,
    bool critical = false,
    String? title,
  }) => TaskLog(
    id: nextId++,
    taskId: 1,
    kind: kind,
    valueDelta: 0,
    coinsDelta: coins,
    streakDelta: 0,
    critical: critical,
    createdAt: at,
    title: title,
    element: element,
    dropCount: 0,
  );

  Deed deed(TaskLog l) =>
      (at: l.createdAt, element: l.element, coins: l.coinsDelta);

  BattleReplay replay(List<TaskLog> logs, {DateTime? on}) => battleReplay(
    kind: BossKind.fireWolf,
    tier: 1,
    startedAt: start,
    deeds: [
      for (final l in logs)
        if (l.kind == LogKind.complete) deed(l),
    ],
    dayLogs: logs,
    day: on ?? day,
    dayStartHour: 0,
  );

  test(
    'HP đầu ngày trừ các ngày trước; mỗi việc tốt trong ngày là một đòn',
    () {
      final r = replay([
        log(LogKind.complete, DateTime(2026, 11, 2, 9), coins: 40),
        log(
          LogKind.complete,
          DateTime(2026, 11, 3, 8),
          coins: 20,
          element: TaskElement.water,
          title: 'Đọc sách',
        ),
        log(
          LogKind.complete,
          DateTime(2026, 11, 3, 9),
          coins: 10,
          critical: true,
          title: 'Chạy bộ',
        ),
        // Hôm sau: không thuộc trận này.
        log(LogKind.complete, DateTime(2026, 11, 4, 9), coins: 99),
      ]);
      expect(r.maxHp, 150);
      expect(r.hpBefore, 110);
      expect([for (final h in r.hits) h.title], ['Đọc sách', 'Chạy bộ']);
      expect(r.hits.first.damage, 30); // Thủy khắc Hỏa: gấp rưỡi
      expect(r.hits.first.weakness, isTrue);
      expect(r.hits.last.critical, isTrue);
      expect(r.damage, 40);
      expect(r.hpAfter, 70);
      expect(r.defeated, isFalse);
      expect(r.counterattack, isFalse);
      expect(r.eventful, isTrue);
    },
  );

  test('việc tốt trước lúc khiêu chiến không tính', () {
    final r = replay([
      log(LogKind.complete, DateTime(2026, 11, 1, 9), coins: 50),
    ], on: DateTime(2026, 11, 1));
    expect(r.hits, isEmpty);
    expect(r.hpBefore, 150);
    expect(r.eventful, isFalse);
  });

  test('bỏ lỡ việc hằng ngày thì boss đánh trả', () {
    final r = replay([
      log(LogKind.missed, DateTime(2026, 11, 3, 23, 59), title: 'Ngủ sớm'),
    ]);
    expect(r.counterattack, isTrue);
    expect(r.missedTitles, ['Ngủ sớm']);
    expect(r.hpAfter, 150);
  });

  test('đủ sát thương thì boss gục, HP không âm', () {
    final r = replay([
      log(
        LogKind.complete,
        DateTime(2026, 11, 3, 9),
        coins: 120,
        element: TaskElement.water,
      ),
    ]);
    expect(r.damage, 180);
    expect(r.hpAfter, 0);
    expect(r.defeated, isTrue);
  });
}
