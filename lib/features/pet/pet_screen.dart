import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/pet_repository.dart';
import '../../data/providers.dart';
import '../../domain/drops.dart';
import '../../domain/growth.dart';
import '../../domain/history.dart';
import '../../domain/pet.dart';
import '../tasks/task_style.dart';
import 'pet_art.dart';

/// Tab Linh thú: khế ước khi chưa có linh thú, sau đó là nhà của nó.
class PetScreen extends ConsumerWidget {
  const PetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Linh thú')),
      body: ref.watch(petProvider).when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Lỗi tải linh thú: $e')),
            data: (pet) => pet == null ? const _ContractView() : _PetHome(pet),
          ),
    );
  }
}

/// Padding của danh sách, chừa chỗ cho thanh điều hướng khi xoay ngang.
EdgeInsets _listPadding(BuildContext context) =>
    const EdgeInsets.fromLTRB(24, 16, 24, 32) + MediaQuery.paddingOf(context);

class _ContractView extends ConsumerStatefulWidget {
  const _ContractView();

  @override
  ConsumerState<_ContractView> createState() => _ContractViewState();
}

class _ContractViewState extends ConsumerState<_ContractView> {
  final _name = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  bool get _canSign => !_saving && _name.text.trim().isNotEmpty;

  Future<void> _sign() async {
    setState(() => _saving = true);
    try {
      await ref.read(petRepositoryProvider).create(_name.text);
    } on StateError {
      // Bấm hai lần: linh thú đã được tạo ở lần đầu.
    }
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: _listPadding(context),
      children: [
        const Center(child: PetArt(stage: PetStage.egg)),
        const SizedBox(height: 24),
        Text('Khế ước linh thú',
            textAlign: TextAlign.center, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 12),
        Text(
          'Một quả trứng linh thú đang chờ chủ nhân. Đặt tên cho nó, rồi hoàn '
          'thành một việc tốt để trứng nở.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _name,
          maxLength: 20,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Tên linh thú',
            border: OutlineInputBorder(),
          ),
          onChanged: (_) => setState(() {}),
          onSubmitted: (_) => _canSign ? _sign() : null,
        ),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: _canSign ? _sign : null,
          icon: const Icon(Icons.handshake_outlined),
          label: const Text('Ký khế ước'),
        ),
      ],
    );
  }
}

class _PetHome extends ConsumerWidget {
  const _PetHome(this.pet);

  final Pet pet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(petStatusProvider);
    if (status == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final theme = Theme.of(context);
    final egg = status.stage == PetStage.egg;
    final stageText = switch (status.stage) {
      PetStage.adult => '${status.stage.label} hệ ${pet.branch!.label}',
      _ => status.stage.label,
    };
    return ListView(
      padding: _listPadding(context),
      children: [
        Center(child: PetArt(stage: status.stage, branch: pet.branch)),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(pet.name,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.headlineSmall),
            ),
            IconButton(
              tooltip: 'Đổi tên',
              icon: const Icon(Icons.edit_outlined, size: 20),
              onPressed: () => _rename(context, ref),
            ),
          ],
        ),
        Text(
          [
            stageText,
            if (!egg) 'Cấp ${pet.level}',
            'Bên nhau ${status.daysTogether} ngày',
          ].join(' · '),
          key: const Key('pet-summary'),
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        _SpeechCard(status: status, name: pet.name),
        const SizedBox(height: 8),
        if (egg)
          _HatchCard(progress: status.hatchProgress)
        else ...[
          _GrowthCard(pet: pet, hatchedOn: status.hatchedOn!),
          const SizedBox(height: 8),
          if (status.stage == PetStage.baby)
            _EvolveCard(pet: pet)
          else
            Card(
              child: ListTile(
                leading: Icon(Icons.auto_awesome, color: pet.branch!.color),
                title: Text('Tiến hóa vào ${dayLabel(pet.evolvedAt!)}'),
              ),
            ),
        ],
        const SizedBox(height: 8),
        _BagCard(pet: pet, canAbsorb: !egg),
        const SizedBox(height: 24),
        Text(
          'Sau này: tiến hóa tiếp thành Yêu Thú, Thánh Thú, Thần Thú theo mốc '
          'chuỗi 30, 100, 365 ngày.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  Future<void> _rename(BuildContext context, WidgetRef ref) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => _RenameDialog(initial: pet.name),
    );
    if (name != null) {
      await ref.read(petRepositoryProvider).rename(pet.id, name);
    }
  }
}

/// Câu thoại và tâm trạng.
class _SpeechCard extends StatelessWidget {
  const _SpeechCard({required this.status, required this.name});

  final PetStatus status;
  final String name;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final egg = status.stage == PetStage.egg;
    final icon = egg
        ? Icons.chat_bubble_outline
        : switch (status.mood) {
            PetMood.happy => Icons.sentiment_very_satisfied,
            PetMood.calm => Icons.sentiment_neutral,
            PetMood.sad => Icons.sentiment_dissatisfied,
            PetMood.tired => Icons.bedtime_outlined,
          };
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!egg)
                    Text('Tâm trạng: ${status.mood.label}',
                        key: const Key('mood'),
                        style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant)),
                  Text(petLine(status, name),
                      style: theme.textTheme.bodyLarge),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Cấp, thanh EXP tới cấp sau, và điểm từng hệ.
class _GrowthCard extends StatelessWidget {
  const _GrowthCard({required this.pet, required this.hatchedOn});

  final Pet pet;
  final DateTime hatchedOn;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final level = pet.level;
    final from = Growth.expForLevel(level);
    final to = Growth.expForLevel(level + 1);
    final leading = Growth.leadingElement(pet.points);
    final muted = theme.textTheme.bodySmall
        ?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cấp $level', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: (pet.exp - from) / (to - from),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            Text('${pet.exp - from}/${to - from} EXP tới cấp ${level + 1}',
                key: const Key('exp')),
            const SizedBox(height: 12),
            Row(
              children: [
                for (final element in TaskElement.values)
                  Expanded(
                    child: Row(
                      children: [
                        Icon(element.icon, size: 18, color: element.color),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            '${element.label} ${pet.points[element]}',
                            key: Key('points-${element.name}'),
                            style: element == leading
                                ? const TextStyle(fontWeight: FontWeight.bold)
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Nở vào ${dayLabel(hatchedOn)}', style: muted),
          ],
        ),
      ),
    );
  }
}

/// Điều kiện tiến hóa kép của ấu thú, và nút tiến hóa khi đủ.
class _EvolveCard extends ConsumerWidget {
  const _EvolveCard({required this.pet});

  final Pet pet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final check = EvolveCheck(
      level: pet.level,
      streak: ref.watch(activeStreakProvider) ?? 0,
      points: pet.points,
    );
    Widget requirement(bool ok, String text) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Icon(ok ? Icons.check_circle : Icons.radio_button_unchecked,
                  size: 20,
                  color: ok
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 8),
              Expanded(child: Text(text)),
            ],
          ),
        );
    final branch = check.branch;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tiến hóa', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            requirement(check.levelOk,
                'Đạt cấp ${Growth.evolveLevel} (đang cấp ${check.level})'),
            requirement(
                check.streakOk,
                'Chuỗi ${Growth.evolveStreak} ngày liên tiếp có việc tốt '
                '(đang ${check.streak} ngày)'),
            const SizedBox(height: 8),
            Text(
              branch == null
                  ? 'Hấp thụ linh vật để chọn hướng tiến hóa.'
                  : 'Hướng tiến hóa: hệ ${branch.label}, theo hệ có điểm cao '
                      'nhất.',
              key: const Key('evolve-branch'),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed:
                  check.ready ? () => _evolve(context, ref, branch!) : null,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Tiến hóa'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _evolve(
      BuildContext context, WidgetRef ref, TaskElement branch) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Tiến hóa theo hệ ${branch.label}?'),
        content: Text(
            '${pet.name} sẽ thành linh thú Trưởng thành hệ ${branch.label}. '
            'Nhánh này không đổi lại được.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Để sau'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Đồng ý'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(petRepositoryProvider).evolve(pet.id, branch);
    }
  }
}

/// Túi linh vật: các món đã nhặt, số món nhặt hôm nay trên giới hạn, và nút
/// hấp thụ từng món.
class _BagCard extends ConsumerWidget {
  const _BagCard({required this.pet, required this.canAbsorb});

  final Pet pet;
  final bool canAbsorb;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final items = ref.watch(inventoryProvider).value ?? const {};
    final today = ref.watch(todayDropsProvider).value ?? 0;
    final muted = theme.textTheme.bodySmall
        ?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Túi linh vật',
                      style: theme.textTheme.titleMedium),
                ),
                Text('Hôm nay $today/${Drops.dailyCap}',
                    key: const Key('drops-today'), style: muted),
              ],
            ),
            const SizedBox(height: 12),
            if (items.isEmpty)
              const Text('Túi còn trống. Làm việc tốt để nhặt linh vật nhé.')
            else
              for (final item in SpiritItem.values)
                if (items[item] case final count?)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        SpiritItemIcon(item),
                        const SizedBox(width: 12),
                        Expanded(child: Text(item.label)),
                        Text('×$count',
                            key: Key('item-${item.name}'),
                            style: theme.textTheme.titleSmall),
                        if (canAbsorb) ...[
                          const SizedBox(width: 8),
                          FilledButton.tonal(
                            key: Key('absorb-${item.name}'),
                            onPressed: () => _absorb(context, ref, item),
                            child: const Text('Hấp thụ'),
                          ),
                        ],
                      ],
                    ),
                  ),
            const SizedBox(height: 8),
            Text(
              [
                if (!canAbsorb) 'Trứng nở rồi mới hấp thụ được linh vật.',
                'Việc tốt có thể rơi linh vật theo hệ của nó, việc càng khó '
                    'càng dễ rơi. Mỗi ngày nhặt tối đa ${Drops.dailyCap} món.',
              ].join(' '),
              style: muted,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _absorb(
      BuildContext context, WidgetRef ref, SpiritItem item) async {
    final messenger = ScaffoldMessenger.of(context);
    final Pet after;
    try {
      after = await ref.read(scoreServiceProvider).absorb(item);
    } on StateError {
      return; // Bấm quá nhanh khi món cuối vừa hết.
    }
    final levelUp =
        after.level > pet.level ? ' · Lên cấp ${after.level}!' : '';
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        duration: const Duration(seconds: 2),
        content: Text('${pet.name} hấp thụ ${item.label}: '
            '+${Growth.expOf(item)} EXP, +${Growth.pointsOf(item)} '
            '${item.element.label}$levelUp'),
      ));
  }
}

class _HatchCard extends StatelessWidget {
  const _HatchCard({required this.progress});

  final int progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ấp trứng', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress / hatchDays,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            Text('Còn ${hatchDays - progress} ngày có việc tốt nữa là nở',
                key: const Key('hatch-progress')),
          ],
        ),
      ),
    );
  }
}

class _RenameDialog extends StatefulWidget {
  const _RenameDialog({required this.initial});

  final String initial;

  @override
  State<_RenameDialog> createState() => _RenameDialogState();
}

class _RenameDialogState extends State<_RenameDialog> {
  late final _name = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _save() {
    if (_name.text.trim().isEmpty) return;
    Navigator.of(context).pop(_name.text);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Đổi tên linh thú'),
      content: TextField(
        controller: _name,
        autofocus: true,
        maxLength: 20,
        textCapitalization: TextCapitalization.words,
        onChanged: (_) => setState(() {}),
        onSubmitted: (_) => _save(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Hủy'),
        ),
        TextButton(
          onPressed: _name.text.trim().isEmpty ? null : _save,
          child: const Text('Lưu'),
        ),
      ],
    );
  }
}
