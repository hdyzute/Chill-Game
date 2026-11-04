import 'package:flutter_test/flutter_test.dart';
import 'package:linh_thu_ky_luat/data/task_enums.dart';
import 'package:linh_thu_ky_luat/domain/drops.dart';

void main() {
  Drop? roll({
    TaskElement? element = TaskElement.water,
    Difficulty difficulty = Difficulty.easy,
    bool critical = false,
    int droppedToday = 0,
    double dropRoll = 0.1,
    double rareRoll = 0.9,
  }) =>
      Drops.roll(
        element: element,
        difficulty: difficulty,
        critical: critical,
        droppedToday: droppedToday,
        dropRoll: dropRoll,
        rareRoll: rareRoll,
      );

  test('rơi một món thường theo hệ của task', () {
    final drop = roll()!;
    expect(drop.item, SpiritItem.waterCommon);
    expect(drop.count, 1);
  });

  test('cơ hội rơi theo độ khó: Dễ 50%, Vừa 75%, Khó luôn rơi', () {
    expect(roll(dropRoll: 0.6), isNull);
    expect(roll(dropRoll: 0.6, difficulty: Difficulty.medium), isNotNull);
    expect(roll(dropRoll: 0.8, difficulty: Difficulty.medium), isNull);
    expect(roll(dropRoll: 0.99, difficulty: Difficulty.hard), isNotNull);
  });

  test('món quý khi rareRoll dưới 10%', () {
    expect(roll(rareRoll: 0.05)!.item, SpiritItem.waterRare);
  });

  test('bạo kích rơi 2 món, nhưng không vượt giới hạn ngày', () {
    expect(roll(critical: true)!.count, 2);
    expect(roll(critical: true, droppedToday: Drops.dailyCap - 1)!.count, 1);
  });

  test('đủ giới hạn ngày hoặc task không có hệ thì không rơi', () {
    expect(roll(droppedToday: Drops.dailyCap), isNull);
    expect(roll(element: null), isNull);
  });

  test('nhãn có số lượng khi nhiều hơn 1', () {
    expect(dropLabel(SpiritItem.fireCommon, 1), 'Hỏa Linh Quả');
    expect(dropLabel(SpiritItem.woodRare, 2), '2 Mộc Linh Chi ngàn năm');
  });
}
