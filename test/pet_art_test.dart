import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linh_thu_ky_luat/data/task_enums.dart';
import 'package:linh_thu_ky_luat/domain/pet.dart';
import 'package:linh_thu_ky_luat/features/pet/pet_art.dart';

void main() {
  Future<void> pump(WidgetTester tester, Widget child) => tester.pumpWidget(
      MaterialApp(home: Scaffold(body: Center(child: child))));

  testWidgets('vẽ được mọi giai đoạn, nhánh và tâm trạng', (tester) async {
    await pump(tester, const PetArt(stage: PetStage.egg));
    expect(tester.takeException(), isNull);
    expect(find.bySemanticsLabel('Trứng'), findsOneWidget);

    for (final mood in PetMood.values) {
      await pump(tester, PetArt(stage: PetStage.baby, mood: mood));
      expect(tester.takeException(), isNull);
      expect(find.bySemanticsLabel('Ấu thú, ${mood.label}'), findsOneWidget);
      for (final branch in TaskElement.values) {
        await pump(tester,
            PetArt(stage: PetStage.adult, branch: branch, mood: mood));
        expect(tester.takeException(), isNull);
        expect(
            find.bySemanticsLabel(
                'Trưởng thành hệ ${branch.label}, ${mood.label}'),
            findsOneWidget);
      }
    }
  });

  testWidgets('vẽ được mọi linh vật, giữ cỡ cũ', (tester) async {
    for (final item in SpiritItem.values) {
      await pump(tester, SpiritItemIcon(item));
      expect(tester.takeException(), isNull);
      expect(find.bySemanticsLabel(item.label), findsOneWidget);
      expect(tester.getSize(find.byType(SpiritItemIcon)), const Size(32, 32));
    }
  });
}
