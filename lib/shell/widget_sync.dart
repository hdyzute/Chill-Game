import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/providers.dart';
import '../domain/widget_snapshot.dart';

/// Cập nhật widget màn hình chính mỗi khi linh thú hoặc việc hôm nay đổi.
class WidgetSync extends ConsumerStatefulWidget {
  const WidgetSync({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<WidgetSync> createState() => _WidgetSyncState();
}

class _WidgetSyncState extends ConsumerState<WidgetSync> {
  // Chạy lần lượt để hai lần cập nhật không chen nhau.
  Future<void> _queue = Future.value();

  @override
  void initState() {
    super.initState();
    ref.listenManual<WidgetSnapshot?>(
      widgetSnapshotProvider,
      (previous, next) {
        if (next == null || previous == next) return;
        final updater = ref.read(homeWidgetUpdaterProvider);
        _queue = _queue.then((_) async {
          try {
            await updater.update(next);
          } catch (e) {
            debugPrint('Không cập nhật được widget: $e');
          }
        });
      },
      fireImmediately: true,
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
