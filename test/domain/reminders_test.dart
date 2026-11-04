import 'package:flutter_test/flutter_test.dart';
import 'package:linh_thu_ky_luat/data/database.dart';
import 'package:linh_thu_ky_luat/domain/reminders.dart';

Task _task({
  int id = 1,
  TaskType type = TaskType.daily,
  int? reminderMinutes = 8 * 60,
  int repeatDays = everyDayMask,
  bool completed = false,
  bool habitUp = true,
  int dailyTarget = 1,
  bool archived = false,
}) =>
    Task(
      id: id,
      title: 'Task $id',
      type: type,
      difficulty: Difficulty.easy,
      element: TaskElement.fire,
      habitUp: habitUp,
      habitDown: false,
      dailyTarget: dailyTarget,
      repeatDays: repeatDays,
      reminderMinutes: reminderMinutes,
      cost: 0,
      value: 0,
      streak: 0,
      completed: completed,
      archived: archived,
      sortOrder: 0,
      createdAt: DateTime(2026),
    );

// 2026-11-03 là Thứ 3.
final _tuesday7am = DateTime(2026, 11, 3, 7);

List<ReminderPlan> _plan(List<Task> tasks,
        {DateTime? now, Map<int, int> counts = const {}, int hour = 0}) =>
    planReminders(
      tasks: tasks,
      todayCounts: counts,
      now: now ?? _tuesday7am,
      dayStartHour: hour,
    );

void main() {
  test('daily mỗi ngày: 7 lịch hằng tuần, lần đầu là ngày gần nhất', () {
    final plans = _plan([_task()]);

    expect(plans, hasLength(7));
    expect(plans.every((p) => p.weekly), isTrue);
    final tuesday = plans.firstWhere((p) => p.id == reminderId(1, 2));
    expect(tuesday.first, DateTime(2026, 11, 3, 8));
    final monday = plans.firstWhere((p) => p.id == reminderId(1, 1));
    expect(monday.first, DateTime(2026, 11, 9, 8)); // Thứ 2 tuần sau
  });

  test('daily T2-T4-T6 chỉ có 3 lịch', () {
    final plans = _plan([_task(repeatDays: 0x15)]);
    expect(plans.map((p) => p.first.weekday), unorderedEquals([1, 3, 5]));
  });

  test('daily đã tick hôm nay thì không nhắc hôm nay nữa', () {
    final plans = _plan([_task(completed: true)]);
    final tuesday = plans.firstWhere((p) => p.id == reminderId(1, 2));
    expect(tuesday.first, DateTime(2026, 11, 10, 8));
  });

  test('đã qua giờ nhắc thì lần đầu là tuần sau', () {
    final plans = _plan([_task()], now: DateTime(2026, 11, 3, 9));
    final tuesday = plans.firstWhere((p) => p.id == reminderId(1, 2));
    expect(tuesday.first, DateTime(2026, 11, 10, 8));
  });

  test('thói quen: một lịch mỗi ngày, đủ số lần thì dời sang mai', () {
    final habit = _task(type: TaskType.habit, dailyTarget: 2);

    final notDone = _plan([habit], counts: {1: 1}).single;
    expect(notDone.weekly, isFalse);
    expect(notDone.id, reminderId(1, 0));
    expect(notDone.first, DateTime(2026, 11, 3, 8));
    expect(notDone.body, contains('2 lần'));

    final done = _plan([habit], counts: {1: 2}).single;
    expect(done.first, DateTime(2026, 11, 4, 8));
  });

  test('không nhắc: chưa đặt giờ, việc cần làm, thói quen xấu, đã cất', () {
    expect(
      _plan([
        _task(id: 1, reminderMinutes: null),
        _task(id: 2, type: TaskType.todo),
        _task(id: 3, type: TaskType.habit, habitUp: false),
        _task(id: 4, archived: true),
      ]),
      isEmpty,
    );
  });

  test('giờ bắt đầu ngày 4:00: lúc 2 giờ sáng, tick của hôm qua không chặn '
      'lần nhắc 8:00 sáng nay', () {
    // 2 giờ sáng Thứ 3 vẫn là ngày Thứ 2; "completed" là của Thứ 2.
    final plans = _plan([_task(completed: true)],
        now: DateTime(2026, 11, 3, 2), hour: 4);
    final tuesday = plans.firstWhere((p) => p.id == reminderId(1, 2));
    expect(tuesday.first, DateTime(2026, 11, 3, 8));
  });

  test('định dạng giờ', () {
    expect(formatMinutes(8 * 60), '08:00');
    expect(formatMinutes(21 * 60 + 5), '21:05');
  });
}
