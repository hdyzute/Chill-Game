import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/boss.dart';
import '../domain/day.dart';
import '../domain/history.dart';
import '../domain/pet.dart';
import '../domain/reminders.dart';
import '../domain/widget_snapshot.dart';
import 'boss_repository.dart';
import 'database.dart';
import 'history_repository.dart';
import 'home_widget_updater.dart';
import 'notification_scheduler.dart';
import 'pet_repository.dart';
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

final notificationSchedulerProvider =
    Provider<NotificationScheduler>((ref) => LocalNotificationScheduler());

/// Lịch nhắc cần đặt, tính lại khi task, số lần hôm nay hoặc ngày thay đổi.
/// Null khi dữ liệu chưa tải xong.
final reminderPlansProvider = Provider<List<ReminderPlan>?>((ref) {
  final tasks = ref.watch(tasksProvider).value;
  final counts = ref.watch(todayCountsProvider).value;
  final hour = ref.watch(dayStartHourProvider);
  ref.watch(dayTickProvider);
  if (tasks == null || counts == null || hour == null) return null;
  return planReminders(
    tasks: tasks,
    todayCounts: counts,
    now: ref.watch(clockProvider)(),
    dayStartHour: hour,
  );
});

final historyRepositoryProvider =
    Provider((ref) => HistoryRepository(ref.watch(databaseProvider)));

/// Nhật ký của một tháng, chia theo ngày logic. Khóa là ngày 1 của tháng.
final monthLogsProvider =
    StreamProvider.autoDispose.family<List<TaskLog>, DateTime>((ref, month) {
  final hour = ref.watch(dayStartHourProvider);
  if (hour == null) return const Stream.empty();
  return ref.watch(historyRepositoryProvider).watchBetween(
        dayStartInstant(month, hour),
        dayStartInstant(DateTime(month.year, month.month + 1), hour),
      );
});

final _completionsProvider = StreamProvider<List<Completion>>(
    (ref) => ref.watch(historyRepositoryProvider).watchCompletions());

/// Những ngày logic có làm ít nhất một việc tốt. Null khi chưa tải xong.
final _deedDaysProvider = Provider<Set<DateTime>?>((ref) {
  final completions = ref.watch(_completionsProvider).value;
  final hour = ref.watch(dayStartHourProvider);
  if (completions == null || hour == null) return null;
  return {for (final c in completions) logicalDate(c.at, hour)};
});

/// Số ngày liên tiếp có làm ít nhất một việc tốt. Null khi chưa tải xong.
final activeStreakProvider = Provider<int?>((ref) {
  final days = ref.watch(_deedDaysProvider);
  final today = ref.watch(todayProvider);
  if (days == null || today == null) return null;
  return activeStreak(days, today);
});

final petRepositoryProvider = Provider((ref) => PetRepository(
      ref.watch(databaseProvider),
      clock: ref.watch(clockProvider),
    ));

/// Linh thú, null khi chưa ký khế ước.
final petProvider =
    StreamProvider<Pet?>((ref) => ref.watch(petRepositoryProvider).watch());

/// Số lần làm thói quen xấu hôm nay, cho tâm trạng linh thú.
final todayBadCountProvider = StreamProvider<int>((ref) {
  final today = ref.watch(todayProvider);
  final hour = ref.watch(dayStartHourProvider);
  if (today == null || hour == null) return const Stream.empty();
  return ref
      .watch(scoreServiceProvider)
      .watchBadSince(dayStartInstant(today, hour));
});

/// Giai đoạn, tiến độ ấp và tâm trạng của linh thú. Null khi chưa có linh
/// thú hoặc dữ liệu chưa tải xong.
final petStatusProvider = Provider<PetStatus?>((ref) {
  final pet = ref.watch(petProvider).value;
  final days = ref.watch(_deedDaysProvider);
  final hour = ref.watch(dayStartHourProvider);
  final today = ref.watch(todayProvider);
  final counts = ref.watch(todayCountsProvider).value;
  final bad = ref.watch(todayBadCountProvider).value;
  final resting = ref.watch(profileProvider).value?.resting;
  if (pet == null ||
      days == null ||
      hour == null ||
      today == null ||
      counts == null ||
      bad == null ||
      resting == null) {
    return null;
  }
  return petStatus(
    contractDay: logicalDate(pet.createdAt, hour),
    deedDays: days,
    today: today,
    branch: pet.branch,
    goodToday: counts.values.fold(0, (a, b) => a + b),
    badToday: bad,
    resting: resting,
    bossHit: ref.watch(bossProgressProvider)?.attacked ?? false,
  );
});

/// Cây trên Linh điền, theo ô.
final plantingsProvider = StreamProvider<List<Planting>>(
    (ref) => ref.watch(scoreServiceProvider).watchPlantings());

/// Số việc tốt cùng hệ đã làm từ lúc gieo, theo ô. Null khi chưa tải xong.
final fieldBoostsProvider = Provider<Map<int, int>?>((ref) {
  final plantings = ref.watch(plantingsProvider).value;
  final completions = ref.watch(_completionsProvider).value;
  if (plantings == null || completions == null) return null;
  return {
    for (final p in plantings)
      p.plot: completions
          .where((c) => c.element == p.element && !c.at.isBefore(p.plantedAt))
          .length,
  };
});

/// Túi linh vật: số lượng từng loại đang có.
final inventoryProvider = StreamProvider<Map<SpiritItem, int>>(
    (ref) => ref.watch(scoreServiceProvider).watchInventory());

/// Số linh vật đã nhặt hôm nay, để hiện "x/5".
final todayDropsProvider = StreamProvider<int>((ref) {
  final today = ref.watch(todayProvider);
  final hour = ref.watch(dayStartHourProvider);
  if (today == null || hour == null) return const Stream.empty();
  return ref
      .watch(scoreServiceProvider)
      .watchDropsSince(dayStartInstant(today, hour));
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

final homeWidgetUpdaterProvider =
    Provider<HomeWidgetUpdater>((ref) => AndroidHomeWidgetUpdater());

/// Nội dung widget màn hình chính. Null khi dữ liệu chưa tải xong.
final widgetSnapshotProvider = Provider<WidgetSnapshot?>((ref) {
  final tasks = ref.watch(tasksProvider).value;
  final counts = ref.watch(todayCountsProvider).value;
  final today = ref.watch(todayProvider);
  final hour = ref.watch(dayStartHourProvider);
  final pet = ref.watch(petProvider);
  if (tasks == null ||
      counts == null ||
      today == null ||
      hour == null ||
      !pet.hasValue) {
    return null;
  }
  final status = ref.watch(petStatusProvider);
  // Có linh thú mà chưa tính xong trạng thái thì chờ, để widget không nháy
  // qua bản "chưa có linh thú".
  if (pet.value != null && status == null) return null;
  return widgetSnapshot(
    tasks: tasks,
    todayCounts: counts,
    today: today,
    dayStartHour: hour,
    pet: pet.value,
    status: status,
  );
});

final bossRepositoryProvider = Provider((ref) => BossRepository(
      ref.watch(databaseProvider),
      clock: ref.watch(clockProvider),
    ));

/// Boss đang đánh, null khi chưa khiêu chiến hoặc vừa nhận thưởng.
final activeBossProvider =
    StreamProvider<Boss?>((ref) => ref.watch(bossRepositoryProvider).watchActive());

/// Số boss đã đánh bại, quyết định boss tiếp theo.
final bossDefeatedCountProvider = StreamProvider<int>(
    (ref) => ref.watch(bossRepositoryProvider).watchDefeatedCount());

final _missedTimesProvider = StreamProvider<List<DateTime>>(
    (ref) => ref.watch(historyRepositoryProvider).watchMissedTimes());

/// HP, sát thương và lần tấn công của boss đang đánh. Null khi không có boss
/// hoặc chưa tải xong.
final bossProgressProvider = Provider<BossProgress?>((ref) {
  final boss = ref.watch(activeBossProvider).value;
  final completions = ref.watch(_completionsProvider).value;
  final missed = ref.watch(_missedTimesProvider).value;
  final hour = ref.watch(dayStartHourProvider);
  final today = ref.watch(todayProvider);
  if (boss == null ||
      completions == null ||
      missed == null ||
      hour == null ||
      today == null) {
    return null;
  }
  return bossProgress(
    kind: boss.kind,
    tier: boss.tier,
    startedAt: boss.startedAt,
    deeds: completions,
    missedDays: {for (final t in missed) logicalDate(t, hour)},
    today: today,
    dayStartHour: hour,
  );
});
