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
            const ListTile(
              leading: Icon(Icons.notifications_paused_outlined),
              title: Text('Không nhận được nhắc nhở?'),
              subtitle: Text(
                'Một số máy (Xiaomi, Oppo, Huawei...) tự tắt app chạy nền. '
                'Vào Cài đặt điện thoại → Ứng dụng → Linh Thú Kỷ Luật: '
                'bật "Tự khởi động" và chọn "Không giới hạn" ở mục Tiết kiệm pin. '
                'Nhắc nhở có thể trễ vài phút.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
