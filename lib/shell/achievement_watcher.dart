import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/providers.dart';
import '../domain/achievements.dart';
import '../features/achievements/achievements_screen.dart';

/// Báo khi mở được mốc thành tựu mới trong lúc dùng app. Thành tựu không
/// lưu, nên chỉ so với số liệu cao nhất đã thấy từ lúc mở app: bỏ tick rồi
/// tick lại không báo lần nữa, và lần tải đầu không báo gì.
class AchievementWatcher extends ConsumerStatefulWidget {
  const AchievementWatcher({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AchievementWatcher> createState() =>
      _AchievementWatcherState();
}

class _AchievementWatcherState extends ConsumerState<AchievementWatcher> {
  /// Số liệu cao nhất đã thấy. Null tới khi số liệu đầu tiên ổn định.
  AchievementStats? _best;
  Timer? _settle;

  /// Các stream cập nhật lần lượt sau một lần ghi (ví dụ lúc sang ngày, dòng
  /// "bỏ lỡ" tới sau), nên chờ số liệu đứng yên rồi mới so, để không báo
  /// nhầm một trạng thái thoáng qua.
  static const settleDelay = Duration(milliseconds: 600);

  @override
  void initState() {
    super.initState();
    ref.listenManual<AchievementStats?>(
      achievementStatsProvider,
      (_, next) {
        if (next == null) return;
        _settle?.cancel();
        _settle = Timer(settleDelay, _compare);
      },
      fireImmediately: true,
    );
  }

  @override
  void dispose() {
    _settle?.cancel();
    super.dispose();
  }

  void _compare() {
    final current = ref.read(achievementStatsProvider);
    if (current == null || !mounted) return;
    final best = _best;
    _best = best == null ? current : best.maxWith(current);
    if (best == null) return;
    final unlocked = newlyUnlocked(best, current);
    if (unlocked.isNotEmpty) _announce(unlocked);
  }

  void _announce(List<({AchievementKind kind, int target})> unlocked) {
    final first = unlocked.first;
    final more = unlocked.length > 1 ? ' (và ${unlocked.length - 1} mốc khác)' : '';
    // Không ẩn snackbar đang hiện (như "Hoàn tác"): xếp hàng sau nó.
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Thành tựu mới: ${first.kind.label} · '
          '${first.kind.goal(first.target)}$more'),
      duration: const Duration(seconds: 4),
      persist: false,
      action: SnackBarAction(
        label: 'Xem',
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => const AchievementsScreen())),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
