import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linh_thu_ky_luat/data/database.dart';
import 'package:linh_thu_ky_luat/data/profile_repository.dart';
import 'package:linh_thu_ky_luat/data/rollover_service.dart';
import 'package:linh_thu_ky_luat/data/score_service.dart';
import 'package:linh_thu_ky_luat/data/task_repository.dart';

import '../helpers.dart';

void main() {
  late AppDatabase db;
  late RolloverService rollover;
  late ScoreService score;
  late DateTime now;

  // 2026-11-02 là Thứ 2.
  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    now = DateTime(2026, 11, 2, 9);
    rollover = RolloverService(db, clock: () => now);
    score = ScoreService(db, random: NoCritRandom(), clock: () => now);
    expect(await rollover.run(), isNull); // lần đầu: chỉ ghi mốc
  });

  tearDown(() => db.close());

  Future<int> addTask(TaskType type, {int repeatDays = everyDayMask}) =>
      db.into(db.tasks).insert(TasksCompanion.insert(
            title: type.label,
            type: type,
            difficulty: Difficulty.easy,
            element: const Value(TaskElement.fire),
            repeatDays: Value(repeatDays),
          ));

  Future<Task> task(int id) =>
      (db.select(db.tasks)..where((t) => t.id.equals(id))).getSingle();

  test('cùng ngày thì không làm gì', () async {
    final id = await addTask(TaskType.daily);
    await score.score(id);
    now = DateTime(2026, 11, 2, 23, 59);

    expect(await rollover.run(), isNull);
    expect((await task(id)).completed, isTrue);
  });

  test('daily đã tick: sang ngày thì bỏ tick, giữ chuỗi', () async {
    final id = await addTask(TaskType.daily);
    await score.score(id);
    now = DateTime(2026, 11, 3, 7);

    final result = await rollover.run();
    expect(result!.daysPassed, 1);
    expect(result.missedTitles, isEmpty);
    final t = await task(id);
    expect(t.completed, isFalse);
    expect(t.streak, 1);
  });

  test('daily bỏ lỡ vào ngày phải làm: mất chuỗi, đỏ đi', () async {
    final id = await addTask(TaskType.daily);
    await (db.update(db.tasks)..where((t) => t.id.equals(id)))
        .write(const TasksCompanion(streak: Value(5), value: Value(3)));
    now = DateTime(2026, 11, 3, 7);

    final result = await rollover.run();
    expect(result!.missedTitles, ['Hằng ngày']);
    final t = await task(id);
    expect(t.streak, 0);
    expect(t.value, lessThan(3));
  });

  test('daily không phải làm hôm qua thì không mất chuỗi', () async {
    // Chỉ lặp Thứ 3: hôm qua (Thứ 2) không phải làm.
    final id = await addTask(TaskType.daily, repeatDays: 0x02);
    await (db.update(db.tasks)..where((t) => t.id.equals(id)))
        .write(const TasksCompanion(streak: Value(4)));
    now = DateTime(2026, 11, 3, 7);

    final result = await rollover.run();
    expect(result!.missedTitles, isEmpty);
    expect((await task(id)).streak, 4);
  });

  test('vắng mặt nhiều ngày: tick ngày cuối vẫn mất chuỗi vì bỏ các ngày giữa',
      () async {
    final id = await addTask(TaskType.daily);
    await score.score(id);
    now = DateTime(2026, 11, 5, 8);

    final result = await rollover.run();
    expect(result!.daysPassed, 3);
    expect(result.missedTitles, ['Hằng ngày']);
    expect((await task(id)).streak, 0);
  });

  test('bế quan: bỏ lỡ không mất chuỗi, nhưng vẫn bỏ tick', () async {
    await ProfileRepository(db).setResting(true);
    final missedId = await addTask(TaskType.daily);
    await (db.update(db.tasks)..where((t) => t.id.equals(missedId)))
        .write(const TasksCompanion(streak: Value(7)));
    final doneId = await addTask(TaskType.daily);
    await score.score(doneId);
    now = DateTime(2026, 11, 3, 7);

    final result = await rollover.run();
    expect(result!.missedTitles, isEmpty);
    expect((await task(missedId)).streak, 7);
    expect((await task(doneId)).completed, isFalse);
  });

  test('việc cần làm đã xong thì cất đi, chưa xong thì giữ', () async {
    final done = await addTask(TaskType.todo);
    final pending = await addTask(TaskType.todo);
    await score.score(done);
    now = DateTime(2026, 11, 3, 7);

    await rollover.run();
    final visible = await TaskRepository(db).watchAll().first;
    expect(visible.map((t) => t.id), [pending]);
    expect((await task(done)).archived, isTrue);
  });

  test('giờ bắt đầu ngày 4:00: 2 giờ sáng chưa sang ngày', () async {
    await ProfileRepository(db).setDayStartHour(4);
    final id = await addTask(TaskType.daily);
    await score.score(id);

    now = DateTime(2026, 11, 3, 2);
    expect(await rollover.run(), isNull);
    expect((await task(id)).completed, isTrue);

    now = DateTime(2026, 11, 3, 4, 1);
    expect(await rollover.run(), isNotNull);
    expect((await task(id)).completed, isFalse);
  });
}
