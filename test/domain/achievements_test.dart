import 'package:flutter_test/flutter_test.dart';
import 'package:linh_thu_ky_luat/domain/achievements.dart';

void main() {
  DateTime d(int day) => DateTime(2026, 11, day);

  group('longestRun', () {
    test('rỗng thì 0, lấy chuỗi dài nhất', () {
      expect(longestRun({}), 0);
      expect(longestRun({d(1)}), 1);
      expect(longestRun({d(1), d(2), d(3), d(5), d(6)}), 3);
      expect(longestRun({d(1), d(3), d(4), d(5), d(6)}), 4);
    });

    test('qua tháng vẫn liền', () {
      expect(longestRun({DateTime(2026, 10, 31), d(1), d(2)}), 3);
    });
  });

  group('perfectDayCount', () {
    test('ngày trước: có việc tốt và không bỏ lỡ', () {
      expect(
        perfectDayCount(
          deedDays: {d(1), d(2), d(3)},
          missedDays: {d(2), d(4)},
          today: d(5),
          todayPerfect: false,
        ),
        2,
      );
    });

    test('hôm nay chỉ tính khi làm đủ daily và có việc tốt', () {
      int count({required bool perfect, required bool deed}) =>
          perfectDayCount(
            deedDays: {if (deed) d(5)},
            missedDays: const {},
            today: d(5),
            todayPerfect: perfect,
          );
      expect(count(perfect: true, deed: true), 1);
      expect(count(perfect: false, deed: true), 0);
      expect(count(perfect: true, deed: false), 0);
    });
  });

  group('tiến độ', () {
    test('mốc đã đạt và mốc kế tiếp', () {
      final p = AchievementProgress(AchievementKind.streak, 8);
      expect(p.reached, 2); // 3 và 7
      expect(p.nextTarget, 21);
      expect(p.complete, isFalse);

      final done = AchievementProgress(AchievementKind.bosses, 12);
      expect(done.reached, 3);
      expect(done.nextTarget, isNull);
      expect(done.complete, isTrue);
    });

    test('đếm tổng số mốc đã mở', () {
      expect(unlockedAchievements(const AchievementStats()), 0);
      expect(
        unlockedAchievements(
            const AchievementStats(deeds: 50, petLevel: 1, bosses: 1)),
        3,
      );
      expect(totalAchievements, 24);
    });

    test('mốc mới mở giữa hai lần tính', () {
      expect(
        newlyUnlocked(const AchievementStats(deeds: 9, longestStreak: 2),
            const AchievementStats(deeds: 51, longestStreak: 2)),
        [
          (kind: AchievementKind.deeds, target: 10),
          (kind: AchievementKind.deeds, target: 50),
        ],
      );
      expect(
        newlyUnlocked(const AchievementStats(deeds: 10),
            const AchievementStats(deeds: 9)),
        isEmpty,
      );
    });

    test('maxWith lấy giá trị lớn hơn từng số liệu', () {
      expect(
        const AchievementStats(deeds: 5, bosses: 2)
            .maxWith(const AchievementStats(deeds: 3, bosses: 4)),
        const AchievementStats(deeds: 5, bosses: 4),
      );
    });

    test('mô tả mốc', () {
      expect(AchievementKind.streak.goal(21), '21 ngày liên tiếp có việc tốt');
      expect(AchievementKind.checkIns.goal(7), 'Điểm danh 7 ngày');
    });
  });
}
