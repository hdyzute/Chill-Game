import 'package:flutter_test/flutter_test.dart';
import 'package:linh_thu_ky_luat/data/task_enums.dart';
import 'package:linh_thu_ky_luat/domain/pet.dart';

void main() {
  final contract = DateTime(2026, 11, 4);
  DateTime day(int d) => DateTime(2026, 11, d);

  test('mới ký khế ước, chưa có việc tốt: trứng 0 ngày', () {
    final s = petStatus(contractDay: contract, deedDays: {}, today: contract);
    expect(s.stage, PetStage.egg);
    expect(s.hatchProgress, 0);
    expect(s.hatchedOn, isNull);
    expect(s.daysTogether, 1);
    expect(s.deedToday, isFalse);
  });

  test('việc tốt trước ngày ký khế ước không được tính', () {
    final s = petStatus(
        contractDay: contract, deedDays: {day(2), day(3)}, today: contract);
    expect(s.hatchProgress, 0);
  });

  test('việc tốt đầu tiên ngay ngày ký khế ước làm trứng nở luôn', () {
    final s = petStatus(
        contractDay: contract, deedDays: {day(4)}, today: contract);
    expect(s.stage, PetStage.baby);
    expect(s.hatchProgress, hatchDays);
    expect(s.hatchedOn, contract);
    expect(s.deedToday, isTrue);
  });

  test('ngày nở là ngày có việc tốt đầu tiên, các ngày sau không đổi nó', () {
    final s = petStatus(
        contractDay: contract,
        deedDays: {day(2), day(6), day(9)},
        today: day(10));
    expect(s.stage, PetStage.baby);
    expect(s.hatchedOn, day(6));
    expect(s.daysTogether, 7);
    expect(s.deedToday, isFalse);
  });

  test('trứng nở và tiến hóa: giai đoạn theo nhánh đã chốt', () {
    final baby = petStatus(
        contractDay: contract, deedDays: {day(4)}, today: contract);
    expect(baby.stage, PetStage.baby);
    final adult = petStatus(
        contractDay: contract,
        deedDays: {day(4)},
        today: contract,
        branch: TaskElement.water);
    expect(adult.stage, PetStage.adult);
    final egg = petStatus(
        contractDay: contract,
        deedDays: {},
        today: contract,
        branch: TaskElement.water);
    expect(egg.stage, PetStage.egg);
  });

  group('tâm trạng', () {
    PetMood mood({
      bool today = false,
      bool yesterday = false,
      int good = 0,
      int bad = 0,
      bool resting = false,
    }) =>
        petMood(
          deedToday: today,
          deedYesterday: yesterday,
          goodToday: good,
          badToday: bad,
          resting: resting,
        );

    test('có việc tốt hôm nay thì vui', () {
      expect(mood(today: true, good: 2), PetMood.happy);
    });

    test('hôm nay chưa làm nhưng hôm qua có thì bình thường', () {
      expect(mood(yesterday: true), PetMood.calm);
    });

    test('hôm qua và hôm nay đều trống thì buồn, trừ khi đang bế quan', () {
      expect(mood(), PetMood.sad);
      expect(mood(resting: true), PetMood.calm);
    });

    test('việc xấu nhiều bằng việc tốt thì mệt', () {
      expect(mood(today: true, good: 1, bad: 1), PetMood.tired);
      expect(mood(bad: 1, yesterday: true), PetMood.tired);
      expect(mood(today: true, good: 2, bad: 1), PetMood.happy);
    });

    test('petStatus dùng ngày hôm qua và số việc hôm nay', () {
      final s = petStatus(
          contractDay: contract,
          deedDays: {day(4)},
          today: day(6),
          badToday: 0);
      expect(s.mood, PetMood.sad);
      final t = petStatus(
          contractDay: contract,
          deedDays: {day(4), day(5)},
          today: day(6));
      expect(t.mood, PetMood.calm);
    });
  });

  test('câu thoại theo tâm trạng', () {
    PetStatus status(PetStage stage, PetMood mood, {bool resting = false}) =>
        PetStatus(
            stage: stage,
            hatchProgress: stage == PetStage.egg ? 0 : hatchDays,
            hatchedOn: stage == PetStage.egg ? null : contract,
            daysTogether: 1,
            deedToday: mood == PetMood.happy,
            mood: mood,
            resting: resting);
    expect(petLine(status(PetStage.egg, PetMood.sad), 'Mochi'),
        contains('nằm im'));
    expect(petLine(status(PetStage.baby, PetMood.happy), 'Mochi'),
        'Mochi vui vẻ quấn quýt bên bạn.');
    expect(petLine(status(PetStage.baby, PetMood.calm), 'Mochi'),
        'Mochi đang chờ việc tốt đầu tiên của bạn hôm nay.');
    expect(petLine(status(PetStage.adult, PetMood.calm, resting: true), 'Mochi'),
        contains('bế quan'));
    expect(petLine(status(PetStage.baby, PetMood.sad), 'Mochi'),
        contains('buồn'));
    expect(petLine(status(PetStage.baby, PetMood.tired), 'Mochi'),
        contains('mệt'));
  });
}
