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

/// Linh vật rơi ra khi làm việc tốt, theo hệ của task. Bản "ngàn năm" hiếm
/// hơn. Lưu theo tên trong database: đổi tên giá trị cần migration.
enum SpiritItem {
  fireCommon(TaskElement.fire, false, 'Hỏa Linh Quả'),
  fireRare(TaskElement.fire, true, 'Hỏa Linh Quả ngàn năm'),
  waterCommon(TaskElement.water, false, 'Thủy Tinh Lộ'),
  waterRare(TaskElement.water, true, 'Thủy Tinh Lộ ngàn năm'),
  woodCommon(TaskElement.wood, false, 'Mộc Linh Chi'),
  woodRare(TaskElement.wood, true, 'Mộc Linh Chi ngàn năm');

  const SpiritItem(this.element, this.rare, this.label);
  final TaskElement element;
  final bool rare;
  final String label;

  static SpiritItem of(TaskElement element, {required bool rare}) =>
      values.firstWhere((i) => i.element == element && i.rare == rare);
}

/// Loại sự kiện trong nhật ký chấm điểm.
enum LogKind {
  /// Làm xong thói quen tốt, daily hoặc việc cần làm.
  complete,

  /// Làm thói quen xấu.
  bad,

  /// Mua phần thưởng.
  purchase,

  /// Bỏ lỡ một daily vào ngày phải làm. Ghi lúc sang ngày, không hoàn tác,
  /// không có khi đang bế quan. Giờ ghi là cuối ngày bị bỏ lỡ.
  missed,

  /// Nhận quà điểm danh, mỗi ngày một lần. Không gắn với task nào
  /// ([checkInTaskId]); xu và linh vật của quà nằm ở coinsDelta, dropItem.
  checkIn,
}

/// taskId của dòng nhật ký không thuộc task nào, như quà điểm danh.
const checkInTaskId = 0;

/// Boss trong Bí cảnh, theo thứ tự khiêu chiến. Số liệu ở lib/domain/boss.dart.
/// Lưu theo tên trong database: đổi tên giá trị cần migration.
enum BossKind {
  fireWolf('Hắc Hỏa Lang', TaskElement.fire, TaskElement.water),
  iceDragon('Băng Giao', TaskElement.water, TaskElement.wood),
  treeDemon('Thụ Yêu', TaskElement.wood, TaskElement.fire);

  const BossKind(this.label, this.element, this.weakness);
  final String label;
  final TaskElement element;

  /// Việc tốt hệ này gây gấp rưỡi sát thương.
  final TaskElement weakness;
}

/// Giới hạn trên cho "số lần mỗi ngày" của thói quen.
const maxDailyTarget = 20;

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
