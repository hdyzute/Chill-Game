/// Linh thú: giai đoạn, tiến độ ấp trứng và tâm trạng, tính từ những ngày có
/// việc tốt. Không lưu riêng, nên bỏ tick hay hoàn tác luôn khớp. Chỉ nhánh
/// tiến hóa được lưu, vì nó được chốt lúc tiến hóa.
library;

import 'dart:math';

import '../data/task_enums.dart';
import 'day.dart';

enum PetStage {
  egg('Trứng'),
  baby('Ấu thú'),
  adult('Trưởng thành');

  const PetStage(this.label);

  final String label;
}

/// Tâm trạng: chỉ đổi câu thoại và hình, không bao giờ làm linh thú chết.
enum PetMood {
  happy('Vui'),
  calm('Bình thường'),
  sad('Buồn'),
  tired('Mệt');

  const PetMood(this.label);

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
    this.mood = PetMood.calm,
    this.resting = false,
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

  final PetMood mood;

  /// Người dùng đang bế quan.
  final bool resting;
}

/// [contractDay], [today] và các phần tử của [deedDays] là ngày logic.
/// [goodToday] và [badToday] là số việc tốt, việc xấu hôm nay.
PetStatus petStatus({
  required DateTime contractDay,
  required Set<DateTime> deedDays,
  required DateTime today,
  TaskElement? branch,
  int goodToday = 0,
  int badToday = 0,
  bool resting = false,
}) {
  final counted = deedDays
      .where((d) => !d.isBefore(contractDay) && !d.isAfter(today))
      .toList()
    ..sort();
  final hatchedOn = counted.length >= hatchDays ? counted[hatchDays - 1] : null;
  final deedToday = deedDays.contains(today);
  return PetStatus(
    stage: switch ((hatchedOn, branch)) {
      (null, _) => PetStage.egg,
      (_, null) => PetStage.baby,
      _ => PetStage.adult,
    },
    hatchProgress: min(counted.length, hatchDays),
    hatchedOn: hatchedOn,
    daysTogether: daysBetween(contractDay, today) + 1,
    deedToday: deedToday,
    mood: petMood(
      deedToday: deedToday,
      deedYesterday: deedDays.contains(addDays(today, -1)),
      goodToday: goodToday,
      badToday: badToday,
      resting: resting,
    ),
    resting: resting,
  );
}

/// Việc xấu nhiều bằng việc tốt thì mệt; có việc tốt hôm nay thì vui; hôm
/// qua có việc tốt (hoặc đang bế quan) thì bình thường; còn lại thì buồn.
PetMood petMood({
  required bool deedToday,
  required bool deedYesterday,
  required int goodToday,
  required int badToday,
  required bool resting,
}) {
  if (badToday > 0 && badToday >= goodToday) return PetMood.tired;
  if (deedToday) return PetMood.happy;
  if (deedYesterday || resting) return PetMood.calm;
  return PetMood.sad;
}

/// Câu linh thú "nói" trên màn hình nhà, theo tâm trạng.
String petLine(PetStatus status, String name) => switch (status) {
      PetStatus(stage: PetStage.egg) =>
        'Quả trứng nằm im, chờ linh khí từ việc tốt đầu tiên của bạn.',
      PetStatus(mood: PetMood.tired) =>
        '$name thấy mệt vì thói quen xấu hôm nay. Làm một việc tốt cho nó '
            'khỏe lại nhé.',
      PetStatus(mood: PetMood.happy) => '$name vui vẻ quấn quýt bên bạn.',
      PetStatus(mood: PetMood.calm, resting: true) =>
        '$name đang bế quan cùng bạn, cứ nghỉ ngơi nhé.',
      PetStatus(mood: PetMood.calm) =>
        '$name đang chờ việc tốt đầu tiên của bạn hôm nay.',
      PetStatus(mood: PetMood.sad) =>
        '$name hơi buồn vì hôm qua vắng bạn. Một việc tốt sẽ làm nó vui lại.',
    };
