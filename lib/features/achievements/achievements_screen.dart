import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../../domain/achievements.dart';

extension AchievementIcon on AchievementKind {
  IconData get icon => switch (this) {
        AchievementKind.deeds => Icons.volunteer_activism,
        AchievementKind.streak => Icons.local_fire_department,
        AchievementKind.perfectDays => Icons.task_alt,
        AchievementKind.checkIns => Icons.redeem,
        AchievementKind.bosses => Icons.sports_martial_arts,
        AchievementKind.petLevel => Icons.pets,
      };
}

/// Mọi thành tựu: mốc đã đạt và tiến độ tới mốc kế tiếp.
class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(achievementStatsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Thành tựu')),
      body: stats == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32) +
                  MediaQuery.paddingOf(context),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Đã mở ${unlockedAchievements(stats)}/$totalAchievements '
                    'mốc thành tựu',
                    key: const Key('achievements-total'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                for (final progress in achievementProgress(stats))
                  _AchievementCard(progress: progress),
              ],
            ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  const _AchievementCard({required this.progress});

  final AchievementProgress progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final kind = progress.kind;
    final next = progress.nextTarget;
    final unlocked = progress.reached > 0;
    final previous = unlocked ? kind.targets[progress.reached - 1] : 0;
    return Card(
      key: Key('achievement-${kind.name}'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: unlocked
                      ? scheme.primaryContainer
                      : scheme.surfaceContainerHighest,
                  child: Icon(kind.icon,
                      color: unlocked
                          ? scheme.onPrimaryContainer
                          : scheme.onSurfaceVariant),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(kind.label, style: theme.textTheme.titleSmall),
                ),
                for (var i = 0; i < kind.targets.length; i++)
                  Icon(
                    i < progress.reached ? Icons.star : Icons.star_border,
                    size: 18,
                    color: i < progress.reached
                        ? Colors.amber.shade700
                        : scheme.outline,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (next == null)
              Text('Đã đạt mọi mốc: ${kind.goal(previous)}.')
            else ...[
              Text(kind.goal(next)),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress.value / next,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 4),
              Text(
                '${progress.value}/$next',
                key: Key('achievement-${kind.name}-progress'),
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
            if (unlocked && next != null) ...[
              const SizedBox(height: 4),
              Text(
                'Đã đạt: ${kind.goal(previous)}',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
