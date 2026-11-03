import 'package:flutter_test/flutter_test.dart';
import 'package:linh_thu_ky_luat/domain/day.dart';

void main() {
  test('ngày logic với giờ bắt đầu ngày', () {
    expect(logicalDate(DateTime(2026, 11, 4, 0, 30), 0), DateTime(2026, 11, 4));
    expect(logicalDate(DateTime(2026, 11, 4, 3, 59), 4), DateTime(2026, 11, 3));
    expect(logicalDate(DateTime(2026, 11, 4, 4), 4), DateTime(2026, 11, 4));
    // Qua đầu tháng và đầu năm.
    expect(logicalDate(DateTime(2027, 1, 1, 2), 4), DateTime(2026, 12, 31));
  });

  test('mốc bắt đầu hôm nay', () {
    expect(todayStart(DateTime(2026, 11, 4, 3), 4), DateTime(2026, 11, 3, 4));
    expect(todayStart(DateTime(2026, 11, 4, 9), 4), DateTime(2026, 11, 4, 4));
  });

  test('đếm ngày giữa hai ngày', () {
    expect(daysBetween(DateTime(2026, 11, 3), DateTime(2026, 11, 3)), 0);
    expect(daysBetween(DateTime(2026, 10, 30), DateTime(2026, 11, 2)), 3);
  });

  test('lịch lặp theo thứ', () {
    const t2t4t6 = 0x15; // bit 0, 2, 4
    expect(isDueOn(t2t4t6, DateTime(2026, 11, 2)), isTrue); // Thứ 2
    expect(isDueOn(t2t4t6, DateTime(2026, 11, 3)), isFalse); // Thứ 3
    expect(isDueOn(t2t4t6, DateTime(2026, 11, 6)), isTrue); // Thứ 6
    expect(isDueOn(t2t4t6, DateTime(2026, 11, 8)), isFalse); // Chủ nhật
  });
}
