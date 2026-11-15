/// Thành tựu, học từ Habitica (chuỗi 21 ngày, Perfect Day). Không lưu: tính
/// từ nhật ký, linh thú và boss, nên bỏ tick hay hoàn tác luôn khớp. Thành
/// tựu chỉ là huy hiệu, không có thưởng, để không cày được.
library;

import 'day.dart';

/// Mỗi loại thành tựu có nhiều mốc, đạt mốc nào thì mở mốc đó.
enum AchievementKind {
  deeds('Tích đức', [10, 50, 200, 500, 1000]),
  streak('Tâm bền', [3, 7, 21, 50, 100]),
  perfectDays('Viên mãn', [1, 7, 30, 100]),
  checkIns('Chuyên cần', [7, 30, 100, 365]),
  bosses('Trảm yêu', [1, 3, 9]),
  petLevel('Đồng hành', [2, 5, 10]);

  const AchievementKind(this.label, this.targets);

  final String label;

  /// Các mốc, tăng dần.
  final List<int> targets;

  /// Mô tả mốc [target], ví dụ "21 ngày liên tiếp có việc tốt".
  String goal(int target) => switch (this) {
        deeds => 'Làm $target việc tốt',
        streak => '$target ngày liên tiếp có việc tốt',
        perfectDays => '$target ngày làm đủ mọi việc hằng ngày',
        checkIns => 'Điểm danh $target ngày',
        bosses => 'Đánh bại $target boss',
        petLevel => 'Linh thú đạt cấp $target',
      };
}

/// Số liệu để xét thành tựu.
class AchievementStats {
  const AchievementStats({
    this.deeds = 0,
    this.longestStreak = 0,
    this.perfectDays = 0,
    this.checkIns = 0,
    this.bosses = 0,
    this.petLevel = 0,
  });

  /// Tổng số việc tốt.
  final int deeds;

  /// Chuỗi dài nhất từng có: số ngày liên tiếp có ít nhất một việc tốt.
  final int longestStreak;

  /// Số ngày có việc tốt mà không bỏ lỡ việc hằng ngày nào.
  final int perfectDays;
  final int checkIns;

  /// Số boss đã đánh bại và nhận thưởng.
  final int bosses;

  /// Cấp linh thú, 0 khi chưa có linh thú.
  final int petLevel;

  int valueOf(AchievementKind kind) => switch (kind) {
        AchievementKind.deeds => deeds,
        AchievementKind.streak => longestStreak,
        AchievementKind.perfectDays => perfectDays,
        AchievementKind.checkIns => checkIns,
        AchievementKind.bosses => bosses,
        AchievementKind.petLevel => petLevel,
      };

  /// Lấy giá trị lớn hơn của từng số liệu.
  AchievementStats maxWith(AchievementStats other) => AchievementStats(
        deeds: _max(deeds, other.deeds),
        longestStreak: _max(longestStreak, other.longestStreak),
        perfectDays: _max(perfectDays, other.perfectDays),
        checkIns: _max(checkIns, other.checkIns),
        bosses: _max(bosses, other.bosses),
        petLevel: _max(petLevel, other.petLevel),
      );

  static int _max(int a, int b) => a > b ? a : b;

  @override
  bool operator ==(Object other) =>
      other is AchievementStats &&
      AchievementKind.values.every((k) => valueOf(k) == other.valueOf(k));

  @override
  int get hashCode =>
      Object.hashAll([for (final k in AchievementKind.values) valueOf(k)]);
}

class AchievementProgress {
  const AchievementProgress(this.kind, this.value);

  final AchievementKind kind;
  final int value;

  /// Số mốc đã đạt.
  int get reached => kind.targets.where((t) => value >= t).length;

  /// Mốc kế tiếp, null khi đã đạt hết.
  int? get nextTarget => reached < kind.targets.length
      ? kind.targets[reached]
      : null;

  bool get complete => nextTarget == null;
}

List<AchievementProgress> achievementProgress(AchievementStats stats) => [
      for (final kind in AchievementKind.values)
        AchievementProgress(kind, stats.valueOf(kind)),
    ];

/// Tổng số mốc của mọi thành tựu.
final totalAchievements =
    AchievementKind.values.fold(0, (sum, k) => sum + k.targets.length);

/// Số mốc đã mở.
int unlockedAchievements(AchievementStats stats) =>
    achievementProgress(stats).fold(0, (sum, p) => sum + p.reached);

/// Các mốc có trong [after] mà chưa có trong [before].
List<({AchievementKind kind, int target})> newlyUnlocked(
        AchievementStats before, AchievementStats after) =>
    [
      for (final kind in AchievementKind.values)
        for (final target in kind.targets)
          if (before.valueOf(kind) < target && after.valueOf(kind) >= target)
            (kind: kind, target: target),
    ];

/// Chuỗi dài nhất các ngày liên tiếp trong [days] (ngày logic).
int longestRun(Set<DateTime> days) {
  var best = 0;
  for (final day in days) {
    // Chỉ đếm từ ngày đầu của mỗi chuỗi.
    if (days.contains(addDays(day, -1))) continue;
    var run = 1;
    while (days.contains(addDays(day, run))) {
      run++;
    }
    if (run > best) best = run;
  }
  return best;
}

/// Số ngày "viên mãn": có việc tốt và không bỏ lỡ việc hằng ngày nào. Các
/// ngày trước [today] xét theo dòng "bỏ lỡ" ghi lúc sang ngày. Hôm nay chưa
/// sang ngày nên xét theo [todayPerfect]: đã làm đủ daily phải làm hôm nay.
int perfectDayCount({
  required Set<DateTime> deedDays,
  required Set<DateTime> missedDays,
  required DateTime today,
  required bool todayPerfect,
}) {
  final past = deedDays
      .where((d) => d.isBefore(today) && !missedDays.contains(d))
      .length;
  return past + (todayPerfect && deedDays.contains(today) ? 1 : 0);
}
