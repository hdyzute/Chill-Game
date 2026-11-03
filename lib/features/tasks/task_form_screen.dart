import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/providers.dart';
import 'task_style.dart';

/// Tạo task mới khi [task] là null, ngược lại là sửa task đó.
class TaskFormScreen extends ConsumerStatefulWidget {
  const TaskFormScreen({super.key, this.task});

  final Task? task;

  @override
  ConsumerState<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends ConsumerState<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _notes;
  late final TextEditingController _cost;
  late TaskType _type;
  late Difficulty _difficulty;
  late TaskElement _element;
  late bool _habitUp;
  late bool _habitDown;
  late int _dailyTarget;
  late int _repeatDays;

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    final t = widget.task;
    _title = TextEditingController(text: t?.title ?? '');
    _notes = TextEditingController(text: t?.notes ?? '');
    _cost = TextEditingController(text: t == null ? '' : '${t.cost}');
    _type = t?.type ?? TaskType.daily;
    _difficulty = t?.difficulty ?? Difficulty.easy;
    _element = t?.element ?? TaskElement.fire;
    _habitUp = t?.habitUp ?? true;
    _habitDown = t?.habitDown ?? false;
    _dailyTarget = t?.dailyTarget ?? 1;
    _repeatDays = t?.repeatDays ?? everyDayMask;
  }

  @override
  void dispose() {
    _title.dispose();
    _notes.dispose();
    _cost.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Sửa' : 'Tạo mới'),
        actions: [
          if (_isEditing)
            IconButton(
              tooltip: 'Xóa',
              icon: const Icon(Icons.delete_outline),
              onPressed: _confirmDelete,
            ),
          TextButton(onPressed: _save, child: const Text('Lưu')),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SegmentedButton<TaskType>(
              showSelectedIcon: false,
              segments: [
                for (final type in TaskType.values)
                  ButtonSegment(
                    value: type,
                    icon: Icon(type.icon),
                    tooltip: type.label,
                  ),
              ],
              selected: {_type},
              // Không cho đổi loại khi sửa, tránh lẫn streak và điểm.
              onSelectionChanged: _isEditing
                  ? null
                  : (s) => setState(() => _type = s.first),
            ),
            const SizedBox(height: 8),
            Text(_type.label,
                textAlign: TextAlign.center, style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            TextFormField(
              controller: _title,
              autofocus: !_isEditing,
              maxLength: 100,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'Tên',
                hintText: _titleHint,
                border: const OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Nhập tên nhé' : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _notes,
              minLines: 1,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Ghi chú (không bắt buộc)',
                border: OutlineInputBorder(),
              ),
            ),
            ..._typeSpecificFields(theme),
            if (_type != TaskType.reward) ...[
              _SectionLabel('Hệ'),
              Wrap(
                spacing: 8,
                children: [
                  for (final e in TaskElement.values)
                    ChoiceChip(
                      avatar: Icon(e.icon, color: e.color),
                      label: Text(e.label),
                      selected: _element == e,
                      onSelected: (_) => setState(() => _element = e),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(_element.hint, style: theme.textTheme.bodySmall),
              ),
              _SectionLabel('Độ khó'),
              SegmentedButton<Difficulty>(
                segments: [
                  for (final d in Difficulty.values)
                    ButtonSegment(value: d, label: Text(d.label)),
                ],
                selected: {_difficulty},
                onSelectionChanged: (s) => setState(() => _difficulty = s.first),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String get _titleHint => switch (_type) {
        TaskType.habit => 'Ví dụ: Uống nước, Ăn vặt',
        TaskType.daily => 'Ví dụ: Chạy bộ 20 phút',
        TaskType.todo => 'Ví dụ: Nộp báo cáo',
        TaskType.reward => 'Ví dụ: Xem 1 tập phim',
      };

  List<Widget> _typeSpecificFields(ThemeData theme) => switch (_type) {
        TaskType.habit => [
            _SectionLabel('Loại thói quen'),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('+ Tốt'),
                  selected: _habitUp,
                  onSelected: (v) => setState(() => _habitUp = v),
                ),
                FilterChip(
                  label: const Text('− Xấu'),
                  selected: _habitDown,
                  onSelected: (v) => setState(() => _habitDown = v),
                ),
              ],
            ),
            if (_habitUp) ...[
              _SectionLabel('Số lần mỗi ngày'),
              Row(
                children: [
                  IconButton.outlined(
                    tooltip: 'Bớt một lần',
                    icon: const Icon(Icons.remove),
                    onPressed: _dailyTarget > 1
                        ? () => setState(() => _dailyTarget--)
                        : null,
                  ),
                  SizedBox(
                    width: 48,
                    child: Text('$_dailyTarget',
                        key: const Key('dailyTarget'),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleLarge),
                  ),
                  IconButton.outlined(
                    tooltip: 'Thêm một lần',
                    icon: const Icon(Icons.add),
                    onPressed: _dailyTarget < maxDailyTarget
                        ? () => setState(() => _dailyTarget++)
                        : null,
                  ),
                ],
              ),
              Text(
                'Được thưởng tối đa $_dailyTarget lần mỗi ngày. '
                'Ví dụ: uống nước 8 lần.',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ],
        TaskType.daily => [
            _SectionLabel('Lặp lại vào'),
            Wrap(
              spacing: 6,
              children: [
                for (var i = 0; i < 7; i++)
                  FilterChip(
                    showCheckmark: false,
                    label: Text(weekdayLabels[i]),
                    selected: _repeatDays & (1 << i) != 0,
                    onSelected: (_) =>
                        setState(() => _repeatDays ^= 1 << i),
                  ),
              ],
            ),
          ],
        TaskType.todo => const [],
        TaskType.reward => [
            const SizedBox(height: 8),
            TextFormField(
              controller: _cost,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Giá (xu)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.monetization_on_outlined),
              ),
              validator: (v) => (int.tryParse(v ?? '') ?? 0) <= 0
                  ? 'Giá phải lớn hơn 0'
                  : null,
            ),
          ],
      };

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final error = switch (_type) {
      TaskType.habit when !_habitUp && !_habitDown =>
        'Chọn ít nhất một loại: Tốt hoặc Xấu',
      TaskType.daily when _repeatDays == 0 => 'Chọn ít nhất một ngày',
      _ => null,
    };
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    final notes = _notes.text.trim();
    final fields = TasksCompanion(
      title: Value(_title.text.trim()),
      notes: Value(notes.isEmpty ? null : notes),
      type: Value(_type),
      difficulty: Value(_difficulty),
      element: Value(_type == TaskType.reward ? null : _element),
      habitUp: Value(_habitUp),
      habitDown: Value(_habitDown),
      dailyTarget: Value(_dailyTarget),
      repeatDays: Value(_repeatDays),
      cost: Value(int.tryParse(_cost.text) ?? 0),
    );

    final repo = ref.read(taskRepositoryProvider);
    if (_isEditing) {
      await repo.updateFields(widget.task!.id, fields);
    } else {
      await repo.add(fields);
    }
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _confirmDelete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa task này?'),
        content: Text('"${widget.task!.title}" sẽ bị xóa vĩnh viễn.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Hủy')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Xóa')),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(taskRepositoryProvider).delete(widget.task!.id);
    if (mounted) Navigator.of(context).pop();
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(text, style: Theme.of(context).textTheme.titleSmall),
    );
  }
}
