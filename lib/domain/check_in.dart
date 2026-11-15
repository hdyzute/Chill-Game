/// Quà điểm danh theo bậc, học từ quà đăng nhập của Habitica: mỗi ngày
/// (logic) nhận một lần, quà theo vòng 7 ngày, ngày 7 có quà lớn. Đếm tổng
/// số lần điểm danh, không cần liên tiếp: bỏ một ngày không mất bậc.
library;

import '../data/task_enums.dart';

class CheckInGift {
  const CheckInGift({this.coins = 0, this.item, this.itemCount = 0});

  final int coins;
  final SpiritItem? item;
  final int itemCount;

  @override
  bool operator ==(Object other) =>
      other is CheckInGift &&
      other.coins == coins &&
      other.item == item &&
      other.itemCount == itemCount;

  @override
  int get hashCode => Object.hash(coins, item, itemCount);
}

class CheckIn {
  static const cycle = 7;

  /// Ngày trong vòng (1 tới [cycle]) của lần điểm danh thứ [number].
  static int dayInCycle(int number) => (number - 1) % cycle + 1;

  /// Quà của lần điểm danh thứ [number] (từ 1). Linh vật đổi hệ lần lượt
  /// Hỏa, Thủy, Mộc theo [number].
  static CheckInGift giftFor(int number) {
    final element = TaskElement.values[(number - 1) % TaskElement.values.length];
    final common = SpiritItem.of(element, rare: false);
    return switch (dayInCycle(number)) {
      1 => const CheckInGift(coins: 5),
      2 => CheckInGift(item: common, itemCount: 1),
      3 => const CheckInGift(coins: 10),
      4 => CheckInGift(item: common, itemCount: 1),
      5 => const CheckInGift(coins: 15),
      6 => CheckInGift(item: common, itemCount: 2),
      _ => CheckInGift(
          coins: 20, item: SpiritItem.of(element, rare: true), itemCount: 1),
    };
  }
}

/// Mô tả quà, ví dụ "20 xu và 1 Hỏa Linh Quả ngàn năm".
String giftLabel(CheckInGift gift) {
  final item = gift.item;
  final parts = [
    if (gift.coins > 0) '${gift.coins} xu',
    if (item != null && gift.itemCount > 0) '${gift.itemCount} ${item.label}',
  ];
  return parts.join(' và ');
}
