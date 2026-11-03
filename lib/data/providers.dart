import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/day.dart';
import 'database.dart';
import 'profile_repository.dart';
import 'rollover_service.dart';
import 'score_service.dart';
import 'task_repository.dart';

/// Đồng hồ của app. Test ghi đè để giả lập sang ngày.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final taskRepositoryProvider =
    Provider((ref) => TaskRepository(ref.watch(databaseProvider)));

final tasksProvider = StreamProvider<List<Task>>(
    (ref) => ref.watch(taskRepositoryProvider).watchAll());

final profileRepositoryProvider =
    Provider((ref) => ProfileRepository(ref.watch(databaseProvider)));

final profileProvider = StreamProvider<Profile>(
    (ref) => ref.watch(profileRepositoryProvider).watch());

final scoreServiceProvider = Provider((ref) => ScoreService(
      ref.watch(databaseProvider),
      clock: ref.watch(clockProvider),
    ));

final rolloverServiceProvider = Provider((ref) => RolloverService(
      ref.watch(databaseProvider),
      clock: ref.watch(clockProvider),
    ));

final coinsProvider =
    StreamProvider<int>((ref) => ref.watch(scoreServiceProvider).watchCoins());

/// Tăng mỗi khi sang ngày mới, để mọi thứ phụ thuộc "hôm nay" tính lại.
final dayTickProvider = NotifierProvider<DayTick, int>(DayTick.new);

class DayTick extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state++;
}

final dayStartHourProvider = Provider<int?>(
    (ref) => ref.watch(profileProvider.select((p) => p.value?.dayStartHour)));

/// Ngày logic hiện tại (nửa đêm của ngày đó). Null khi chưa tải xong cài đặt.
final todayProvider = Provider<DateTime?>((ref) {
  ref.watch(dayTickProvider);
  final hour = ref.watch(dayStartHourProvider);
  if (hour == null) return null;
  return logicalDate(ref.watch(clockProvider)(), hour);
});

/// Số lần hoàn thành hôm nay của từng task (taskId → số lần).
final todayCountsProvider = StreamProvider<Map<int, int>>((ref) {
  final today = ref.watch(todayProvider);
  final hour = ref.watch(dayStartHourProvider);
  if (today == null || hour == null) return const Stream.empty();
  return ref
      .watch(scoreServiceProvider)
      .watchCountsSince(dayStartInstant(today, hour));
});
