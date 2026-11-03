import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linh_thu_ky_luat/data/database.dart';
import 'package:linh_thu_ky_luat/data/task_repository.dart';

void main() {
  late AppDatabase db;
  late TaskRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = TaskRepository(db);
  });

  tearDown(() => db.close());

  test('thêm, sửa, xóa task', () async {
    final id = await repo.add(const TasksCompanion(
      title: Value('Chạy bộ'),
      type: Value(TaskType.daily),
      difficulty: Value(Difficulty.medium),
      element: Value(TaskElement.fire),
    ));

    var tasks = await repo.watchAll().first;
    expect(tasks.single.title, 'Chạy bộ');
    expect(tasks.single.repeatDays, everyDayMask);
    expect(tasks.single.streak, 0);

    await repo.updateFields(id, const TasksCompanion(title: Value('Chạy bộ 5km')));
    tasks = await repo.watchAll().first;
    expect(tasks.single.title, 'Chạy bộ 5km');
    expect(tasks.single.difficulty, Difficulty.medium);

    await repo.delete(id);
    expect(await repo.watchAll().first, isEmpty);
  });

  test('phần thưởng không có hệ', () async {
    await repo.add(const TasksCompanion(
      title: Value('Xem phim'),
      type: Value(TaskType.reward),
      difficulty: Value(Difficulty.easy),
      cost: Value(30),
    ));

    final reward = (await repo.watchAll().first).single;
    expect(reward.element, isNull);
    expect(reward.cost, 30);
  });

  test('mô tả ngày lặp', () {
    expect(describeRepeatDays(everyDayMask), 'Mỗi ngày');
    expect(describeRepeatDays(0x15), 'T2, T4, T6');
  });
}
