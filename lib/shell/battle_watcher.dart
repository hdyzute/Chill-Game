import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/providers.dart';
import '../features/pet/battle_screen.dart';

/// Mỗi sáng tự mở trận boss hôm qua một lần, nếu hôm qua có đòn đánh hoặc bị
/// đánh trả. Màn trận ghi lại ngày đã chiếu (`Profiles.lastBattleDay`).
class BattleWatcher extends ConsumerStatefulWidget {
  const BattleWatcher({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<BattleWatcher> createState() => _BattleWatcherState();
}

class _BattleWatcherState extends ConsumerState<BattleWatcher> {
  /// Lúc mở app, sang ngày ghi các dòng "bỏ lỡ" của hôm qua ngay sau đó, nên
  /// chờ số liệu đứng yên rồi mới mở, để trận có cả lượt boss đánh trả.
  static const settleDelay = Duration(milliseconds: 1200);

  Timer? _settle;

  /// Ngày đã mở trong phiên này, để không mở hai lần khi đang ghi ngày đã xem.
  DateTime? _opened;

  @override
  void initState() {
    super.initState();
    ref.listenManual(unseenBattleProvider, (_, next) {
      _settle?.cancel();
      if (next != null) _settle = Timer(settleDelay, _open);
    }, fireImmediately: true);
  }

  @override
  void dispose() {
    _settle?.cancel();
    super.dispose();
  }

  void _open() {
    final replay = ref.read(unseenBattleProvider);
    if (replay == null || !mounted || _opened == replay.day) return;
    _opened = replay.day;
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => BattleScreen(replay: replay)));
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
