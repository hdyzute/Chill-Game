import 'package:flutter_test/flutter_test.dart';
import 'package:linh_thu_ky_luat/data/task_enums.dart';
import 'package:linh_thu_ky_luat/domain/check_in.dart';

void main() {
  test('vòng 7 ngày, hết vòng thì lặp lại', () {
    expect([for (var n = 1; n <= 9; n++) CheckIn.dayInCycle(n)],
        [1, 2, 3, 4, 5, 6, 7, 1, 2]);
  });

  test('quà từng ngày trong vòng', () {
    expect(CheckIn.giftFor(1), const CheckInGift(coins: 5));
    expect(CheckIn.giftFor(2),
        const CheckInGift(item: SpiritItem.waterCommon, itemCount: 1));
    expect(CheckIn.giftFor(3), const CheckInGift(coins: 10));
    expect(CheckIn.giftFor(4),
        const CheckInGift(item: SpiritItem.fireCommon, itemCount: 1));
    expect(CheckIn.giftFor(5), const CheckInGift(coins: 15));
    expect(CheckIn.giftFor(6),
        const CheckInGift(item: SpiritItem.woodCommon, itemCount: 2));
    expect(CheckIn.giftFor(7),
        const CheckInGift(coins: 20, item: SpiritItem.fireRare, itemCount: 1));
    expect(CheckIn.giftFor(8), const CheckInGift(coins: 5));
  });

  test('mô tả quà', () {
    expect(giftLabel(CheckIn.giftFor(1)), '5 xu');
    expect(giftLabel(CheckIn.giftFor(6)), '2 Mộc Linh Chi');
    expect(giftLabel(CheckIn.giftFor(7)), '20 xu và 1 Hỏa Linh Quả ngàn năm');
  });
}
