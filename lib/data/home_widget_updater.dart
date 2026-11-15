import 'package:home_widget/home_widget.dart';

import '../domain/widget_snapshot.dart';

/// Gửi nội dung sang widget màn hình chính. Test dùng bản giả.
abstract class HomeWidgetUpdater {
  Future<void> update(WidgetSnapshot snapshot);
}

class AndroidHomeWidgetUpdater implements HomeWidgetUpdater {
  /// Tên lớp AppWidgetProvider trong android/app (cùng package với app).
  static const providerName = 'TodayWidgetProvider';

  @override
  Future<void> update(WidgetSnapshot snapshot) async {
    for (final MapEntry(:key, :value) in snapshot.toData().entries) {
      await HomeWidget.saveWidgetData<String>(key, value);
    }
    await HomeWidget.updateWidget(androidName: providerName);
  }
}
