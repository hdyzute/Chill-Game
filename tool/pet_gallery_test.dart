// Vẽ mọi hình linh thú và linh vật ra một ảnh PNG để xem nhanh, không cần
// điện thoại. Không chạy cùng `flutter test` (nằm ngoài thư mục test/):
//
//   flutter test tool/pet_gallery_test.dart --dart-define=OUT=<file .png>
//
// Thêm --dart-define=PETS=<thư mục> để xuất từng linh thú ra PNG nền trong
// suốt (dùng cho ảnh bìa store, xem tool/make_store_images.py).
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linh_thu_ky_luat/data/task_enums.dart';
import 'package:linh_thu_ky_luat/domain/pet.dart';
import 'package:linh_thu_ky_luat/features/pet/pet_painter.dart';

const out = String.fromEnvironment('OUT');
const petsDir = String.fromEnvironment('PETS');
const cell = 220.0;

void main() {
  testWidgets('vẽ bảng hình linh thú', (tester) async {
    expect(
      out.isNotEmpty || petsDir.isNotEmpty,
      isTrue,
      reason: 'Thiếu --dart-define=OUT=<file> hoặc PETS=<thư mục>',
    );
    if (petsDir.isNotEmpty) await _exportPets(tester);
    if (out.isEmpty) return;
    final rows = <List<CustomPainter>>[
      [
        const PetPainter(stage: PetStage.egg),
        for (final item in SpiritItem.values) SpiritItemPainter(item),
      ],
      for (final branch in [null, ...TaskElement.values])
        [
          for (final mood in PetMood.values)
            PetPainter(
              stage: branch == null ? PetStage.baby : PetStage.adult,
              branch: branch,
              mood: mood,
            ),
          if (branch == null)
            const PetPainter(stage: PetStage.baby, blink: true),
        ],
    ];
    final columns = rows.map((r) => r.length).reduce((a, b) => a > b ? a : b);
    tester.view.physicalSize = Size(columns * cell, rows.length * cell);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final key = GlobalKey();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: RepaintBoundary(
          key: key,
          child: Container(
            color: const Color(0xFFFFF4EC),
            child: Column(
              children: [
                for (final row in rows)
                  Row(
                    children: [
                      for (final painter in row)
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: CustomPaint(
                            size: const Size.square(cell - 20),
                            painter: painter,
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.runAsync(() async {
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage();
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      File(out).writeAsBytesSync(bytes!.buffer.asUint8List());
    });
  });
}

/// Từng linh thú, nền trong suốt, 600 × 600.
Future<void> _exportPets(WidgetTester tester) async {
  final pets = {
    'egg': const PetPainter(stage: PetStage.egg, bob: 0.5),
    'baby': const PetPainter(stage: PetStage.baby, mood: PetMood.happy),
    for (final branch in TaskElement.values)
      branch.name: PetPainter(
        stage: PetStage.adult,
        branch: branch,
        mood: PetMood.happy,
      ),
  };
  Directory(petsDir).createSync(recursive: true);
  for (final MapEntry(key: name, value: painter) in pets.entries) {
    await tester.runAsync(() async {
      final recorder = ui.PictureRecorder();
      painter.paint(Canvas(recorder), const Size.square(600));
      final image = await recorder.endRecording().toImage(600, 600);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      File('$petsDir/$name.png').writeAsBytesSync(bytes!.buffer.asUint8List());
    });
  }
}
