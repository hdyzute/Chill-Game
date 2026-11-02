import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:linh_thu_ky_luat/app.dart';

void main() {
  testWidgets('Thanh điều hướng chuyển được giữa các tab', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: LinhThuApp()));

    expect(find.text('Danh sách thói quen và việc cần làm hôm nay sẽ ở đây.'),
        findsOneWidget);

    await tester.tap(find.byIcon(Icons.pets_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Linh thú của bạn đang ngủ trong trứng...'),
        findsOneWidget);
  });
}
