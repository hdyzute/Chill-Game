import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linh_thu_ky_luat/data/database.dart';
import 'package:linh_thu_ky_luat/data/profile_repository.dart';
import 'package:linh_thu_ky_luat/data/score_service.dart';
import 'package:linh_thu_ky_luat/domain/drops.dart';
import 'package:linh_thu_ky_luat/domain/growth.dart';

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
    expect(await service.todayCounts(), {id: 2});
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

  test('giờ bắt đầu ngày 4:00: 3 giờ sáng vẫn tính là hôm trước', () async {
    await ProfileRepository(db).setDayStartHour(4);
    final id = await addTask(TaskType.habit);

    now = DateTime(2026, 11, 3, 23);
    await service.score(id);

    now = DateTime(2026, 11, 4, 3, 59);
    await expectLater(service.score(id), throwsStateError);

    now = DateTime(2026, 11, 4, 4);
    await service.score(id);
    expect(await coins(), 20);
  });

  test('bỏ tick thói quen thì trả lại một lần trong ngày', () async {
    final id = await addTask(TaskType.habit);
    await service.score(id);
    await service.uncheck(id);

    expect(await coins(), 0);
    expect(await service.todayCounts(), isEmpty);
    await service.score(id);
    expect(await coins(), 10);
  });

  test('thói quen xấu không bị giới hạn số lần', () async {
    final id = await addTask(TaskType.habit);
    for (var i = 0; i < 3; i++) {
      await service.score(id, up: false);
    }
    expect(await service.todayCounts(), isEmpty);
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

  test('nhật ký giữ tên và hệ lúc chấm, dù task bị đổi tên hay xóa sau đó',
      () async {
    final id = await addTask(TaskType.habit);
    final first = await service.score(id);
    await (db.update(db.tasks)..where((t) => t.id.equals(id))).write(
        const TasksCompanion(
            title: Value('Uống nước'), element: Value(TaskElement.wood)));
    now = now.add(const Duration(days: 1));
    final second = await service.score(id);
    await (db.delete(db.tasks)..where((t) => t.id.equals(id))).go();

    final logs = await db.select(db.taskLogs).get();
    expect(logs.map((l) => l.id), [first.id, second.id]);
    expect(logs.map((l) => l.title), ['Thói quen', 'Uống nước']);
    expect(logs.map((l) => l.element), [TaskElement.fire, TaskElement.wood]);
  });

  test('xóa task rồi hoàn tác vẫn trả lại xu', () async {
    final id = await addTask(TaskType.todo);
    final log = await service.score(id);
    await (db.delete(db.tasks)..where((t) => t.id.equals(id))).go();

    await service.undo(log.id);
    expect(await coins(), 0);
  });

  group('rơi linh vật', () {
    Future<Map<SpiritItem, int>> bag() => service.watchInventory().first;
    Future<int> droppedToday() => service
        .watchDropsSince(DateTime(now.year, now.month, now.day))
        .first;

    test('việc tốt rơi linh vật theo hệ, hoàn tác lấy lại đúng món', () async {
      // Không bạo kích, rơi đồ, không quý.
      service = ScoreService(db,
          random: SequenceRandom([0.5, 0.1, 0.9]), clock: () => now);
      final id = await addTask(TaskType.daily);
      final log = await service.score(id);

      expect(log.dropItem, SpiritItem.fireCommon);
      expect(log.dropCount, 1);
      expect(await bag(), {SpiritItem.fireCommon: 1});
      expect(await droppedToday(), 1);

      await service.undo(log.id);
      expect(await bag(), isEmpty);
      expect(await droppedToday(), 0);
    });

    test('bạo kích rơi 2 món quý', () async {
      service = ScoreService(db,
          random: SequenceRandom([0.01, 0.1, 0.05]), clock: () => now);
      final log = await service.score(await addTask(TaskType.todo));

      expect(log.critical, isTrue);
      expect(log.dropItem, SpiritItem.fireRare);
      expect(log.dropCount, 2);
      expect(await bag(), {SpiritItem.fireRare: 2});
    });

    test('mỗi ngày tối đa 5 món, sang ngày mới nhặt tiếp', () async {
      service = ScoreService(db,
          random: SequenceRandom([0.5, 0.1, 0.9]), clock: () => now);
      final id = await addTask(TaskType.habit, dailyTarget: 7);
      final logs = [for (var i = 0; i < 7; i++) await service.score(id)];

      expect(logs.map((l) => l.dropCount), [1, 1, 1, 1, 1, 0, 0]);
      expect(await bag(), {SpiritItem.fireCommon: Drops.dailyCap});

      now = now.add(const Duration(days: 1));
      expect((await service.score(id)).dropCount, 1);
    });

    test('việc xấu không rơi gì', () async {
      service = ScoreService(db,
          random: SequenceRandom([0.5, 0.1, 0.9]), clock: () => now);
      final id = await db.into(db.tasks).insert(TasksCompanion.insert(
            title: 'Thức khuya',
            type: TaskType.habit,
            difficulty: Difficulty.hard,
            element: const Value(TaskElement.wood),
            habitUp: const Value(false),
            habitDown: const Value(true),
          ));
      final log = await service.score(id, up: false);
      expect(log.dropItem, isNull);
      expect(await bag(), isEmpty);
    });
  });

  group('hấp thụ linh vật', () {
    Future<Pet> pet() => db.select(db.pets).getSingle();
    Future<Map<SpiritItem, int>> bag() => service.watchInventory().first;

    setUp(() async {
      await db.into(db.pets).insert(
          PetsCompanion.insert(name: 'Mochi', createdAt: DateTime(2026, 11)));
      // Không bạo kích, rơi đồ, món quý.
      service = ScoreService(db,
          random: SequenceRandom([0.5, 0.1, 0.05]), clock: () => now);
    });

    test('hấp thụ: bớt một món, +EXP và +điểm đúng hệ', () async {
      await service.score(await addTask(TaskType.todo));
      expect(await bag(), {SpiritItem.fireRare: 1});

      final after = await service.absorb(SpiritItem.fireRare);
      expect(after.exp, Growth.rareExp);
      expect(after.firePoints, Growth.rarePoints);
      expect(after.waterPoints, 0);
      expect(await bag(), isEmpty);
      await expectLater(
          service.absorb(SpiritItem.fireRare), throwsStateError);
    });

    test('bỏ tick sau khi đã hấp thụ thì trừ lại đúng EXP và điểm', () async {
      final id = await addTask(TaskType.daily);
      await service.score(id);
      await service.absorb(SpiritItem.fireRare);

      await service.uncheck(id);
      final p = await pet();
      expect(p.exp, 0);
      expect(p.firePoints, 0);
      expect(await bag(), isEmpty);

      // Tick lại: rơi món mới, nhưng tổng không hơn một lần tick.
      await service.score(id);
      await service.absorb(SpiritItem.fireRare);
      expect((await pet()).exp, Growth.rareExp);
    });

    test('chưa có linh thú thì không hấp thụ được', () async {
      await db.delete(db.pets).go();
      await service.score(await addTask(TaskType.todo));
      await expectLater(
          service.absorb(SpiritItem.fireRare), throwsStateError);
      expect(await bag(), {SpiritItem.fireRare: 1});
    });
  });
}
