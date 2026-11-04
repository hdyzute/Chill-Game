import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/day.dart';
import '../domain/history.dart';
import '../domain/pet.dart';
import '../domain/reminders.dart';
import 'database.dart';
import 'history_repository.dart';
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

final _completionTimesProvider = StreamProvider<List<DateTime>>(
    (ref) => ref.watch(historyRepositoryProvider).watchCompletionTimes());

/// Những ngày logic có làm ít nhất một việc tốt. Null khi chưa tải xong.
final _deedDaysProvider = Provider<Set<DateTime>?>((ref) {
  final times = ref.watch(_completionTimesProvider).value;
  final hour = ref.watch(dayStartHourProvider);
  if (times == null || hour == null) return null;
  return {for (final t in times) logicalDate(t, hour)};
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

/// Giai đoạn và tiến độ ấp của linh thú. Null khi chưa có linh thú hoặc dữ
/// liệu chưa tải xong.
final petStatusProvider = Provider<PetStatus?>((ref) {
  final pet = ref.watch(petProvider).value;
  final days = ref.watch(_deedDaysProvider);
  final hour = ref.watch(dayStartHourProvider);
  final today = ref.watch(todayProvider);
  if (pet == null || days == null || hour == null || today == null) {
    return null;
  }
  return petStatus(
    contractDay: logicalDate(pet.createdAt, hour),
    deedDays: days,
    today: today,
  );
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
