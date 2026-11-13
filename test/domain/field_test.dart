import 'package:flutter_test/flutter_test.dart';
import 'package:linh_thu_ky_luat/data/task_enums.dart';
import 'package:linh_thu_ky_luat/domain/field.dart';

void main() {
  final planted = DateTime(2026, 11, 13, 8);

  PlotState at(DateTime now, {int boosts = 0}) => plotState(
      element: TaskElement.wood, plantedAt: planted, boosts: boosts, now: now);

  test('ô chưa gieo thì trống', () {
    expect(
        plotState(element: null, plantedAt: null, boosts: 0, now: planted),
        isA<EmptyPlot>());
  });

  test('cây lớn dần, chín sau 8 giờ', () {
    final growing = at(planted.add(const Duration(hours: 2))) as GrowingPlot;
    expect(growing.remaining, const Duration(hours: 6));
    expect(growing.progress, closeTo(0.25, 1e-9));
    expect(at(planted.add(Field.growTime)), isA<ReadyPlot>());
  });

  test('mỗi việc tốt cùng hệ giúp chín sớm 1 giờ, không trước lúc gieo', () {
    expect(Field.readyAt(planted, 3), planted.add(const Duration(hours: 5)));
    expect(Field.readyAt(planted, 20), planted);
    expect(at(planted.add(const Duration(hours: 5)), boosts: 3),
        isA<ReadyPlot>());
  });

  test('thu hoạch 2 món cùng hệ, món quý khi số quay dưới 10%', () {
    expect(Field.harvest(TaskElement.fire, [0.5, 0.05]),
        [SpiritItem.fireCommon, SpiritItem.fireRare]);
  });

  test('nhãn thời gian còn lại làm tròn lên phút', () {
    expect(remainingLabel(const Duration(hours: 3, minutes: 20)),
        '3 giờ 20 phút');
    expect(remainingLabel(const Duration(hours: 2)), '2 giờ');
    expect(remainingLabel(const Duration(minutes: 44, seconds: 10)),
        '45 phút');
    expect(remainingLabel(Duration.zero), 'dưới 1 phút');
  });
}
