import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/providers.dart';

/// Chạy "sang ngày mới" khi mở app, khi quay lại app, và mỗi phút
/// trong lúc app đang mở (để qua nửa đêm là daily tự reset).
class DayWatcher extends ConsumerStatefulWidget {
  const DayWatcher({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<DayWatcher> createState() => _DayWatcherState();
}

class _DayWatcherState extends ConsumerState<DayWatcher> {
  late final AppLifecycleListener _lifecycle;
  late final Timer _timer;
  bool _running = false;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: _check);
    _timer = Timer.periodic(const Duration(minutes: 1), (_) => _check());
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  @override
  void dispose() {
    _timer.cancel();
    _lifecycle.dispose();
    super.dispose();
  }

  Future<void> _check() async {
    if (_running) return;
    _running = true;
    try {
      final result = await ref.read(rolloverServiceProvider).run();
      if (result == null || !mounted) return;
      ref.read(dayTickProvider.notifier).bump();

      final missed = result.missedTitles;
      if (missed.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: const Duration(seconds: 6),
          content: Text(
            'Ngày mới! Bạn đã bỏ lỡ ${missed.length} việc hằng ngày '
            '(${missed.join(', ')}), chuỗi của chúng bắt đầu lại.',
          ),
        ));
      }
    } finally {
      _running = false;
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
