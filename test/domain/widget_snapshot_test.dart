import 'package:flutter_test/flutter_test.dart';
import 'package:linh_thu_ky_luat/data/database.dart';
import 'package:linh_thu_ky_luat/domain/pet.dart';
import 'package:linh_thu_ky_luat/domain/widget_snapshot.dart';

void main() {
  // Thứ Ba.
  final today = DateTime(2026, 11, 3);
  var nextId = 1;

  Task task(String title, TaskType type,
          {int target = 1,
          bool completed = false,
          bool up = true,
          int repeatDays = everyDayMask}) =>
      Task(
        id: nextId++,
        title: title,
        type: type,
        difficulty: Difficulty.easy,
        element: TaskElement.fire,
        habitUp: up,
        habitDown: !up,
        dailyTarget: target,
        repeatDays: repeatDays,
        cost: 0,
        value: 0,
        streak: 0,
        completed: completed,
        archived: false,
        sortOrder: 0,
        createdAt: today,
      );

  Pet pet({int exp = 0, TaskElement? branch}) => Pet(
        id: 1,
        name: 'Mochi',
        createdAt: today,
        exp: exp,
        firePoints: 0,
        waterPoints: 0,
        woodPoints: 0,
        branch: branch,
      );

  PetStatus status(PetStage stage, PetMood mood) => PetStatus(
        stage: stage,
        hatchProgress: stage == PetStage.egg ? 0 : 1,
        hatchedOn: stage == PetStage.egg ? null : today,
        daysTogether: 1,
        deedToday: mood == PetMood.happy,
        mood: mood,
      );

  test('chưa có linh thú: tên app, tiến độ và việc chưa làm', () {
    final read = task('Đọc sách', TaskType.daily);
    final water = task('Uống nước', TaskType.habit, target: 3);
    final s = widgetSnapshot(
      tasks: [
        read,
        water,
        task('Xong rồi', TaskType.todo, completed: true),
        task('Phần thưởng', TaskType.reward),
        task('Thức khuya', TaskType.habit, up: false),
        // Chỉ thứ Hai: hôm nay nghỉ.
        task('Họp tuần', TaskType.daily, repeatDays: 1),
      ],
      todayCounts: {water.id: 1},
      today: today,
      dayStartHour: 4,
    );
    expect(s.emoji, '🥚');
    expect(s.title, 'Linh Thú Kỷ Luật');
    expect(s.subtitle, 'Hôm nay 1/3 việc');
    expect(s.tasks, '• Đọc sách\n• Uống nước (1/3)');
    expect(s.date, '2026-11-03');
    expect(s.toData()['day_start_hour'], '4');
  });

  test('có ấu thú: tên, cấp, tâm trạng; quá 3 việc thì gộp', () {
    final s = widgetSnapshot(
      tasks: [for (var i = 1; i <= 5; i++) task('Việc $i', TaskType.todo)],
      todayCounts: {},
      today: today,
      dayStartHour: 0,
      pet: pet(exp: 60),
      status: status(PetStage.baby, PetMood.sad),
    );
    expect(s.emoji, '🐾');
    expect(s.title, 'Mochi · Cấp 3');
    expect(s.subtitle, 'Buồn · Hôm nay 0/5 việc');
    expect(s.tasks, '• Việc 1\n• Việc 2\n• Việc 3\n+2 việc nữa');
  });

  test('trưởng thành hiện biểu tượng hệ; xong hết hoặc không có việc', () {
    final adult = widgetSnapshot(
      tasks: [task('Chạy', TaskType.daily, completed: true)],
      todayCounts: {},
      today: today,
      dayStartHour: 0,
      pet: pet(exp: 200, branch: TaskElement.water),
      status: status(PetStage.adult, PetMood.happy),
    );
    expect(adult.emoji, '💧');
    expect(adult.subtitle, 'Vui · Hôm nay 1/1 việc');
    expect(adult.tasks, 'Xong hết việc hôm nay!');

    final egg = widgetSnapshot(
      tasks: [],
      todayCounts: {},
      today: today,
      dayStartHour: 0,
      pet: pet(),
      status: status(PetStage.egg, PetMood.sad),
    );
    expect(egg.title, 'Mochi · Trứng');
    expect(egg.subtitle, 'Hôm nay 0/0 việc');
    expect(egg.tasks, 'Chưa có việc nào cho hôm nay.');
  });
}
