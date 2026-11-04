import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/providers.dart';
import '../domain/reminders.dart';

/// Đặt lại lịch nhắc với hệ điều hành mỗi khi [reminderPlansProvider] đổi
/// (thêm/sửa task, tick xong, sang ngày mới).
class ReminderSync extends ConsumerStatefulWidget {
  const ReminderSync({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<ReminderSync> createState() => _ReminderSyncState();
}

class _ReminderSyncState extends ConsumerState<ReminderSync> {
  // Chạy lần lượt để hai lần đặt lịch không chen nhau.
  Future<void> _queue = Future.value();

  @override
  void initState() {
    super.initState();
    ref.listenManual<List<ReminderPlan>?>(
      reminderPlansProvider,
      (previous, next) {
        if (next == null || listEquals(previous, next)) return;
        final scheduler = ref.read(notificationSchedulerProvider);
        _queue = _queue.then((_) async {
          try {
            await scheduler.replaceAll(next);
          } catch (e) {
            debugPrint('Không đặt được lịch nhắc: $e');
          }
        });
      },
      fireImmediately: true,
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
