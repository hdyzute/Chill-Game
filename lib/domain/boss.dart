/// Bí cảnh: boss có HP, việc tốt gây sát thương, học từ boss của Habitica.
/// Sát thương tích lũy trong ngày và chỉ đánh vào boss lúc sang ngày, nên HP
/// tính từ nhật ký các ngày trước: bỏ tick hôm nay không làm HP nhảy lung tung.
/// Bỏ lỡ daily thì boss tấn công tâm trạng linh thú, không bao giờ làm nó chết.
library;

import 'dart:math';

import '../data/task_enums.dart';
import 'day.dart';

class BossStats {
  static const _baseHp = {
    BossKind.fireWolf: 150,
    BossKind.iceDragon: 300,
    BossKind.treeDemon: 450,
  };
  static const _baseCoins = {
    BossKind.fireWolf: 50,
    BossKind.iceDragon: 100,
    BossKind.treeDemon: 150,
  };

  /// Việc tốt cùng hệ khắc chế gây sát thương nhân chừng này.
  static const weaknessMultiplier = 1.5;

  /// Số linh vật "ngàn năm" (hệ của boss) khi đánh bại.
  static const rewardItems = 2;

  static int maxHp(BossKind kind, int tier) => _baseHp[kind]! * tier;

  static int rewardCoins(BossKind kind, int tier) => _baseCoins[kind]! * tier;

  /// Boss tiếp theo sau khi đã đánh bại [defeated] con: lần lượt, hết vòng
  /// thì sang vòng mạnh hơn.
  static BossKind nextKind(int defeated) =>
      BossKind.values[defeated % BossKind.values.length];

  static int nextTier(int defeated) => 1 + defeated ~/ BossKind.values.length;
}

/// Sát thương của một việc tốt: bằng số xu nó kiếm được, gấp rưỡi nếu cùng
/// hệ khắc chế boss.
int deedDamage(int coins, TaskElement? element, BossKind kind) =>
    element == kind.weakness
        ? (coins * BossStats.weaknessMultiplier).round()
        : coins;

/// Một việc tốt, đủ để tính sát thương.
typedef Deed = ({DateTime at, TaskElement? element, int coins});

class BossProgress {
  const BossProgress({
    required this.kind,
    required this.tier,
    required this.maxHp,
    required this.dealt,
    required this.pending,
    required this.attacked,
  });

  final BossKind kind;
  final int tier;
  final int maxHp;

  /// Sát thương đã đánh vào boss (các ngày trước hôm nay).
  final int dealt;

  /// Sát thương tích lũy hôm nay, đánh vào lúc sang ngày.
  final int pending;

  /// Hôm qua bỏ lỡ daily nên boss vừa tấn công linh thú.
  final bool attacked;

  int get hp => max(0, maxHp - dealt);
  bool get defeated => dealt >= maxHp;
}

/// [missedDays] là các ngày logic có daily bị bỏ lỡ.
BossProgress bossProgress({
  required BossKind kind,
  required int tier,
  required DateTime startedAt,
  required List<Deed> deeds,
  required Set<DateTime> missedDays,
  required DateTime today,
  required int dayStartHour,
}) {
  var dealt = 0, pending = 0;
  for (final deed in deeds) {
    if (deed.at.isBefore(startedAt)) continue;
    final damage = deedDamage(deed.coins, deed.element, kind);
    final day = logicalDate(deed.at, dayStartHour);
    if (day.isBefore(today)) {
      dealt += damage;
    } else if (day == today) {
      pending += damage;
    }
  }
  final maxHp = BossStats.maxHp(kind, tier);
  final yesterday = addDays(today, -1);
  return BossProgress(
    kind: kind,
    tier: tier,
    maxHp: maxHp,
    dealt: dealt,
    pending: pending,
    attacked: dealt < maxHp &&
        missedDays.contains(yesterday) &&
        !yesterday.isBefore(logicalDate(startedAt, dayStartHour)),
  );
}
