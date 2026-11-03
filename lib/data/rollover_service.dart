import 'package:drift/drift.dart';

import '../domain/day.dart';
import '../domain/scoring.dart';
import 'database.dart';

class RolloverResult {
  const RolloverResult({required this.daysPassed, required this.missedTitles});

  final int daysPassed;

  /// Daily bị bỏ lỡ (đã đặt lại chuỗi). Rỗng khi đang bế quan.
  final List<String> missedTitles;
}

/// Xử lý "sang ngày mới", học từ cron của Habitica:
/// - daily bỏ tick; daily bị bỏ lỡ vào ngày phải làm thì mất chuỗi và đỏ đi,
/// - việc cần làm đã xong thì cất đi,
/// - đang bế quan thì không phạt.
/// Thói quen tự đếm lại vì số lần tính theo nhật ký từ đầu ngày.
class RolloverService {
  RolloverService(this._db, {DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _clock;

  /// Trả về null nếu vẫn cùng ngày logic với lần chạy trước.
  Future<RolloverResult?> run() {
    return _db.transaction(() async {
      final profile = await (_db.select(_db.profiles)
            ..where((p) => p.id.equals(profileId)))
          .getSingle();
      final today = logicalDate(_clock(), profile.dayStartHour);
      final last = profile.lastRolloverDate;

      if (last == null) {
        // Lần đầu mở app: chỉ ghi mốc, chưa có gì để xử lý.
        await _setLastRollover(today);
        return null;
      }
      final lastDate = DateTime(last.year, last.month, last.day);
      final days = daysBetween(lastDate, today);
      if (days <= 0) return null;

      final missed = <String>[];
      final dailies = await (_db.select(_db.tasks)
            ..where((t) =>
                t.type.equalsValue(TaskType.daily) & t.archived.not()))
          .get();
      for (final daily in dailies) {
        // Các ngày từ lastDate tới hôm qua. Đã tick thì ngày lastDate xong rồi.
        var misses = 0;
        for (var i = daily.completed ? 1 : 0; i < days; i++) {
          if (isDueOn(daily.repeatDays, addDays(lastDate, i))) misses++;
        }

        var value = daily.value;
        var streak = daily.streak;
        if (misses > 0 && !profile.resting) {
          for (var i = 0; i < misses; i++) {
            value += Scoring.delta(value, up: false);
          }
          streak = 0;
          missed.add(daily.title);
        }
        await (_db.update(_db.tasks)..where((t) => t.id.equals(daily.id)))
            .write(TasksCompanion(
          completed: const Value(false),
          value: Value(value),
          streak: Value(streak),
        ));
      }

      await (_db.update(_db.tasks)
            ..where((t) =>
                t.type.equalsValue(TaskType.todo) & t.completed.equals(true)))
          .write(const TasksCompanion(archived: Value(true)));

      await _setLastRollover(today);
      return RolloverResult(daysPassed: days, missedTitles: missed);
    });
  }

  Future<void> _setLastRollover(DateTime date) =>
      (_db.update(_db.profiles)..where((p) => p.id.equals(profileId)))
          .write(ProfilesCompanion(lastRolloverDate: Value(date)));
}
