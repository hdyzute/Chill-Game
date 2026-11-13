/// Linh điền: gieo hạt bằng xu, cây lớn theo giờ thật, thu hoạch ra linh vật.
/// Việc tốt cùng hệ làm sau khi gieo giúp cây chín sớm hơn; số lần đó tính từ
/// nhật ký nên bỏ tick hay hoàn tác vẫn khớp.
library;

import 'dart:math';

import '../data/task_enums.dart';
import 'drops.dart';

class Field {
  /// Số ô đất.
  static const plots = 3;

  /// Giá một hạt giống, bằng xu.
  static const seedCost = 15;

  /// Thời gian cây chín khi không có việc tốt cùng hệ nào.
  static const growTime = Duration(hours: 8);

  /// Mỗi việc tốt cùng hệ sau khi gieo rút ngắn chừng này.
  static const deedBoost = Duration(hours: 1);

  /// Số linh vật mỗi lần thu hoạch. Mỗi món tự quay ra bản quý.
  static const harvestCount = 2;

  /// Lúc cây chín, khi đã có [boosts] việc tốt cùng hệ.
  static DateTime readyAt(DateTime plantedAt, int boosts) {
    final wait = growTime - deedBoost * boosts;
    return wait.isNegative ? plantedAt : plantedAt.add(wait);
  }

  /// Linh vật thu được; [rareRolls] là [harvestCount] số ngẫu nhiên trong
  /// [0, 1), truyền vào để test được.
  static List<SpiritItem> harvest(TaskElement element, List<double> rareRolls) =>
      [
        for (final roll in rareRolls.take(harvestCount))
          SpiritItem.of(element, rare: roll < Drops.rareChance),
      ];
}

/// Trạng thái một ô lúc [now].
sealed class PlotState {
  const PlotState();
}

class EmptyPlot extends PlotState {
  const EmptyPlot();
}

class GrowingPlot extends PlotState {
  const GrowingPlot(this.element, this.remaining, this.progress);

  final TaskElement element;
  final Duration remaining;

  /// Từ 0 tới 1.
  final double progress;
}

class ReadyPlot extends PlotState {
  const ReadyPlot(this.element);

  final TaskElement element;
}

/// [element] và [plantedAt] null nghĩa là ô trống.
PlotState plotState({
  required TaskElement? element,
  required DateTime? plantedAt,
  required int boosts,
  required DateTime now,
}) {
  if (element == null || plantedAt == null) return const EmptyPlot();
  final ready = Field.readyAt(plantedAt, boosts);
  if (!now.isBefore(ready)) return ReadyPlot(element);
  final total = ready.difference(plantedAt);
  final remaining = ready.difference(now);
  return GrowingPlot(
    element,
    remaining,
    max(0, 1 - remaining.inSeconds / total.inSeconds),
  );
}

/// "3 giờ 20 phút", "45 phút", "dưới 1 phút".
String remainingLabel(Duration d) {
  // Làm tròn lên phút, để không hiện "0 phút" khi còn vài giây.
  final minutes = (d.inSeconds / 60).ceil();
  if (minutes < 1) return 'dưới 1 phút';
  final h = minutes ~/ 60, m = minutes % 60;
  if (h == 0) return '$m phút';
  return m == 0 ? '$h giờ' : '$h giờ $m phút';
}
