import 'package:flutter_test/flutter_test.dart';
import 'package:linh_thu_ky_luat/data/database.dart';
import 'package:linh_thu_ky_luat/domain/history.dart';

void main() {
  var nextId = 1;
  TaskLog log(DateTime at,
          {LogKind kind = LogKind.complete,
          int coins = 10,
          TaskElement? element = TaskElement.fire}) =>
      TaskLog(
        id: nextId++,
        taskId: 1,
        kind: kind,
        valueDelta: 0,
        coinsDelta: coins,
        streakDelta: 0,
        critical: false,
        createdAt: at,
        title: 'Chạy bộ',
        element: element,
        dropCount: 0,
      );

  test('gom theo ngày logic: 2 giờ sáng thuộc hôm trước khi ngày bắt đầu 4:00',
      () {
    final days = groupByDay([
      log(DateTime(2026, 11, 3, 22)),
      log(DateTime(2026, 11, 4, 2)),
      log(DateTime(2026, 11, 4, 9)),
    ], 4);

    expect(days.keys, [DateTime(2026, 11, 3), DateTime(2026, 11, 4)]);
    expect(days[DateTime(2026, 11, 3)], hasLength(2));
    expect(days[DateTime(2026, 11, 4)], hasLength(1));
  });

  test('chỉ đếm việc tốt, không đếm thói quen xấu và phần thưởng', () {
    expect(
      completionsOf([
        log(DateTime(2026, 11, 3, 9)),
        log(DateTime(2026, 11, 3, 10), kind: LogKind.bad, coins: 0),
        log(DateTime(2026, 11, 3, 11), kind: LogKind.purchase, coins: -30),
      ]),
      1,
    );
  });

  test('độ đậm ô lịch tăng theo số việc tốt', () {
    expect([0, 1, 2, 3, 4, 5, 6, 20].map(heatLevel), [0, 1, 2, 2, 3, 3, 4, 4]);
  });

  group('chuỗi ngày', () {
    final today = DateTime(2026, 11, 4);
    Set<DateTime> days(List<int> dayOfMonth) =>
        {for (final d in dayOfMonth) DateTime(2026, 11, d)};

    test('đếm lùi từ hôm nay', () {
      expect(activeStreak(days([2, 3, 4]), today), 3);
    });

    test('hôm nay chưa làm thì vẫn giữ chuỗi tới hôm qua', () {
      expect(activeStreak(days([1, 2, 3]), today), 3);
    });

    test('bỏ một ngày thì chuỗi tính lại', () {
      expect(activeStreak(days([1, 3, 4]), today), 2);
      expect(activeStreak(days([1, 2]), today), 0);
    });

    test('nối qua đầu tháng', () {
      final set = {DateTime(2026, 10, 31), DateTime(2026, 11, 1)};
      expect(activeStreak(set, DateTime(2026, 11, 1)), 2);
    });
  });

  test('thống kê tháng: chỉ cộng xu từ việc tốt, đếm theo hệ', () {
    final stats = monthStats([
      log(DateTime(2026, 11, 1, 9), coins: 12),
      log(DateTime(2026, 11, 2, 9), coins: 8, element: TaskElement.water),
      log(DateTime(2026, 11, 2, 10), coins: 5, element: null),
      log(DateTime(2026, 11, 2, 11), kind: LogKind.purchase, coins: -30),
      log(DateTime(2026, 11, 2, 12), kind: LogKind.bad, coins: 0),
    ]);

    expect(stats.completions, 3);
    expect(stats.coinsEarned, 25);
    expect(stats.byElement,
        {TaskElement.fire: 1, TaskElement.water: 1});
  });

  test('lịch tháng 11/2026 bắt đầu Chủ nhật: 6 ô trống đầu, đủ 6 tuần', () {
    final cells = monthGrid(DateTime(2026, 11, 17));

    expect(cells, hasLength(42));
    expect(cells.take(6), everyElement(isNull));
    expect(cells[6], DateTime(2026, 11, 1));
    expect(cells[35], DateTime(2026, 11, 30));
    expect(cells.skip(36), everyElement(isNull));
  });

  test('lịch tháng 2/2027 bắt đầu Thứ Hai: không có ô trống', () {
    final cells = monthGrid(DateTime(2027, 2));
    expect(cells, hasLength(28));
    expect(cells.first, DateTime(2027, 2, 1));
  });

  test('nhãn tiếng Việt', () {
    expect(monthLabel(DateTime(2026, 11)), 'Tháng 11, 2026');
    expect(dayLabel(DateTime(2026, 11, 3)), 'Thứ Ba, 3/11');
    expect(timeLabel(DateTime(2026, 11, 3, 7, 5)), '07:05');
  });
}
