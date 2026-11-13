import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/providers.dart';
import '../../domain/drops.dart';
import '../../domain/field.dart';
import '../tasks/task_style.dart';

/// Linh điền: các ô đất, gieo hạt bằng xu, xem cây lớn, thu hoạch linh vật.
class FieldCard extends ConsumerStatefulWidget {
  const FieldCard({super.key});

  @override
  ConsumerState<FieldCard> createState() => _FieldCardState();
}

class _FieldCardState extends ConsumerState<FieldCard> {
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    // Cây lớn theo giờ thật: vẽ lại định kỳ để thời gian còn lại tự giảm.
    _timer =
        Timer.periodic(const Duration(seconds: 30), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final plantings = ref.watch(plantingsProvider).value ?? const [];
    final boosts = ref.watch(fieldBoostsProvider) ?? const {};
    final now = ref.watch(clockProvider)();
    final byPlot = {for (final p in plantings) p.plot: p};
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Linh điền', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                for (var i = 0; i < Field.plots; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(
                    child: _PlotTile(
                      key: Key('plot-$i'),
                      state: plotState(
                        element: byPlot[i]?.element,
                        plantedAt: byPlot[i]?.plantedAt,
                        boosts: boosts[i] ?? 0,
                        now: now,
                      ),
                      onPlant: () => _plant(i),
                      onHarvest: () => _harvest(i),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Hạt giống ${Field.seedCost} xu, chín sau '
              '${Field.growTime.inHours} giờ, thu ${Field.harvestCount} linh '
              'vật cùng hệ. Mỗi việc tốt cùng hệ giúp cây chín sớm '
              '${Field.deedBoost.inHours} giờ.',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  ScaffoldMessengerState _messenger() =>
      ScaffoldMessenger.of(context)..hideCurrentSnackBar();

  void _show(String text) => _messenger().showSnackBar(
      SnackBar(content: Text(text), duration: const Duration(seconds: 2)));

  Future<void> _plant(int plot) async {
    final coins = ref.read(coinsProvider).value ?? 0;
    final element = await showModalBottomSheet<TaskElement>(
      context: context,
      builder: (_) => _SeedSheet(coins: coins),
    );
    if (element == null || !mounted) return;
    final bool planted;
    try {
      planted = await ref.read(scoreServiceProvider).plant(plot, element);
    } on StateError {
      return; // Bấm hai lần: ô vừa được gieo.
    }
    if (!mounted) return;
    _show(planted
        ? 'Đã gieo hạt ${element.label}. Chín sau '
            '${Field.growTime.inHours} giờ.'
        : 'Chưa đủ xu: cần ${Field.seedCost}, bạn đang có $coins');
  }

  Future<void> _harvest(int plot) async {
    final List<SpiritItem> items;
    try {
      items = await ref.read(scoreServiceProvider).harvest(plot);
    } on StateError {
      return; // Bấm hai lần, hoặc đồng hồ chưa tới lúc chín.
    }
    if (!mounted) return;
    final counts = <SpiritItem, int>{};
    for (final item in items) {
      counts[item] = (counts[item] ?? 0) + 1;
    }
    _show('Thu hoạch được '
        '${counts.entries.map((e) => dropLabel(e.key, e.value)).join(', ')}');
  }
}

class _PlotTile extends StatelessWidget {
  const _PlotTile({
    super.key,
    required this.state,
    required this.onPlant,
    required this.onHarvest,
  });

  final PlotState state;
  final VoidCallback onPlant;
  final VoidCallback onHarvest;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final small = theme.textTheme.bodySmall;
    final (Widget top, String label, VoidCallback? onTap) = switch (state) {
      EmptyPlot() => (
          Icon(Icons.add, size: 32, color: theme.colorScheme.primary),
          'Gieo hạt',
          onPlant,
        ),
      GrowingPlot(:final element, :final remaining, :final progress) => (
          SizedBox.square(
            dimension: 40,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 3,
                  color: element.color,
                  backgroundColor: element.color.withValues(alpha: 0.2),
                ),
                Icon(Icons.spa, size: 20, color: element.color),
              ],
            ),
          ),
          'Còn ${remainingLabel(remaining)}',
          null,
        ),
      ReadyPlot(:final element) => (
          Icon(element.icon, size: 36, color: element.color),
          'Thu hoạch',
          onHarvest,
        ),
    };
    return Material(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: Column(
            children: [
              SizedBox(height: 40, child: Center(child: top)),
              const SizedBox(height: 8),
              Text(label,
                  textAlign: TextAlign.center,
                  style: state is ReadyPlot
                      ? small?.copyWith(fontWeight: FontWeight.bold)
                      : small),
            ],
          ),
        ),
      ),
    );
  }
}

class _SeedSheet extends StatelessWidget {
  const _SeedSheet({required this.coins});

  final int coins;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enough = coins >= Field.seedCost;
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 4),
            child: Text('Gieo hạt linh vật', style: theme.textTheme.titleLarge),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Mỗi hạt ${Field.seedCost} xu · bạn đang có $coins xu',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 8),
          for (final element in TaskElement.values)
            ListTile(
              enabled: enough,
              leading: Icon(element.icon, color: element.color),
              title: Text('Hạt ${element.label}'),
              subtitle: Text(
                  'Ra ${SpiritItem.of(element, rare: false).label}'),
              onTap: () => Navigator.of(context).pop(element),
            ),
          if (!enough)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Text('Chưa đủ xu. Làm việc tốt để kiếm thêm nhé.',
                  style: TextStyle(color: theme.colorScheme.error)),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
