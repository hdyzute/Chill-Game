import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';

/// Giờ bắt đầu ngày: 0 giờ (nửa đêm) tới 12 giờ trưa.
final _dayStartHours = [for (var h = 0; h <= 12; h++) h];

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final repo = ref.read(profileRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      body: profile.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Lỗi tải cài đặt: $e')),
        data: (p) => ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.wb_twilight),
              title: const Text('Giờ bắt đầu ngày mới'),
              subtitle: const Text(
                  'Trước giờ này vẫn tính là hôm trước. Hợp với người hay thức khuya.'),
              trailing: DropdownButton<int>(
                key: const Key('dayStartHour'),
                value: p.dayStartHour,
                items: [
                  for (final h in _dayStartHours)
                    DropdownMenuItem(value: h, child: Text('$h:00')),
                ],
                onChanged: (h) => repo.setDayStartHour(h!),
              ),
            ),
            const Divider(),
            SwitchListTile(
              secondary: const Icon(Icons.self_improvement),
              title: const Text('Linh thú bế quan'),
              subtitle: Text(p.resting
                  ? 'Đang bế quan: bỏ lỡ việc hằng ngày không bị mất chuỗi.'
                  : 'Bật khi ốm hoặc đi xa: bỏ lỡ việc hằng ngày '
                      'không bị mất chuỗi.'),
              value: p.resting,
              onChanged: repo.setResting,
            ),
            const Divider(),
            const _ExactRemindersTile(),
            ListTile(
              key: const Key('app-settings'),
              leading: const Icon(Icons.notifications_paused_outlined),
              title: const Text('Có ngày không nhận được nhắc nhở?'),
              subtitle: const Text(
                'Xiaomi, Oppo, Huawei... hay tự tắt app chạy nền và xóa luôn '
                'lịch nhắc. Bấm để mở trang của app, rồi bật "Tự khởi chạy" và '
                'chọn "Không giới hạn" ở mục Tiết kiệm pin.',
              ),
              trailing: const Icon(Icons.open_in_new),
              onTap: () =>
                  ref.read(notificationSchedulerProvider).openAppSettings(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Trạng thái quyền nhắc đúng giờ, kiểm tra lại mỗi khi quay về app (người
/// dùng vừa bật hoặc tắt trong cài đặt hệ thống).
class _ExactRemindersTile extends ConsumerStatefulWidget {
  const _ExactRemindersTile();

  @override
  ConsumerState<_ExactRemindersTile> createState() =>
      _ExactRemindersTileState();
}

class _ExactRemindersTileState extends ConsumerState<_ExactRemindersTile> {
  bool? _exact;
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _check();
    _lifecycle = AppLifecycleListener(onResume: _check);
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  Future<void> _check() async {
    final exact =
        await ref.read(notificationSchedulerProvider).canScheduleExact();
    if (mounted) setState(() => _exact = exact);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final exact = _exact;
    return ListTile(
      key: const Key('exact-reminders'),
      leading: Icon(exact == false ? Icons.alarm_off : Icons.alarm_on,
          color: exact == false ? theme.colorScheme.error : null),
      title: const Text('Nhắc đúng giờ'),
      subtitle: Text(switch (exact) {
        null => 'Đang kiểm tra...',
        true => 'Đã bật: nhắc nhở đến đúng giờ đã đặt.',
        false => 'Chưa bật: Android có thể nhắc trễ tới 1 giờ. Bấm để bật.',
      }),
      onTap: exact == false
          ? () => ref.read(notificationSchedulerProvider).requestExactPermission()
          : null,
    );
  }
}
