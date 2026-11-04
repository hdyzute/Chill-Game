import '../data/database.dart';
import 'day.dart';

/// Một lịch nhắc lặp lại để đặt với hệ điều hành.
class ReminderPlan {
  const ReminderPlan({
    required this.id,
    required this.title,
    required this.body,
    required this.first,
    required this.weekly,
  });

  /// Id thông báo, xem [reminderId].
  final int id;
  final String title;
  final String body;

  /// Lần nhắc đầu tiên (giờ máy). Các lần sau lặp lại cùng giờ.
  final DateTime first;

  /// true: lặp mỗi tuần vào thứ của [first]. false: lặp mỗi ngày.
  final bool weekly;

  @override
  bool operator ==(Object other) =>
      other is ReminderPlan &&
      other.id == id &&
      other.title == title &&
      other.body == body &&
      other.first == first &&
      other.weekly == weekly;

  @override
  int get hashCode => Object.hash(id, title, body, first, weekly);

  @override
  String toString() =>
      'ReminderPlan($id, $title, $first, ${weekly ? 'weekly' : 'daily'})';
}

/// 480 → "08:00".
String formatMinutes(int minutes) =>
    '${(minutes ~/ 60).toString().padLeft(2, '0')}:'
    '${(minutes % 60).toString().padLeft(2, '0')}';

/// Daily: một lịch cho mỗi thứ trong tuần (weekday 1–7).
/// Thói quen: một lịch mỗi ngày (weekday 0).
int reminderId(int taskId, int weekday) => taskId * 8 + weekday;

/// Lên lịch nhắc cho daily và thói quen tốt có giờ nhắc.
///
/// Lịch lặp mãi cả khi không mở app. Nếu hôm nay task đã xong, hoặc đã qua
/// giờ nhắc, thì lần đầu tiên dời sang lần kế tiếp.
List<ReminderPlan> planReminders({
  required List<Task> tasks,
  required Map<int, int> todayCounts,
  required DateTime now,
  required int dayStartHour,
}) {
  final today = logicalDate(now, dayStartHour);
  final calendarToday = DateTime(now.year, now.month, now.day);
  final plans = <ReminderPlan>[];

  for (final task in tasks) {
    final minutes = task.reminderMinutes;
    if (minutes == null || task.archived) continue;
    final doneToday = switch (task.type) {
      TaskType.daily => task.completed,
      TaskType.habit when task.habitUp =>
        (todayCounts[task.id] ?? 0) >= task.dailyTarget,
      _ => null, // không nhắc loại này
    };
    if (doneToday == null) continue;

    DateTime at(DateTime date) =>
        DateTime(date.year, date.month, date.day, minutes ~/ 60, minutes % 60);

    // Lần nhắc này có cần bỏ qua không: đã qua giờ, hoặc rơi vào hôm nay
    // (theo ngày logic) mà task đã xong.
    bool skip(DateTime when) =>
        !when.isAfter(now) ||
        (doneToday && logicalDate(when, dayStartHour) == today);

    if (task.type == TaskType.habit) {
      var first = at(calendarToday);
      if (skip(first)) first = at(addDays(calendarToday, 1));
      plans.add(ReminderPlan(
        id: reminderId(task.id, 0),
        title: task.title,
        body: _body(task),
        first: first,
        weekly: false,
      ));
      continue;
    }

    for (var weekday = 1; weekday <= 7; weekday++) {
      if (!isDueOn(task.repeatDays, _dateWithWeekday(calendarToday, weekday))) {
        continue;
      }
      var first = at(_dateWithWeekday(calendarToday, weekday));
      if (skip(first)) first = at(addDays(first, 7));
      plans.add(ReminderPlan(
        id: reminderId(task.id, weekday),
        title: task.title,
        body: _body(task),
        first: first,
        weekly: true,
      ));
    }
  }
  return plans;
}

/// Ngày đầu tiên kể từ [from] (tính cả [from]) rơi vào [weekday].
DateTime _dateWithWeekday(DateTime from, int weekday) =>
    addDays(from, (weekday - from.weekday) % 7);

String _body(Task task) => task.type == TaskType.habit && task.dailyTarget > 1
    ? 'Hôm nay làm đủ ${task.dailyTarget} lần nhé! Linh thú đang chờ bạn.'
    : 'Đến giờ rồi! Linh thú đang chờ bạn.';
