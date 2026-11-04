import 'dart:math';

import 'package:linh_thu_ky_luat/data/notification_scheduler.dart';
import 'package:linh_thu_ky_luat/domain/reminders.dart';

/// Luôn trả 0.5, lớn hơn tỉ lệ bạo kích 3%, nên test không bị ngẫu nhiên.
class NoCritRandom implements Random {
  @override
  double nextDouble() => 0.5;

  @override
  bool nextBool() => throw UnimplementedError();

  @override
  int nextInt(int max) => throw UnimplementedError();
}

/// Ghi lại lịch nhắc thay vì gọi hệ điều hành.
class FakeScheduler implements NotificationScheduler {
  List<ReminderPlan> plans = const [];
  int replaceCount = 0;
  bool permission = true;

  @override
  Future<bool> requestPermission() async => permission;

  @override
  Future<void> replaceAll(List<ReminderPlan> plans) async {
    this.plans = plans;
    replaceCount++;
  }
}
