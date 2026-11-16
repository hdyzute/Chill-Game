// Chụp màn trận boss ở vài thời điểm ra ảnh PNG để xem hình mà không cần
// điện thoại. Không chạy cùng `flutter test` (nằm ngoài thư mục test/):
//
//   flutter test tool/battle_preview_test.dart --dart-define=OUT=<thư mục>
//
// Chữ dùng font Roboto đi kèm Flutter SDK (đặt ROBOTO_DIR nếu SDK ở chỗ khác).
import 'dart:io';
import 'dart:ui' as ui;

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linh_thu_ky_luat/core/theme.dart';
import 'package:linh_thu_ky_luat/data/database.dart';
import 'package:linh_thu_ky_luat/data/providers.dart';
import 'package:linh_thu_ky_luat/features/pet/battle_screen.dart';

const out = String.fromEnvironment('OUT');
const robotoDir = String.fromEnvironment(
  'ROBOTO_DIR',
  defaultValue: r'C:\src\flutter\bin\cache\artifacts\material_fonts',
);

Future<void> _loadRoboto() async {
  final loader = FontLoader('Roboto');
  for (final w in ['regular', 'medium', 'bold', 'black']) {
    final bytes = File('$robotoDir/roboto-$w.ttf').readAsBytesSync();
    loader.addFont(Future.value(ByteData.view(bytes.buffer)));
  }
  await loader.load();
}

void main() {
  testWidgets('chụp màn trận boss', (tester) async {
    expect(out, isNotEmpty, reason: 'Thiếu --dart-define=OUT=<thư mục>');
    await tester.runAsync(_loadRoboto);
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);

    final db = AppDatabase(NativeDatabase.memory());
    DateTime clock() => DateTime(2026, 11, 3, 10);
    await db
        .into(db.pets)
        .insert(
          PetsCompanion.insert(
            name: 'Mochi',
            createdAt: DateTime(2026, 10, 1),
            exp: const Value(600),
            branch: const Value(TaskElement.fire),
          ),
        );
    await db
        .into(db.bosses)
        .insert(
          BossesCompanion.insert(
            kind: BossKind.treeDemon,
            startedAt: DateTime(2026, 11, 1, 6),
          ),
        );
    Future<void> log(
      LogKind kind,
      int hour,
      String title, {
      int coins = 0,
      TaskElement? element,
      bool critical = false,
    }) => db
        .into(db.taskLogs)
        .insert(
          TaskLogsCompanion.insert(
            taskId: 1,
            kind: kind,
            title: Value(title),
            coinsDelta: Value(coins),
            element: Value(element),
            critical: Value(critical),
            createdAt: Value(DateTime(2026, 11, 2, hour)),
          ),
        );
    await log(
      LogKind.complete,
      7,
      'Tập thể dục 15 phút',
      coins: 32,
      element: TaskElement.fire,
    );
    await log(
      LogKind.complete,
      9,
      'Đọc sách 20 phút',
      coins: 18,
      element: TaskElement.water,
      critical: true,
    );
    await log(LogKind.missed, 23, 'Ngủ đúng giờ');

    final key = GlobalKey();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          clockProvider.overrideWithValue(clock),
        ],
        child: RepaintBoundary(
          key: key,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            home: Consumer(
              builder: (context, ref, _) {
                final replay = ref.watch(battleReplayProvider);
                return replay == null
                    ? const SizedBox()
                    : BattleScreen(replay: replay);
              },
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    Future<void> shot(String name) async {
      await tester.runAsync(() async {
        final boundary =
            key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: 1);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        Directory(out).createSync(recursive: true);
        File('$out/$name.png').writeAsBytesSync(bytes!.buffer.asUint8List());
      });
    }

    // Mở màn 0,7 s; mỗi đòn 1,1 s, trúng ở 32 %; boss đánh trả 1,3 s.
    // Chụp đều mỗi 150 ms cho tới hết trận, rồi chụp kết quả.
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 150));
      await shot('frame_${i.toString().padLeft(2, '0')}');
    }
    await tester.pumpAndSettle();
    await shot('result');

    await tester.pumpWidget(const SizedBox());
    await tester.pump(Duration.zero);
    await db.close();
  });
}
