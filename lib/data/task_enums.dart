/// Các loại task, giống Habitica.
enum TaskType {
  habit('Thói quen'),
  daily('Hằng ngày'),
  todo('Việc cần làm'),
  reward('Phần thưởng');

  const TaskType(this.label);
  final String label;
}

/// Độ khó nhân vào mọi phần thưởng.
enum Difficulty {
  easy('Dễ', 1.0),
  medium('Vừa', 1.5),
  hard('Khó', 2.0);

  const Difficulty(this.label, this.multiplier);
  final String label;
  final double multiplier;
}

/// Hệ của task, quyết định nhánh tiến hóa của linh thú.
enum TaskElement {
  fire('Hỏa', 'Vận động, sức khỏe'),
  water('Thủy', 'Học tập, đọc sách'),
  wood('Mộc', 'Tinh thần, nghỉ ngơi');

  const TaskElement(this.label, this.hint);
  final String label;
  final String hint;
}

/// Bit 0 = Thứ 2 ... bit 6 = Chủ nhật.
const weekdayLabels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
const everyDayMask = 0x7f;

String describeRepeatDays(int mask) {
  if (mask == everyDayMask) return 'Mỗi ngày';
  return [
    for (var i = 0; i < 7; i++)
      if (mask & (1 << i) != 0) weekdayLabels[i],
  ].join(', ');
}
