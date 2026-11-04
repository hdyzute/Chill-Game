import 'dart:math';

import '../data/task_enums.dart';

/// Rơi linh vật khi làm việc tốt, học từ Habitica (randomDrop.js) nhưng đơn
/// giản hơn: món theo hệ của task, việc càng khó càng dễ rơi, có giới hạn mỗi
/// ngày để không bấm liên tục cày đồ.
class Drops {
  /// Số linh vật tối đa nhặt được trong một ngày logic.
  static const dailyCap = 5;

  /// Cơ hội rơi với task Dễ; nhân với độ khó (Vừa 75%, Khó 100%).
  static const baseChance = 0.5;

  /// Trong số món rơi, tỉ lệ ra bản "ngàn năm".
  static const rareChance = 0.1;

  /// Linh khí bạo phát thì rơi gấp đôi.
  static const critCount = 2;

  /// Món rơi ở một lần làm việc tốt, hoặc null nếu không rơi gì.
  /// [dropRoll] và [rareRoll] là số ngẫu nhiên trong [0, 1), truyền vào để
  /// test được.
  static Drop? roll({
    required TaskElement? element,
    required Difficulty difficulty,
    required bool critical,
    required int droppedToday,
    required double dropRoll,
    required double rareRoll,
  }) {
    if (element == null) return null;
    final room = dailyCap - droppedToday;
    if (room <= 0) return null;
    if (dropRoll >= baseChance * difficulty.multiplier) return null;
    return Drop(
      SpiritItem.of(element, rare: rareRoll < rareChance),
      min(room, critical ? critCount : 1),
    );
  }
}

class Drop {
  const Drop(this.item, this.count);

  final SpiritItem item;
  final int count;
}

/// "Hỏa Linh Quả" hoặc "2 Hỏa Linh Quả".
String dropLabel(SpiritItem item, int count) =>
    count > 1 ? '$count ${item.label}' : item.label;
