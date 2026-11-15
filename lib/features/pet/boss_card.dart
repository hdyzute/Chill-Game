import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/providers.dart';
import '../../data/score_service.dart';
import '../../domain/boss.dart';
import '../../domain/drops.dart';
import '../tasks/task_style.dart';

/// Bí cảnh: khiêu chiến boss, xem HP và sát thương hôm nay, nhận thưởng khi
/// đánh bại.
class BossCard extends ConsumerWidget {
  const BossCard({super.key, required this.petName});

  final String petName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final active = ref.watch(activeBossProvider);
    final defeated = ref.watch(bossDefeatedCountProvider).value;
    if (!active.hasValue || defeated == null) return const SizedBox.shrink();
    final boss = active.value;
    final progress = ref.watch(bossProgressProvider);

    final Widget body;
    if (boss == null) {
      body = _Challenge(defeated: defeated);
    } else if (progress == null) {
      body = const Center(child: CircularProgressIndicator());
    } else if (progress.defeated) {
      body = _Defeated(progress: progress);
    } else {
      body = _Fighting(progress: progress, petName: petName);
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bí cảnh', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            body,
          ],
        ),
      ),
    );
  }
}

class _BossHeader extends StatelessWidget {
  const _BossHeader({required this.kind, required this.tier});

  final BossKind kind;
  final int tier;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: kind.element.color.withValues(alpha: 0.15),
          child: Icon(kind.element.icon, color: kind.element.color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tier > 1 ? '${kind.label} · Vòng $tier' : kind.label,
                  key: const Key('boss-name'),
                  style: theme.textTheme.titleSmall),
              Text(
                'Hệ ${kind.element.label} · Bị hệ ${kind.weakness.label} khắc chế',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Challenge extends ConsumerWidget {
  const _Challenge({required this.defeated});

  final int defeated;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kind = BossStats.nextKind(defeated);
    final tier = BossStats.nextTier(defeated);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BossHeader(kind: kind, tier: tier),
        const SizedBox(height: 8),
        Text(
          'HP ${BossStats.maxHp(kind, tier)}. Mỗi việc tốt gây sát thương bằng '
          'số xu nó kiếm được, đánh vào boss lúc sang ngày. Bỏ lỡ việc hằng '
          'ngày thì boss tấn công linh thú. Thắng được '
          '${BossStats.rewardCoins(kind, tier)} xu và ${BossStats.rewardItems} '
          '${SpiritItem.of(kind.element, rare: true).label}.',
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: () async {
            try {
              await ref.read(bossRepositoryProvider).challengeNext();
            } on StateError {
              // Bấm hai lần: boss vừa được tạo.
            }
          },
          icon: const Icon(Icons.sports_martial_arts),
          label: const Text('Khiêu chiến'),
        ),
      ],
    );
  }
}

class _Fighting extends StatelessWidget {
  const _Fighting({required this.progress, required this.petName});

  final BossProgress progress;
  final String petName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final kind = progress.kind;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BossHeader(kind: kind, tier: progress.tier),
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: progress.hp / progress.maxHp,
          minHeight: 10,
          color: theme.colorScheme.error,
          backgroundColor: theme.colorScheme.error.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(5),
        ),
        const SizedBox(height: 8),
        Text('HP ${progress.hp}/${progress.maxHp}',
            key: const Key('boss-hp')),
        Text(
          'Hôm nay tích lũy ${progress.pending} sát thương, đánh vào boss lúc '
          'sang ngày. Việc tốt hệ ${kind.weakness.label} gây gấp rưỡi.',
          key: const Key('boss-pending'),
          style: theme.textTheme.bodySmall
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        if (progress.attacked) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.flash_on, size: 18, color: theme.colorScheme.error),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Hôm qua bỏ lỡ việc hằng ngày: ${kind.label} đã tấn công '
                  '$petName.',
                  key: const Key('boss-attack'),
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _Defeated extends ConsumerWidget {
  const _Defeated({required this.progress});

  final BossProgress progress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kind = progress.kind;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BossHeader(kind: kind, tier: progress.tier),
        const SizedBox(height: 12),
        Text('Đã đánh bại ${kind.label}!',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: () => _claim(context, ref),
          icon: const Icon(Icons.redeem),
          label: const Text('Nhận thưởng'),
        ),
      ],
    );
  }

  Future<void> _claim(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final BossReward reward;
    try {
      reward = await ref.read(scoreServiceProvider).claimBoss();
    } on StateError {
      return; // Bấm hai lần: thưởng đã nhận.
    }
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        duration: const Duration(seconds: 3),
        content: Text('Nhận ${reward.coins} xu và '
            '${dropLabel(reward.item, reward.itemCount)}'),
      ));
  }
}
