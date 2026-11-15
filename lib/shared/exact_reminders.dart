import 'package:flutter/material.dart';

import '../data/notification_scheduler.dart';

/// Hỏi bật nhắc đúng giờ nếu chưa có quyền. Chưa bật thì Android có thể nhắc
/// trễ tới 1 giờ.
Future<void> askExactReminders(
    BuildContext context, NotificationScheduler scheduler) async {
  if (await scheduler.canScheduleExact() || !context.mounted) return;
  final open = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Nhắc đúng giờ?'),
      content: const Text(
          'Nếu chưa cho phép, Android có thể nhắc trễ tới 1 giờ để tiết kiệm '
          'pin. Bấm "Mở cài đặt" rồi bật "Cho phép đặt chuông báo và lời nhắc" '
          'cho Linh Thú Kỷ Luật.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Để sau'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Mở cài đặt'),
        ),
      ],
    ),
  );
  if (open == true) await scheduler.requestExactPermission();
}
