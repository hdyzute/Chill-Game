// Tạo database mẫu để xem tab Lịch sử trên điện thoại. Không chạy cùng
// `flutter test` (nằm ngoài thư mục test/). Cách dùng:
//
//   flutter test tool/sample_data_test.dart --dart-define=OUT=<file .sqlite>
//
// Script đi qua từng ngày bằng chính ScoreService và RolloverService của app,
// nên xu, chuỗi và nhật ký khớp nhau như dùng thật. Có cả linh thú (hấp thụ
// linh vật rồi tiến hóa), điểm danh, boss và Linh điền, đủ để chụp ảnh store.
// Ngày TODAY có vài việc đã làm từ sáng và hai ô ruộng đã gieo. Ảnh store chụp
// với TODAY là ngày chụp, để Linh điền và "hôm nay" khớp đồng hồ điện thoại.
import 'dart:io';
import 'dart:math';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linh_thu_ky_luat/data/boss_repository.dart';
import 'package:linh_thu_ky_luat/data/database.dart';
import 'package:linh_thu_ky_luat/data/pet_repository.dart';
import 'package:linh_thu_ky_luat/data/rollover_service.dart';
import 'package:linh_thu_ky_luat/data/score_service.dart';
import 'package:linh_thu_ky_luat/domain/day.dart';
import 'package:linh_thu_ky_luat/domain/growth.dart';

const out = String.fromEnvironment('OUT');
const firstDay = String.fromEnvironment('FROM', defaultValue: '2026-10-01');
const today = String.fromEnvironment('TODAY', defaultValue: '2026-11-04');

void main() {
  test('tạo database mẫu', () async {
    expect(out, isNotEmpty, reason: 'Thiếu --dart-define=OUT=<file>');
    final file = File(out);
    if (file.existsSync()) file.deleteSync();

    var now = DateTime.parse(firstDay).subtract(const Duration(hours: 12));
    final db = AppDatabase(NativeDatabase(file));
    final score = ScoreService(db, random: Random(7), clock: () => now);
    final rollover = RolloverService(db, clock: () => now);
    final pets = PetRepository(db, clock: () => now);
    final bosses = BossRepository(db, clock: () => now);
    final rng = Random(42);

    Future<int> add(
      String title,
      TaskType type,
      Difficulty difficulty, {
      TaskElement? element,
      bool up = true,
      bool down = false,
      int target = 1,
      int repeatDays = everyDayMask,
      int cost = 0,
      int? reminder,
    }) => db
        .into(db.tasks)
        .insert(
          TasksCompanion.insert(
            title: title,
            type: type,
            difficulty: difficulty,
            element: Value(element),
            habitUp: Value(up),
            habitDown: Value(down),
            dailyTarget: Value(target),
            repeatDays: Value(repeatDays),
            cost: Value(cost),
            reminderMinutes: Value(reminder),
            createdAt: Value(now),
          ),
        );

    // Ba task người dùng có trước khi mất dữ liệu, rồi vài task mẫu.
    final breakfast = await add(
      'Ăn sáng',
      TaskType.habit,
      Difficulty.medium,
      element: TaskElement.fire,
    );
    final water = await add(
      'Uống nước',
      TaskType.habit,
      Difficulty.easy,
      element: TaskElement.fire,
      target: 3,
    );
    final sleep = await add(
      'Ngủ đúng giờ',
      TaskType.daily,
      Difficulty.easy,
      element: TaskElement.fire,
    );
    final reading = await add(
      'Đọc sách 20 phút',
      TaskType.daily,
      Difficulty.medium,
      element: TaskElement.water,
      repeatDays: 0x1f,
    ); // T2–T6
    final meditate = await add(
      'Thiền 10 phút',
      TaskType.habit,
      Difficulty.easy,
      element: TaskElement.wood,
    );
    final phone = await add(
      'Lướt điện thoại khuya',
      TaskType.habit,
      Difficulty.easy,
      element: TaskElement.wood,
      up: false,
      down: true,
    );
    final movie = await add(
      'Xem 1 tập phim',
      TaskType.reward,
      Difficulty.easy,
      cost: 40,
    );
    final exercise = await add(
      'Tập thể dục 15 phút',
      TaskType.daily,
      Difficulty.hard,
      element: TaskElement.wood,
      reminder: 6 * 60 + 30,
    );
    await add(
      'Dọn phòng',
      TaskType.todo,
      Difficulty.medium,
      element: TaskElement.water,
    );
    await add('Trà sữa cuối tuần', TaskType.reward, Difficulty.easy, cost: 60);
    await pets.create('Mochi');

    /// Cho linh thú hấp thụ hết túi, chừa lại [keep] món mỗi loại.
    Future<void> absorbAll({int keep = 0}) async {
      final bag = await score.watchInventory().first;
      for (final MapEntry(key: item, value: count) in bag.entries) {
        for (var i = keep; i < count; i++) {
          await score.absorb(item);
        }
      }
    }

    /// Nhận thưởng boss nếu đã thắng, rồi khiêu chiến con tiếp theo.
    Future<void> fightBoss() async {
      try {
        await score.claimBoss();
      } on StateError {
        return;
      }
      await bosses.challengeNext();
    }

    await rollover.run(); // ghi mốc ngày đầu
    final end = DateTime.parse(today);
    final days = daysBetween(DateTime.parse(firstDay), end);

    for (var d = 0; d < days; d++) {
      final date = addDays(DateTime.parse(firstDay), d);
      Future<void> at(int hour, int minute, Future<void> Function() action) {
        now = DateTime(date.year, date.month, date.day, hour, minute);
        return action();
      }

      // Tuần cuối làm đều để có chuỗi ngày đẹp.
      final lastWeek = d >= days - 7;
      bool chance(double p) =>
          lastWeek ? rng.nextDouble() < 0.9 : rng.nextDouble() < p;

      await at(0, 5, () => rollover.run());
      if (d == days - 12) await at(0, 10, () => bosses.challengeNext());
      if (d > days - 12) await at(0, 10, fightBoss);
      if (chance(0.85)) await at(7, 0, () => score.checkIn().then((_) {}));
      if (chance(0.8)) {
        await at(6, 30 + rng.nextInt(20), () => score.score(exercise));
      }
      if (chance(0.8)) {
        await at(7, 10 + rng.nextInt(40), () => score.score(breakfast));
      }
      for (final hour in [9, 13, 16]) {
        if (chance(0.6)) {
          await at(hour, rng.nextInt(60), () => score.score(water));
        }
      }
      if (isDueOn(0x1f, date) && chance(0.7)) {
        await at(20, rng.nextInt(50), () => score.score(reading));
      }
      if (chance(0.45)) {
        await at(21, rng.nextInt(30), () => score.score(meditate));
      }
      if (rng.nextDouble() < 0.25) {
        await at(23, 10 + rng.nextInt(40), () => score.score(phone, up: false));
      }
      if (chance(0.75)) await at(22, 30, () => score.score(sleep));
      if (date.weekday == DateTime.saturday) {
        await at(19, 0, () => score.buyReward(movie));
      }
      await at(22, 50, () => absorbAll(keep: d >= days - 3 ? 1 : 0));
    }

    now = DateTime(end.year, end.month, end.day, 0, 5);
    await rollover.run();

    // Tiến hóa theo hệ dẫn đầu khi đủ cấp.
    final pet = (await db.select(db.pets).get()).single;
    final branch = Growth.leadingElement(pet.points);
    if (pet.level >= Growth.evolveLevel && branch != null) {
      await pets.evolve(pet.id, branch);
    }

    // Hôm nay: vài việc đã làm, hai ô ruộng đã gieo, chưa điểm danh.
    Future<void> todayAt(int hour, int minute, Future<void> Function() action) {
      now = DateTime(end.year, end.month, end.day, hour, minute);
      return action();
    }

    await todayAt(6, 40, () => score.score(exercise));
    await todayAt(7, 15, () => score.score(breakfast));
    await todayAt(9, 0, () => score.score(water));
    await todayAt(9, 5, () => score.plant(0, TaskElement.fire));
    await todayAt(13, 20, () => score.score(water));
    await todayAt(19, 30, () => score.plant(1, TaskElement.water));

    final finalPet = (await db.select(db.pets).get()).single;
    // ignore: avoid_print
    print(
      'Linh thú ${finalPet.name}: cấp ${finalPet.level}, '
      'nhánh ${finalPet.branch?.label ?? "chưa tiến hóa"}, '
      'túi ${await score.watchInventory().first}',
    );
    // ignore: avoid_print
    final bossNames = [
      for (final b in await db.select(db.bosses).get())
        '${b.kind.label}${b.claimedAt == null ? ' (đang đánh)' : ''}',
    ];
    // ignore: avoid_print
    print('Boss: ${bossNames.join(', ')}');
    final coins = await score.watchCoins().first;
    final logs = await db.select(db.taskLogs).get();
    final tasks = await db.select(db.tasks).get();
    // ignore: avoid_print
    print(
      'Đã tạo ${tasks.length} task, ${logs.length} dòng nhật ký, '
      '$coins xu → $out',
    );
    for (final t in tasks.where((t) => t.type == TaskType.daily)) {
      // ignore: avoid_print
      print('  ${t.title}: chuỗi ${t.streak}');
    }
    await db.close();
  });
}
