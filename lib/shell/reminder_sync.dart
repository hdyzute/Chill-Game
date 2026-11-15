import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/providers.dart';
import '../domain/reminders.dart';

/// Đặt lại lịch nhắc với hệ điều hành mỗi khi [reminderPlansProvider] đổi
/// (thêm/sửa task, tick xong, sang ngày mới), và mỗi lần app trở lại màn
/// hình: để áp dụng quyền nhắc đúng giờ vừa bật, và đặt lại lịch mà Xiaomi
/// hay các máy tiết kiệm pin đã xóa khi tắt app.
class ReminderSync extends ConsumerStatefulWidget {
  const ReminderSync({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<ReminderSync> createState() => _ReminderSyncState();
}

class _ReminderSyncState extends ConsumerState<ReminderSync> {
  // Chạy lần lượt để hai lần đặt lịch không chen nhau.
  Future<void> _queue = Future.value();
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    ref.listenManual<List<ReminderPlan>?>(
      reminderPlansProvider,
      (previous, next) {
        if (next == null || listEquals(previous, next)) return;
        _schedule(next);
      },
      fireImmediately: true,
    );
    _lifecycle = AppLifecycleListener(onResume: () {
      final plans = ref.read(reminderPlansProvider);
      if (plans != null) _schedule(plans);
    });
  }

  void _schedule(List<ReminderPlan> plans) {
    final scheduler = ref.read(notificationSchedulerProvider);
    _queue = _queue.then((_) async {
      try {
        await scheduler.replaceAll(plans);
      } catch (e) {
        debugPrint('Không đặt được lịch nhắc: $e');
      }
    });
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
