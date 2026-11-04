import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/providers.dart';
import '../../domain/drops.dart';
import '../../domain/history.dart';
import '../tasks/task_style.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  /// Tháng đang xem; null = tháng hiện tại.
  DateTime? _month;

  /// Ngày đang chọn; null = hôm nay nếu đang xem tháng hiện tại.
  DateTime? _selected;

  @override
  Widget build(BuildContext context) {
    final today = ref.watch(todayProvider);
    final hour = ref.watch(dayStartHourProvider);
    if (today == null || hour == null) {
      return const _Frame(child: Center(child: CircularProgressIndicator()));
    }
    final thisMonth = monthOf(today);
    final month = _month ?? thisMonth;
    final selected = _selected ?? (month == thisMonth ? today : null);

    return _Frame(
      child: ref.watch(monthLogsProvider(month)).when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Lỗi tải lịch sử: $e')),
            data: (logs) {
              final byDay = groupByDay(logs, hour);
              return ListView(
                // Chừa chỗ cho thanh điều hướng bên cạnh khi xoay ngang.
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32) +
                    MediaQuery.paddingOf(context),
                children: [
                  _SummaryCard(
                    streak: ref.watch(activeStreakProvider),
                    stats: monthStats(logs),
                  ),
                  const SizedBox(height: 16),
                  _MonthHeader(
                    month: month,
                    onPrev: () => _showMonth(
                        DateTime(month.year, month.month - 1)),
                    onNext: month.isBefore(thisMonth)
                        ? () => _showMonth(
                            DateTime(month.year, month.month + 1))
                        : null,
                  ),
                  _CalendarGrid(
                    month: month,
                    today: today,
                    selected: selected,
                    byDay: byDay,
                    onSelect: (day) => setState(() => _selected = day),
                  ),
                  const SizedBox(height: 16),
                  if (selected == null)
                    const _Hint('Chọn một ngày để xem chi tiết.')
                  else
                    _DayDetail(day: selected, logs: byDay[selected] ?? const []),
                ],
              );
            },
          ),
    );
  }

  void _showMonth(DateTime month) => setState(() {
        _month = month;
        _selected = null;
      });
}

class _Frame extends StatelessWidget {
  const _Frame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Lịch sử')),
        body: child,
      );
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.streak, required this.stats});

  final int? streak;
  final MonthStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _Stat(
                  key: const Key('streak'),
                  icon: Icons.local_fire_department,
                  color: TaskElement.fire.color,
                  value: '${streak ?? 0}',
                  label: 'ngày liên tiếp',
                ),
                _Stat(
                  icon: Icons.check_circle_outline,
                  color: theme.colorScheme.primary,
                  value: '${stats.completions}',
                  label: 'việc tốt trong tháng',
                ),
                _Stat(
                  key: const Key('month-coins'),
                  icon: Icons.monetization_on,
                  color: rewardColor,
                  value: '${stats.coinsEarned}',
                  label: 'xu trong tháng',
                ),
              ],
            ),
            if (stats.byElement.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final element in TaskElement.values)
                    if (stats.byElement[element] case final count?)
                      Chip(
                        avatar: Icon(element.icon, color: element.color),
                        label: Text('${element.label} $count'),
                        visualDensity: VisualDensity.compact,
                      ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    super.key,
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 4),
              Text(value, style: theme.textTheme.titleLarge),
            ],
          ),
          Text(label,
              textAlign: TextAlign.center, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _MonthHeader extends StatelessWidget {
  const _MonthHeader(
      {required this.month, required this.onPrev, required this.onNext});

  final DateTime month;
  final VoidCallback onPrev;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          tooltip: 'Tháng trước',
          onPressed: onPrev,
          icon: const Icon(Icons.chevron_left),
        ),
        Expanded(
          child: Text(
            monthLabel(month),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        IconButton(
          tooltip: 'Tháng sau',
          onPressed: onNext,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid({
    required this.month,
    required this.today,
    required this.selected,
    required this.byDay,
    required this.onSelect,
  });

  final DateTime month;
  final DateTime today;
  final DateTime? selected;
  final Map<DateTime, List<TaskLog>> byDay;
  final ValueChanged<DateTime> onSelect;

  static const _alphas = [0.0, 0.25, 0.45, 0.7, 0.95];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final cells = monthGrid(month);

    return Column(
      children: [
        Row(
          children: [
            for (final label in ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'])
              Expanded(
                child: Center(
                  child: Text(label, style: theme.textTheme.labelSmall),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        for (var row = 0; row < cells.length; row += 7)
          Row(
            children: [
              for (final day in cells.sublist(row, row + 7))
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: day == null
                        ? const SizedBox()
                        : _dayCell(context, scheme, day),
                  ),
                ),
            ],
          ),
      ],
    );
  }

  Widget _dayCell(BuildContext context, ColorScheme scheme, DateTime day) {
    final future = day.isAfter(today);
    final level = heatLevel(completionsOf(byDay[day] ?? const []));
    final isSelected = day == selected;
    final isToday = day == today;

    final Color textColor;
    if (future) {
      textColor = scheme.onSurface.withValues(alpha: 0.3);
    } else if (level >= 3) {
      textColor = scheme.onPrimary;
    } else {
      textColor = scheme.onSurface;
    }

    return Padding(
      padding: const EdgeInsets.all(2),
      child: Material(
        color: scheme.primary.withValues(alpha: _alphas[level]),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: isSelected
              ? BorderSide(color: scheme.onSurface, width: 2)
              : isToday
                  ? BorderSide(color: scheme.primary, width: 2)
                  : BorderSide.none,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: Key('day-${day.day}'),
          onTap: future ? null : () => onSelect(day),
          child: Center(
            child: Text(
              '${day.day}',
              style: TextStyle(
                color: textColor,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DayDetail extends StatelessWidget {
  const _DayDetail({required this.day, required this.logs});

  final DateTime day;
  final List<TaskLog> logs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final done = completionsOf(logs);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          done > 0 ? '${dayLabel(day)} · $done việc tốt' : dayLabel(day),
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: 4),
        if (logs.isEmpty)
          const _Hint('Ngày này chưa có hoạt động nào.')
        else
          for (final log in logs) _LogTile(log: log),
      ],
    );
  }
}

class _LogTile extends StatelessWidget {
  const _LogTile({required this.log});

  final TaskLog log;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (icon, color) = switch (log.kind) {
      LogKind.complete => (
          Icons.check,
          log.element?.color ?? theme.colorScheme.primary
        ),
      LogKind.bad => (Icons.thumb_down_alt_outlined, theme.colorScheme.error),
      LogKind.purchase => (Icons.card_giftcard, rewardColor),
    };
    final notes = [
      timeLabel(log.createdAt),
      if (log.kind == LogKind.bad) 'thói quen xấu',
      if (log.kind == LogKind.purchase) 'đổi phần thưởng',
      if (log.critical) 'Linh khí bạo phát!',
      if (log.dropItem != null)
        'nhặt được ${dropLabel(log.dropItem!, log.dropCount)}',
    ];
    final coins = log.coinsDelta;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      leading: CircleAvatar(
        radius: 16,
        backgroundColor: color.withValues(alpha: 0.15),
        child: Icon(icon, size: 18, color: color),
      ),
      title: Text(log.title ?? 'Task đã xóa'),
      subtitle: Text(notes.join(' · ')),
      trailing: coins == 0
          ? null
          : Text(
              coins > 0 ? '+$coins xu' : '−${-coins} xu',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: coins > 0 ? null : theme.colorScheme.error,
              ),
            ),
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
}
