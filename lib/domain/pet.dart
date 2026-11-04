/// Linh thú: giai đoạn và tiến độ ấp trứng, tính hoàn toàn từ những ngày có
/// việc tốt. Không lưu trạng thái riêng, nên bỏ tick hay hoàn tác luôn khớp.
library;

import 'dart:math';

import 'day.dart';

enum PetStage {
  egg('Trứng'),
  baby('Ấu thú');

  const PetStage(this.label);

  final String label;
}

/// Số ngày có làm việc tốt (tính từ ngày ký khế ước) để trứng nở. Để 1 cho
/// người mới thấy linh thú ngay từ việc tốt đầu tiên, chờ lâu dễ bỏ app.
const hatchDays = 1;

class PetStatus {
  const PetStatus({
    required this.stage,
    required this.hatchProgress,
    required this.hatchedOn,
    required this.daysTogether,
    required this.deedToday,
  });

  final PetStage stage;

  /// Số ngày đã ấp, từ 0 tới [hatchDays].
  final int hatchProgress;

  /// Ngày trứng nở: ngày có việc tốt thứ [hatchDays]. Null khi còn là trứng.
  final DateTime? hatchedOn;

  /// Số ngày bên nhau, tính cả ngày ký khế ước.
  final int daysTogether;

  /// Hôm nay đã làm ít nhất một việc tốt chưa.
  final bool deedToday;
}

/// [contractDay], [today] và các phần tử của [deedDays] là ngày logic.
PetStatus petStatus({
  required DateTime contractDay,
  required Set<DateTime> deedDays,
  required DateTime today,
}) {
  final counted = deedDays
      .where((d) => !d.isBefore(contractDay) && !d.isAfter(today))
      .toList()
    ..sort();
  final hatchedOn = counted.length >= hatchDays ? counted[hatchDays - 1] : null;
  return PetStatus(
    stage: hatchedOn == null ? PetStage.egg : PetStage.baby,
    hatchProgress: min(counted.length, hatchDays),
    hatchedOn: hatchedOn,
    daysTogether: daysBetween(contractDay, today) + 1,
    deedToday: deedDays.contains(today),
  );
}

/// Câu linh thú "nói" trên màn hình nhà, theo việc tốt hôm nay.
String petLine(PetStatus status, String name) => switch (status) {
      PetStatus(stage: PetStage.egg) =>
        'Quả trứng nằm im, chờ linh khí từ việc tốt đầu tiên của bạn.',
      PetStatus(deedToday: true) => '$name vui vẻ quấn quýt bên bạn.',
      _ => '$name đang chờ việc tốt đầu tiên của bạn hôm nay.',
    };
