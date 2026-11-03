import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linh_thu_ky_luat/data/database.dart';
import 'package:linh_thu_ky_luat/data/score_service.dart';

import '../helpers.dart';

void main() {
  late AppDatabase db;
  late ScoreService service;
  late DateTime now;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    now = DateTime(2026, 11, 3, 9);
    service = ScoreService(db, random: NoCritRandom(), clock: () => now);
  });

  tearDown(() => db.close());

  Future<int> addTask(TaskType type, {int cost = 0, int dailyTarget = 1}) =>
      db.into(db.tasks).insert(TasksCompanion.insert(
            title: type.label,
            type: type,
            difficulty: Difficulty.easy,
            element: Value(type == TaskType.reward ? null : TaskElement.fire),
            cost: Value(cost),
            dailyTarget: Value(dailyTarget),
          ));

  Future<Task> task(int id) =>
      (db.select(db.tasks)..where((t) => t.id.equals(id))).getSingle();

  Future<int> coins() => service.watchCoins().first;

  test('tick daily: cộng xu, streak, đánh dấu xong; không tick lại được',
      () async {
    final id = await addTask(TaskType.daily);
    final log = await service.score(id);

    expect(log.coinsDelta, 10);
    expect(await coins(), 10);
    final t = await task(id);
    expect(t.streak, 1);
    expect(t.completed, isTrue);
    expect(t.value, 1);

    await expectLater(service.score(id), throwsStateError);
  });

  test('bỏ tick hoàn lại chính xác', () async {
    final id = await addTask(TaskType.daily);
    await service.score(id);
    await service.uncheck(id);

    expect(await coins(), 0);
    final t = await task(id);
    expect(t.streak, 0);
    expect(t.completed, isFalse);
    expect(t.value, 0);
    expect(await db.select(db.taskLogs).get(), isEmpty);
  });

  test('thói quen mục tiêu 2 lần/ngày: thưởng giảm dần, lần thứ 3 bị chặn',
      () async {
    final id = await addTask(TaskType.habit, dailyTarget: 2);
    await service.score(id);
    final second = await service.score(id);

    expect(second.coinsDelta, 10); // 10 × 0.9747 = 9.7
    expect(await coins(), 20);
    expect(await service.watchTodayCounts().first, {id: 2});
    await expectLater(service.score(id), throwsStateError);
    expect(await coins(), 20);
  });

  test('thói quen mặc định 1 lần/ngày, sang ngày mới bấm lại được', () async {
    final id = await addTask(TaskType.habit);
    await service.score(id);
    await expectLater(service.score(id), throwsStateError);

    now = DateTime(2026, 11, 4, 0, 1);
    await service.score(id);
    expect(await coins(), 20);
  });

  test('bỏ tick thói quen thì trả lại một lần trong ngày', () async {
    final id = await addTask(TaskType.habit);
    await service.score(id);
    await service.uncheck(id);

    expect(await coins(), 0);
    expect(await service.watchTodayCounts().first, isEmpty);
    await service.score(id);
    expect(await coins(), 10);
  });

  test('thói quen xấu không bị giới hạn số lần', () async {
    final id = await addTask(TaskType.habit);
    for (var i = 0; i < 3; i++) {
      await service.score(id, up: false);
    }
    expect(await service.watchTodayCounts().first, isEmpty);
  });

  test('thói quen xấu: không trừ xu, hoàn tác được', () async {
    final id = await addTask(TaskType.habit);
    final log = await service.score(id, up: false);

    expect(log.kind, LogKind.bad);
    expect(await coins(), 0);
    expect((await task(id)).value, -1);

    await service.undo(log.id);
    expect((await task(id)).value, 0);
  });

  test('mua phần thưởng: thiếu xu thì từ chối, đủ thì trừ, hoàn tác thì trả',
      () async {
    final reward = await addTask(TaskType.reward, cost: 15);
    expect(await service.buyReward(reward), isNull);

    final daily = await addTask(TaskType.daily);
    final todo = await addTask(TaskType.todo);
    await service.score(daily);
    await service.score(todo);
    expect(await coins(), 20);

    final log = await service.buyReward(reward);
    expect(log, isNotNull);
    expect(await coins(), 5);

    await service.undo(log!.id);
    expect(await coins(), 20);
  });

  test('hoàn tác sau khi đã tiêu xu thì ví không âm', () async {
    final daily = await addTask(TaskType.daily);
    final reward = await addTask(TaskType.reward, cost: 10);
    await service.score(daily);
    await service.buyReward(reward);

    await service.uncheck(daily);
    expect(await coins(), 0);
  });

  test('xóa task rồi hoàn tác vẫn trả lại xu', () async {
    final id = await addTask(TaskType.todo);
    final log = await service.score(id);
    await (db.delete(db.tasks)..where((t) => t.id.equals(id))).go();

    await service.undo(log.id);
    expect(await coins(), 0);
  });
}
