import 'package:flutter_test/flutter_test.dart';
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

  test('câu thoại theo giai đoạn và việc hôm nay', () {
    PetStatus status(PetStage stage, bool deed) => PetStatus(
        stage: stage,
        hatchProgress: stage == PetStage.egg ? 0 : hatchDays,
        hatchedOn: stage == PetStage.egg ? null : contract,
        daysTogether: 1,
        deedToday: deed);
    expect(petLine(status(PetStage.egg, false), 'Mochi'), contains('nằm im'));
    expect(petLine(status(PetStage.baby, true), 'Mochi'),
        'Mochi vui vẻ quấn quýt bên bạn.');
    expect(petLine(status(PetStage.baby, false), 'Mochi'),
        'Mochi đang chờ việc tốt đầu tiên của bạn hôm nay.');
  });
}
