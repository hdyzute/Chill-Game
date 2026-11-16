/// Trận đánh boss của một ngày, dựng lại từ nhật ký để chiếu thành cảnh
/// đánh nhau: mỗi việc tốt là một đòn của linh thú, bỏ lỡ việc hằng ngày thì
/// boss đánh trả. Không lưu gì thêm: số liệu khớp với [bossProgress], nên bỏ
/// tick hay hoàn tác vẫn đúng.
library;

import 'dart:math';

import '../data/database.dart';
import 'boss.dart';
import 'day.dart';

/// Một đòn của linh thú.
class BattleHit {
  const BattleHit({
    required this.title,
    required this.element,
    required this.damage,
    required this.weakness,
    required this.critical,
  });

  /// Tên việc tốt tạo ra đòn này.
  final String title;
  final TaskElement? element;
  final int damage;

  /// Cùng hệ khắc chế boss: gấp rưỡi sát thương.
  final bool weakness;

  /// Việc tốt có "Linh khí bạo phát".
  final bool critical;
}

class BattleReplay {
  const BattleReplay({
    required this.kind,
    required this.tier,
    required this.maxHp,
    required this.day,
    required this.hpBefore,
    required this.hits,
    required this.missedTitles,
  });

  final BossKind kind;
  final int tier;
  final int maxHp;

  /// Ngày logic của trận.
  final DateTime day;

  /// HP của boss lúc đầu ngày.
  final int hpBefore;
  final List<BattleHit> hits;

  /// Việc hằng ngày bị bỏ lỡ trong ngày: có thì boss đánh trả.
  final List<String> missedTitles;

  bool get counterattack => missedTitles.isNotEmpty;

  int get damage => hits.fold(0, (sum, h) => sum + h.damage);

  int get hpAfter => max(0, hpBefore - damage);

  /// Boss gục trong trận này (hoặc đã gục từ trước mà chưa nhận thưởng).
  bool get defeated => hpAfter == 0;

  /// Có gì để chiếu không.
  bool get eventful => hits.isNotEmpty || counterattack;
}

/// Trận của ngày [day] với boss [kind] bắt đầu lúc [startedAt]. [deeds] là
/// mọi việc tốt (để tính HP đầu ngày), [dayLogs] là nhật ký của riêng ngày
/// đó (việc tốt và bỏ lỡ).
BattleReplay battleReplay({
  required BossKind kind,
  required int tier,
  required DateTime startedAt,
  required List<Deed> deeds,
  required List<TaskLog> dayLogs,
  required DateTime day,
  required int dayStartHour,
}) {
  final before = bossProgress(
    kind: kind,
    tier: tier,
    startedAt: startedAt,
    deeds: deeds,
    missedDays: const {},
    today: day,
    dayStartHour: dayStartHour,
  );
  bool onDay(TaskLog log) => logicalDate(log.createdAt, dayStartHour) == day;
  final started = !day.isBefore(logicalDate(startedAt, dayStartHour));
  return BattleReplay(
    kind: kind,
    tier: tier,
    maxHp: before.maxHp,
    day: day,
    hpBefore: before.hp,
    hits: [
      for (final log in dayLogs)
        if (log.kind == LogKind.complete &&
            onDay(log) &&
            !log.createdAt.isBefore(startedAt))
          BattleHit(
            title: log.title ?? 'Việc tốt',
            element: log.element,
            damage: deedDamage(log.coinsDelta, log.element, kind),
            weakness: log.element == kind.weakness,
            critical: log.critical,
          ),
    ],
    missedTitles: [
      if (started)
        for (final log in dayLogs)
          if (log.kind == LogKind.missed && onDay(log))
            log.title ?? 'Việc hằng ngày',
    ],
  );
}
