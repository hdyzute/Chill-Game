import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../domain/reminders.dart';

/// Đặt thông báo nhắc với hệ điều hành. Test dùng bản giả.
abstract class NotificationScheduler {
  /// Hỏi quyền gửi thông báo (Android 13+). Trả về true nếu được phép.
  Future<bool> requestPermission();

  /// Xóa mọi lịch nhắc chưa tới giờ và đặt lại theo [plans].
  Future<void> replaceAll(List<ReminderPlan> plans);
}

class LocalNotificationScheduler implements NotificationScheduler {
  final _plugin = FlutterLocalNotificationsPlugin();
  Future<void>? _ready;

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'reminders',
      'Nhắc nhở',
      channelDescription: 'Nhắc làm thói quen và việc hằng ngày',
      importance: Importance.high,
      priority: Priority.high,
      icon: 'ic_notification',
    ),
  );

  Future<void> _init() => _ready ??= () async {
        tzdata.initializeTimeZones();
        final zone = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(zone.identifier));
        await _plugin.initialize(
          settings: const InitializationSettings(
            android: AndroidInitializationSettings('ic_notification'),
          ),
        );
      }();

  AndroidFlutterLocalNotificationsPlugin? get _android =>
      _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  @override
  Future<bool> requestPermission() async {
    await _init();
    return await _android?.requestNotificationsPermission() ?? true;
  }

  @override
  Future<void> replaceAll(List<ReminderPlan> plans) async {
    await _init();
    // Chỉ xóa lịch chưa tới giờ, không gỡ thông báo đang hiện.
    await _plugin.cancelAllPendingNotifications();
    for (final plan in plans) {
      await _plugin.zonedSchedule(
        id: plan.id,
        title: plan.title,
        body: plan.body,
        scheduledDate: tz.TZDateTime.from(plan.first, tz.local),
        notificationDetails: _details,
        // Không chính xác tuyệt đối (có thể trễ vài phút) nhưng không cần
        // quyền exact alarm, vốn bị Google Play hạn chế.
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: plan.weekly
            ? DateTimeComponents.dayOfWeekAndTime
            : DateTimeComponents.time,
      );
    }
  }
}
