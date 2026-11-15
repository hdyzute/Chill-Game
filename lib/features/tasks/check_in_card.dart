import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../../data/score_service.dart';
import '../../domain/check_in.dart';
import 'task_style.dart';

/// Quà điểm danh ở đầu tab Hôm nay. Ẩn khi hôm nay đã nhận.
class CheckInCard extends ConsumerWidget {
  const CheckInCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(checkInStatusProvider);
    if (status == null || status.doneToday) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final number = status.count + 1;
    final day = CheckIn.dayInCycle(number);
    return Card(
      key: const Key('check-in'),
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
        child: Row(
          children: [
            const Icon(Icons.redeem, color: rewardColor, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Quà điểm danh · ngày $day/${CheckIn.cycle}',
                      style: theme.textTheme.titleSmall),
                  Text(
                    giftLabel(CheckIn.giftFor(number)) +
                        (day < CheckIn.cycle
                            ? ' · ngày ${CheckIn.cycle} có quà lớn'
                            : ''),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: () => _claim(context, ref),
              child: const Text('Nhận'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _claim(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final CheckInResult result;
    try {
      result = await ref.read(scoreServiceProvider).checkIn();
    } on StateError {
      return; // Bấm hai lần: hôm nay đã nhận.
    }
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        duration: const Duration(seconds: 3),
        content: Text('Điểm danh lần ${result.number}: nhận '
            '${giftLabel(result.gift)}'),
      ));
  }
}
