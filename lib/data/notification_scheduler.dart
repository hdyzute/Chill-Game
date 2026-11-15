import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../domain/reminders.dart';

/// Đặt thông báo nhắc với hệ điều hành. Test dùng bản giả.
abstract class NotificationScheduler {
  /// Hỏi quyền gửi thông báo (Android 13+). Trả về true nếu được phép.
  Future<bool> requestPermission();

  /// Có được đặt nhắc đúng giờ không (quyền "Báo thức và lời nhắc").
  /// Không có thì Android có thể nhắc trễ tới 1 giờ.
  Future<bool> canScheduleExact();

  /// Mở màn hình hệ thống để người dùng bật nhắc đúng giờ.
  Future<void> requestExactPermission();

  /// Mở trang thông tin của app, nơi bật "Tự khởi chạy" và bỏ giới hạn pin.
  Future<void> openAppSettings();

  /// Xóa mọi lịch nhắc chưa tới giờ và đặt lại theo [plans]. Đặt đúng giờ
  /// nếu được phép, không thì đặt kiểu không chính xác.
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

  static const _system = MethodChannel('linh_thu/system');

  @override
  Future<bool> canScheduleExact() async {
    await _init();
    return await _android?.canScheduleExactNotifications() ?? true;
  }

  @override
  Future<void> requestExactPermission() async {
    await _init();
    await _android?.requestExactAlarmsPermission();
  }

  @override
  Future<void> openAppSettings() => _system.invokeMethod('openAppSettings');

  @override
  Future<void> replaceAll(List<ReminderPlan> plans) async {
    await _init();
    final mode = await canScheduleExact()
        ? AndroidScheduleMode.exactAllowWhileIdle
        // Không có quyền thì Android gom lịch để tiết kiệm pin: nhắc có thể
        // trễ tới 1 giờ.
        : AndroidScheduleMode.inexactAllowWhileIdle;
    // Chỉ xóa lịch chưa tới giờ, không gỡ thông báo đang hiện.
    await _plugin.cancelAllPendingNotifications();
    for (final plan in plans) {
      await _plugin.zonedSchedule(
        id: plan.id,
        title: plan.title,
        body: plan.body,
        scheduledDate: tz.TZDateTime.from(plan.first, tz.local),
        notificationDetails: _details,
        androidScheduleMode: mode,
        matchDateTimeComponents: plan.weekly
            ? DateTimeComponents.dayOfWeekAndTime
            : DateTimeComponents.time,
      );
    }
  }
}
