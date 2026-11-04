import 'package:drift/drift.dart' hide isNull, isNotNull;
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
  late FakeScheduler scheduler;

  setUp(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    db = AppDatabase(NativeDatabase.memory());
    scheduler = FakeScheduler();
  });

  // Thứ 3, 10 giờ sáng: cố định để lịch lặp theo thứ không phụ thuộc ngày chạy.
  DateTime clock() => DateTime(2026, 11, 3, 10);

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        clockProvider.overrideWithValue(clock),
        notificationSchedulerProvider.overrideWithValue(scheduler),
        scoreServiceProvider.overrideWithValue(
            ScoreService(db, random: NoCritRandom(), clock: clock)),
      ],
      child: const LinhThuApp(),
    ));
    await tester.pumpAndSettle();
  }

  Future<void> addTask(String title, TaskType type,
          {int cost = 0,
          Difficulty difficulty = Difficulty.easy,
          int dailyTarget = 1,
          int repeatDays = everyDayMask,
          int? reminderMinutes}) =>
      db.into(db.tasks).insert(TasksCompanion.insert(
            title: title,
            type: type,
            difficulty: difficulty,
            repeatDays: Value(repeatDays),
            reminderMinutes: Value(reminderMinutes),
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
    expect(find.byTooltip('Bớt một lần'), findsNothing);

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

    // Chưa đủ thì vòng tròn chỉ cộng: nút "Bớt một lần" đưa được về 0.
    await tester.tap(find.byTooltip('Bớt một lần'));
    await tester.pumpAndSettle();
    expect(find.textContaining('0/2 lần hôm nay'), findsOneWidget);
    expect(coinsShown(tester), '0');
    expect(find.byTooltip('Bớt một lần'), findsNothing);

    await tearDownApp(tester);
  });

  testWidgets('form cuộn được tới mục cuối, không bị thanh điều hướng che',
      (tester) async {
    // Điện thoại có thanh 3 nút cao 48dp, app vẽ tràn xuống dưới nó.
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    tester.view.padding = const FakeViewPadding(bottom: 48 * 2.75);
    tester.view.viewPadding = const FakeViewPadding(bottom: 48 * 2.75);
    addTearDown(tester.view.reset);
    await pumpApp(tester);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Thói quen'));
    await tester.pumpAndSettle();
    // Ẩn bàn phím (tự mở khi tạo mới) rồi cuộn hết cỡ.
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -2000));
    await tester.pumpAndSettle();

    final screenBottom = 2400 / 2.75;
    final navBarTop = screenBottom - 48;
    expect(tester.getRect(find.text('Khó')).bottom, lessThan(navBarTop));

    await tearDownApp(tester);
  });

  testWidgets('xoay ngang: thanh điều hướng bên trái không che nội dung',
      (tester) async {
    // Khi ngang, thanh 3 nút (48dp) nằm ở cạnh trái màn hình.
    tester.view.physicalSize = const Size(2400, 1080);
    tester.view.devicePixelRatio = 2.75;
    tester.view.padding = const FakeViewPadding(left: 48 * 2.75);
    tester.view.viewPadding = const FakeViewPadding(left: 48 * 2.75);
    addTearDown(tester.view.reset);
    await addTask('Chạy bộ', TaskType.habit);
    await pumpApp(tester);

    expect(tester.getRect(find.text('Thói quen')).left, greaterThanOrEqualTo(48));
    expect(tester.getRect(find.byType(Card).first).left, greaterThanOrEqualTo(48));

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    expect(tester.getRect(find.byType(TextFormField).first).left,
        greaterThanOrEqualTo(48));

    Navigator.of(tester.element(find.text('Tạo mới'))).pop();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lịch sử'));
    await tester.pumpAndSettle();
    expect(tester.getRect(find.byType(Card).first).left, greaterThanOrEqualTo(48));

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

  testWidgets('đặt lịch nhắc khi mở app, tick xong thì dời nhắc hôm nay',
      (tester) async {
    // Đồng hồ cố định Thứ 3 10:00, nhắc lúc 21:00.
    await addTask('Đọc sách', TaskType.daily, reminderMinutes: 21 * 60);
    await pumpApp(tester);

    expect(scheduler.plans, hasLength(7));
    expect(scheduler.plans.map((p) => p.first),
        contains(DateTime(2026, 11, 3, 21)));
    expect(find.textContaining('Nhắc 21:00'), findsOneWidget);

    await tester.tap(find.byTooltip('Hoàn thành'));
    await tester.pumpAndSettle();
    expect(scheduler.plans.map((p) => p.first),
        isNot(contains(DateTime(2026, 11, 3, 21))));
    expect(scheduler.plans.map((p) => p.first),
        contains(DateTime(2026, 11, 10, 21)));

    await tearDownApp(tester);
  });

  testWidgets(
      'tab Lịch sử: lịch tháng, chuỗi ngày, chi tiết ngày, giữ tên task đã xóa',
      (tester) async {
    // Cỡ màn hình điện thoại thật, để lịch và chi tiết ngày cùng vừa màn hình.
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    Future<void> addLog(DateTime at, String title, int coins) =>
        db.into(db.taskLogs).insert(TaskLogsCompanion.insert(
              taskId: 99,
              kind: LogKind.complete,
              coinsDelta: Value(coins),
              createdAt: Value(at),
              title: Value(title),
              element: const Value(TaskElement.water),
            ));
    await addTask('Chạy bộ', TaskType.daily);
    await addLog(DateTime(2026, 11, 2, 21), 'Đọc sách', 8);
    await addLog(DateTime(2026, 10, 15, 9), 'Thiền', 5);
    await pumpApp(tester);

    await tester.tap(find.byTooltip('Hoàn thành'));
    await tester.pumpAndSettle();
    await db.delete(db.tasks).go();
    await tester.tap(find.byIcon(Icons.calendar_month_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Tháng 11, 2026'), findsOneWidget);
    expect(
        find.descendant(
            of: find.byKey(const Key('streak')), matching: find.text('2')),
        findsOneWidget);
    expect(
        find.descendant(
            of: find.byKey(const Key('month-coins')),
            matching: find.text('18')),
        findsOneWidget); // 10 + 8
    expect(find.text('Hỏa 1'), findsOneWidget);
    expect(find.text('Thủy 1'), findsOneWidget);
    // Hôm nay được chọn sẵn; task đã xóa vẫn hiện đúng tên.
    expect(find.text('Thứ Ba, 3/11 · 1 việc tốt'), findsOneWidget);
    expect(find.text('Chạy bộ'), findsOneWidget);
    expect(find.text('+10 xu'), findsOneWidget);

    await tester.tap(find.byKey(const Key('day-2')));
    await tester.pumpAndSettle();
    expect(find.text('Thứ Hai, 2/11 · 1 việc tốt'), findsOneWidget);
    expect(find.text('Đọc sách'), findsOneWidget);
    expect(find.text('21:00'), findsOneWidget);

    await tester.tap(find.byKey(const Key('day-1')));
    await tester.pumpAndSettle();
    expect(find.text('Ngày này chưa có hoạt động nào.'), findsOneWidget);

    await tester.tap(find.byTooltip('Tháng trước'));
    await tester.pumpAndSettle();
    expect(find.text('Tháng 10, 2026'), findsOneWidget);
    expect(find.text('Chọn một ngày để xem chi tiết.'), findsOneWidget);
    await tester.tap(find.byKey(const Key('day-15')));
    await tester.pumpAndSettle();
    expect(find.text('Thiền'), findsOneWidget);

    await tester.tap(find.byTooltip('Tháng sau'));
    await tester.pumpAndSettle();
    expect(find.text('Tháng 11, 2026'), findsOneWidget);
    final next = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.chevron_right));
    expect(next.onPressed, isNull);

    await tearDownApp(tester);
  });

  testWidgets('thanh điều hướng chuyển được giữa các tab', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.byIcon(Icons.pets_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Khế ước linh thú'), findsOneWidget);

    await tearDownApp(tester);
  });

  testWidgets('ký khế ước rồi làm việc tốt đầu tiên thì trứng nở',
      (tester) async {
    await addTask('Uống nước', TaskType.habit);
    await pumpApp(tester);
    await tester.tap(find.byIcon(Icons.pets_outlined));
    await tester.pumpAndSettle();

    final sign = find.widgetWithText(FilledButton, 'Ký khế ước');
    expect(tester.widget<FilledButton>(sign).onPressed, isNull);
    await tester.enterText(find.byType(TextField), '  Mochi ');
    await tester.pump();
    await tester.ensureVisible(sign);
    await tester.pumpAndSettle();
    await tester.tap(sign);
    await tester.pumpAndSettle();

    expect(find.text('Mochi'), findsOneWidget);
    expect(find.text('Trứng · Bên nhau 1 ngày'), findsOneWidget);
    expect(find.text('Còn 1 ngày có việc tốt nữa là nở'), findsOneWidget);
    expect(find.textContaining('nằm im'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.check_circle_outline));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Hoàn thành'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.pets_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Ấu thú · Bên nhau 1 ngày'), findsOneWidget);
    expect(find.byKey(const Key('hatch-progress')), findsNothing);
    expect(find.text('Mochi vui vẻ quấn quýt bên bạn.'), findsOneWidget);
    expect(await db.select(db.pets).get(), hasLength(1));

    await tearDownApp(tester);
  });

  testWidgets('ngày nở là ngày có việc tốt đầu tiên, đổi tên được',
      (tester) async {
    await db.into(db.pets).insert(PetsCompanion.insert(
        name: 'Mochi', createdAt: DateTime(2026, 10, 31, 20)));
    for (final day in [31, 1, 2]) {
      await db.into(db.taskLogs).insert(TaskLogsCompanion.insert(
            taskId: 1,
            kind: LogKind.complete,
            createdAt: Value(DateTime(2026, day == 31 ? 10 : 11, day, 9)),
          ));
    }
    await pumpApp(tester);
    await tester.tap(find.byIcon(Icons.pets_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Ấu thú · Bên nhau 4 ngày'), findsOneWidget);
    expect(find.textContaining('31/10'), findsOneWidget);
    expect(find.byKey(const Key('hatch-progress')), findsNothing);
    expect(find.textContaining('đang chờ việc tốt'), findsOneWidget);

    await tester.tap(find.byTooltip('Đổi tên'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Bánh Bao');
    await tester.tap(find.text('Lưu'));
    await tester.pumpAndSettle();

    expect(find.text('Bánh Bao'), findsOneWidget);
    expect((await db.select(db.pets).getSingle()).name, 'Bánh Bao');

    await tearDownApp(tester);
  });

  testWidgets('làm việc khó rơi linh vật: báo trong thông báo và vào túi',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    await addTask('Chạy bộ', TaskType.daily, difficulty: Difficulty.hard);
    await db.into(db.pets).insert(PetsCompanion.insert(
        name: 'Mochi', createdAt: DateTime(2026, 11, 1, 20)));
    await pumpApp(tester);

    await tester.tap(find.byTooltip('Hoàn thành'));
    await tester.pumpAndSettle();
    expect(find.textContaining('nhặt được Hỏa Linh Quả'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.pets_outlined));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
        find.byKey(const Key('drops-today')), 200,
        scrollable: find.byType(Scrollable).last);
    expect(tester.widget<Text>(find.byKey(const Key('drops-today'))).data,
        'Hôm nay 1/5');
    expect(find.text('Hỏa Linh Quả'), findsOneWidget);
    expect(tester.widget<Text>(find.byKey(const Key('item-fireCommon'))).data,
        '×1');

    await tearDownApp(tester);
  });
}
