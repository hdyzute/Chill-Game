import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/providers.dart';
import '../../domain/drops.dart';
import '../../domain/history.dart';
import '../../domain/pet.dart';
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
    return ListView(
      padding: _listPadding(context),
      children: [
        Center(child: PetArt(stage: status.stage)),
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
          '${status.stage.label} · Bên nhau ${status.daysTogether} ngày',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.chat_bubble_outline,
                    color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(petLine(status, pet.name),
                      style: theme.textTheme.bodyLarge),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (status.stage == PetStage.egg)
          _HatchCard(progress: status.hatchProgress)
        else
          Card(
            child: ListTile(
              leading: const Icon(Icons.celebration_outlined),
              title: Text('Nở vào ${dayLabel(status.hatchedOn!)}'),
            ),
          ),
        const SizedBox(height: 8),
        const _BagCard(),
        const SizedBox(height: 24),
        Text(
          'Sắp có: cho linh thú hấp thụ linh vật để lên cấp và tiến hóa theo hệ.',
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

/// Túi linh vật: các món đã nhặt, và số món nhặt hôm nay trên giới hạn.
class _BagCard extends ConsumerWidget {
  const _BagCard();

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
                      ],
                    ),
                  ),
            const SizedBox(height: 8),
            Text(
              'Việc tốt có thể rơi linh vật theo hệ của nó, việc càng khó càng '
              'dễ rơi. Mỗi ngày nhặt tối đa ${Drops.dailyCap} món.',
              style: muted,
            ),
          ],
        ),
      ),
    );
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
