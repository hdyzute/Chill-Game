/// Tính toán cho tab Lịch sử. Thuần Dart, nhận nhật ký đã đọc từ database.
library;

import '../data/database.dart';
import 'day.dart';

/// Gom nhật ký theo ngày logic (nửa đêm của ngày đó), giữ thứ tự thời gian.
Map<DateTime, List<TaskLog>> groupByDay(
    Iterable<TaskLog> logs, int dayStartHour) {
  final days = <DateTime, List<TaskLog>>{};
  for (final log in logs) {
    days.putIfAbsent(logicalDate(log.createdAt, dayStartHour), () => []).add(log);
  }
  return days;
}

int completionsOf(Iterable<TaskLog> logs) =>
    logs.where((l) => l.kind == LogKind.complete).length;

/// Độ đậm của ô lịch (0–4) theo số việc tốt đã làm trong ngày.
int heatLevel(int completions) => switch (completions) {
      0 => 0,
      1 => 1,
      <= 3 => 2,
      <= 5 => 3,
      _ => 4,
    };

/// Số ngày liên tiếp có ít nhất một việc tốt, tính lùi từ [today]. Hôm nay
/// chưa làm gì thì chuỗi vẫn giữ (tính tới hôm qua), vì ngày chưa kết thúc.
int activeStreak(Set<DateTime> activeDays, DateTime today) {
  var day = activeDays.contains(today) ? today : addDays(today, -1);
  var streak = 0;
  while (activeDays.contains(day)) {
    streak++;
    day = addDays(day, -1);
  }
  return streak;
}

class MonthStats {
  const MonthStats({
    required this.completions,
    required this.coinsEarned,
    required this.byElement,
  });

  final int completions;

  /// Xu nhận được từ việc tốt (không trừ phần đã tiêu cho phần thưởng).
  final int coinsEarned;

  /// Số việc tốt theo hệ. Bỏ qua dòng không rõ hệ.
  final Map<TaskElement, int> byElement;
}

MonthStats monthStats(Iterable<TaskLog> logs) {
  var completions = 0;
  var coins = 0;
  final byElement = <TaskElement, int>{};
  for (final log in logs) {
    if (log.kind != LogKind.complete) continue;
    completions++;
    coins += log.coinsDelta;
    final element = log.element;
    if (element != null) byElement[element] = (byElement[element] ?? 0) + 1;
  }
  return MonthStats(
      completions: completions, coinsEarned: coins, byElement: byElement);
}

/// Ngày 1 của tháng chứa [date].
DateTime monthOf(DateTime date) => DateTime(date.year, date.month);

/// Các ô của lịch tháng, tuần bắt đầu từ Thứ Hai. Ô trống ở đầu và cuối là
/// null; tổng số ô là bội của 7.
List<DateTime?> monthGrid(DateTime month) {
  final first = monthOf(month);
  final daysInMonth = DateTime(first.year, first.month + 1, 0).day;
  final cells = <DateTime?>[
    for (var i = 1; i < first.weekday; i++) null,
    for (var d = 1; d <= daysInMonth; d++) DateTime(first.year, first.month, d),
  ];
  while (cells.length % 7 != 0) {
    cells.add(null);
  }
  return cells;
}

const weekdayNames = [
  'Thứ Hai',
  'Thứ Ba',
  'Thứ Tư',
  'Thứ Năm',
  'Thứ Sáu',
  'Thứ Bảy',
  'Chủ nhật',
];

String monthLabel(DateTime month) => 'Tháng ${month.month}, ${month.year}';

String dayLabel(DateTime date) =>
    '${weekdayNames[date.weekday - 1]}, ${date.day}/${date.month}';

String timeLabel(DateTime time) =>
    '${time.hour.toString().padLeft(2, '0')}:'
    '${time.minute.toString().padLeft(2, '0')}';
