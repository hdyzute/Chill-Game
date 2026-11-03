import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:linh_thu_ky_luat/app.dart';
import 'package:linh_thu_ky_luat/data/database.dart';
import 'package:linh_thu_ky_luat/data/providers.dart';
import 'package:linh_thu_ky_luat/data/score_service.dart';

import 'helpers.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    db = AppDatabase(NativeDatabase.memory());
  });

  // Thứ 3, 10 giờ sáng: cố định để lịch lặp theo thứ không phụ thuộc ngày chạy.
  DateTime clock() => DateTime(2026, 11, 3, 10);

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        clockProvider.overrideWithValue(clock),
        scoreServiceProvider.overrideWithValue(
            ScoreService(db, random: NoCritRandom(), clock: clock)),
      ],
      child: const LinhThuApp(),
    ));
    await tester.pumpAndSettle();
  }

  Future<void> addTask(String title, TaskType type,
          {int cost = 0, int dailyTarget = 1, int repeatDays = everyDayMask}) =>
      db.into(db.tasks).insert(TasksCompanion.insert(
            title: title,
            type: type,
            difficulty: Difficulty.easy,
            repeatDays: Value(repeatDays),
            element: Value(type == TaskType.reward ? null : TaskElement.fire),
            cost: Value(cost),
            dailyTarget: Value(dailyTarget),
          ));

  String coinsShown(WidgetTester tester) =>
      tester.widget<Text>(find.byKey(const Key('coins'))).data!;

  // Gỡ cây widget, pump một nhịp để Drift hủy stream, rồi mới đóng DB.
  // Đóng trước khi pump thì close() chờ mãi trong fake async.
  Future<void> tearDownApp(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(Duration.zero);
    await db.close();
  }

  testWidgets('tạo task mới thì hiện trong danh sách Hôm nay', (tester) async {
    await pumpApp(tester);
    expect(find.textContaining('Chưa có thói quen nào'), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Tên'), 'Chạy bộ');
    await tester.tap(find.text('Lưu'));
    await tester.pumpAndSettle();

    expect(find.text('Chạy bộ'), findsOneWidget);
    expect(find.text('Hằng ngày'), findsOneWidget);
    expect(find.text('Hỏa · Mỗi ngày · Dễ'), findsOneWidget);

    await tearDownApp(tester);
  });

  testWidgets('không lưu được khi thiếu tên', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lưu'));
    await tester.pumpAndSettle();

    expect(find.text('Nhập tên nhé'), findsOneWidget);

    await tearDownApp(tester);
  });

  testWidgets('tick daily được xu, bấm Hoàn tác thì trả lại', (tester) async {
    await addTask('Chạy bộ', TaskType.daily);
    await pumpApp(tester);
    expect(coinsShown(tester), '0');

    await tester.tap(find.byTooltip('Hoàn thành'));
    await tester.pumpAndSettle();
    expect(coinsShown(tester), '10');
    expect(find.text('+10 xu · chuỗi 1 ngày'), findsOneWidget);
    expect(find.textContaining('Chuỗi 1 ngày'), findsOneWidget);

    await tester.tap(find.text('Hoàn tác'));
    await tester.pumpAndSettle();
    expect(coinsShown(tester), '0');
    expect(find.byTooltip('Hoàn thành'), findsOneWidget);

    await tearDownApp(tester);
  });

  testWidgets('thói quen 2 lần/ngày: vòng tiến độ rồi thành dấu tick',
      (tester) async {
    await addTask('Uống nước', TaskType.habit, dailyTarget: 2);
    await pumpApp(tester);
    expect(find.textContaining('0/2 lần hôm nay'), findsOneWidget);

    await tester.tap(find.byTooltip('Hoàn thành'));
    await tester.pumpAndSettle();
    expect(find.textContaining('1/2 lần hôm nay'), findsOneWidget);
    expect(find.text('+10 xu · 1/2 hôm nay'), findsOneWidget);

    await tester.tap(find.byTooltip('Hoàn thành'));
    await tester.pumpAndSettle();
    expect(find.textContaining('2/2 lần hôm nay'), findsOneWidget);
    expect(find.byTooltip('Bỏ tick'), findsOneWidget);
    expect(coinsShown(tester), '20');

    // Đã đủ: bấm lần nữa là bỏ tick lần gần nhất, không cộng thêm xu.
    await tester.tap(find.byTooltip('Bỏ tick'));
    await tester.pumpAndSettle();
    expect(find.textContaining('1/2 lần hôm nay'), findsOneWidget);
    expect(coinsShown(tester), '10');

    await tearDownApp(tester);
  });

  testWidgets('không đủ xu thì không mua được phần thưởng', (tester) async {
    await addTask('Xem phim', TaskType.reward, cost: 30);
    await pumpApp(tester);

    await tester.tap(find.text('30'));
    await tester.pumpAndSettle();
    expect(find.text('Chưa đủ xu: cần 30, bạn đang có 0'), findsOneWidget);
    expect(coinsShown(tester), '0');

    await tearDownApp(tester);
  });

  testWidgets('daily không phải làm hôm nay thì ghi "Hôm nay nghỉ"',
      (tester) async {
    await addTask('Tập gym', TaskType.daily, repeatDays: 0x15); // T2, T4, T6
    await addTask('Đọc sách', TaskType.daily);
    await pumpApp(tester);

    expect(find.text('Hôm nay nghỉ · Hỏa · T2, T4, T6 · Dễ'), findsOneWidget);
    expect(find.text('Hỏa · Mỗi ngày · Dễ'), findsOneWidget);

    await tearDownApp(tester);
  });

  testWidgets('cài đặt: đổi giờ bắt đầu ngày và bật bế quan', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('dayStartHour')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('4:00').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(find.textContaining('Đang bế quan'), findsOneWidget);

    final profile = await db.select(db.profiles).getSingle();
    expect(profile.dayStartHour, 4);
    expect(profile.resting, isTrue);

    await tearDownApp(tester);
  });

  testWidgets('thanh điều hướng chuyển được giữa các tab', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.byIcon(Icons.pets_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Linh thú của bạn đang ngủ trong trứng...'),
        findsOneWidget);

    await tearDownApp(tester);
  });
}
