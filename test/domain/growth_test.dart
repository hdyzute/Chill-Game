import 'package:flutter_test/flutter_test.dart';
import 'package:linh_thu_ky_luat/data/task_enums.dart';
import 'package:linh_thu_ky_luat/domain/growth.dart';

void main() {
  test('EXP và điểm hệ theo bậc linh vật', () {
    expect(Growth.expOf(SpiritItem.fireCommon), 10);
    expect(Growth.expOf(SpiritItem.waterRare), 30);
    expect(Growth.pointsOf(SpiritItem.woodCommon), 1);
    expect(Growth.pointsOf(SpiritItem.woodRare), 3);
  });

  test('mốc cấp: 20, 60, 120, 200 EXP', () {
    expect([for (var l = 1; l <= 5; l++) Growth.expForLevel(l)],
        [0, 20, 60, 120, 200]);
    expect(Growth.levelFor(0), 1);
    expect(Growth.levelFor(19), 1);
    expect(Growth.levelFor(20), 2);
    expect(Growth.levelFor(199), 4);
    expect(Growth.levelFor(200), 5);
  });

  test('hệ dẫn đầu: điểm cao nhất, hòa theo Hỏa, Thủy, Mộc', () {
    expect(Growth.leadingElement({}), isNull);
    expect(
        Growth.leadingElement({TaskElement.fire: 0, TaskElement.wood: 2}),
        TaskElement.wood);
    expect(
        Growth.leadingElement({TaskElement.water: 3, TaskElement.wood: 3}),
        TaskElement.water);
  });

  test('tiến hóa cần đủ cả cấp và chuỗi ngày', () {
    final points = {TaskElement.fire: 5};
    expect(EvolveCheck(level: 5, streak: 7, points: points).ready, isTrue);
    expect(EvolveCheck(level: 4, streak: 9, points: points).ready, isFalse);
    expect(EvolveCheck(level: 6, streak: 6, points: points).ready, isFalse);
    expect(EvolveCheck(level: 5, streak: 7, points: {}).ready, isFalse);
  });
}
