import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:linh_thu_ky_luat/app.dart';
import 'package:linh_thu_ky_luat/data/database.dart';
import 'package:linh_thu_ky_luat/data/providers.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    db = AppDatabase(NativeDatabase.memory());
  });

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: const LinhThuApp(),
    ));
    await tester.pumpAndSettle();
  }

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

  testWidgets('thanh điều hướng chuyển được giữa các tab', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.byIcon(Icons.pets_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Linh thú của bạn đang ngủ trong trứng...'),
        findsOneWidget);

    await tearDownApp(tester);
  });
}
