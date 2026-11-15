/// Nội dung widget màn hình chính: linh thú và việc hôm nay, dạng chữ sẵn để
/// phần Android chỉ việc hiện ra.
library;

import '../data/database.dart';
import 'growth.dart';
import 'pet.dart';
import 'today.dart';

class WidgetSnapshot {
  const WidgetSnapshot({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.tasks,
    required this.date,
    required this.dayStartHour,
  });

  /// Hình tạm của linh thú.
  final String emoji;

  /// "Abcdef · Cấp 3".
  final String title;

  /// "Vui · Hôm nay 2/4 việc".
  final String subtitle;

  /// Các việc chưa làm, mỗi dòng một việc, hoặc một câu khi không còn gì.
  final String tasks;

  /// Ngày logic của dữ liệu, dạng 2026-11-15. Widget so với ngày hiện tại để
  /// biết dữ liệu đã cũ (sang ngày mới mà chưa mở app).
  final String date;

  /// Giờ bắt đầu ngày, để widget tự tính ngày logic.
  final int dayStartHour;

  Map<String, String> toData() => {
        'emoji': emoji,
        'title': title,
        'subtitle': subtitle,
        'tasks': tasks,
        'date': date,
        'day_start_hour': '$dayStartHour',
      };

  @override
  bool operator ==(Object other) =>
      other is WidgetSnapshot &&
      _mapEquals(other.toData(), toData());

  @override
  int get hashCode => Object.hashAll(toData().values);
}

bool _mapEquals(Map<String, String> a, Map<String, String> b) =>
    a.length == b.length && a.keys.every((k) => a[k] == b[k]);

/// Số việc chưa làm hiện trên widget; còn lại gộp thành "+N việc nữa".
const widgetTaskLines = 3;

WidgetSnapshot widgetSnapshot({
  required List<Task> tasks,
  required Map<int, int> todayCounts,
  required DateTime today,
  required int dayStartHour,
  Pet? pet,
  PetStatus? status,
}) {
  final due = tasks.where((t) => isDueToday(t, today)).toList();
  final pending = [
    for (final t in due)
      if (!isTaskDone(t, todayCounts[t.id] ?? 0))
        t.type == TaskType.habit && t.dailyTarget > 1
            ? '${t.title} (${todayCounts[t.id] ?? 0}/${t.dailyTarget})'
            : t.title,
  ];
  final done = due.length - pending.length;
  final progress = 'Hôm nay $done/${due.length} việc';

  final String emoji, title, subtitle;
  if (pet == null || status == null) {
    emoji = '🥚';
    title = 'Linh Thú Kỷ Luật';
    subtitle = progress;
  } else {
    emoji = switch (status.stage) {
      PetStage.egg => '🥚',
      PetStage.baby => '🐾',
      PetStage.adult => switch (pet.branch) {
          TaskElement.fire => '🔥',
          TaskElement.water => '💧',
          TaskElement.wood => '🌿',
          null => '🐾',
        },
    };
    title = status.stage == PetStage.egg
        ? '${pet.name} · Trứng'
        : '${pet.name} · Cấp ${Growth.levelFor(pet.exp)}';
    subtitle = status.stage == PetStage.egg
        ? progress
        : '${status.mood.label} · $progress';
  }

  final String lines;
  if (due.isEmpty) {
    lines = 'Chưa có việc nào cho hôm nay.';
  } else if (pending.isEmpty) {
    lines = 'Xong hết việc hôm nay!';
  } else {
    lines = [
      for (final p in pending.take(widgetTaskLines)) '• $p',
      if (pending.length > widgetTaskLines)
        '+${pending.length - widgetTaskLines} việc nữa',
    ].join('\n');
  }

  return WidgetSnapshot(
    emoji: emoji,
    title: title,
    subtitle: subtitle,
    tasks: lines,
    date: _isoDate(today),
    dayStartHour: dayStartHour,
  );
}

String _isoDate(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}'
    '-${d.day.toString().padLeft(2, '0')}';
