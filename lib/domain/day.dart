/// Mọi khái niệm "hôm nay" của app đều đi qua file này.
///
/// "Ngày logic" bắt đầu lúc [dayStartHour] giờ, không phải nửa đêm: với
/// dayStartHour = 4 thì 2 giờ sáng thứ Ba vẫn là ngày thứ Hai.
library;

/// Ngày logic chứa thời điểm [now], trả về nửa đêm của ngày đó.
DateTime logicalDate(DateTime now, int dayStartHour) {
  final date = DateTime(now.year, now.month, now.day);
  return now.hour < dayStartHour ? addDays(date, -1) : date;
}

/// Thời điểm bắt đầu của ngày logic [date].
DateTime dayStartInstant(DateTime date, int dayStartHour) =>
    DateTime(date.year, date.month, date.day, dayStartHour);

/// Thời điểm bắt đầu của ngày logic đang chứa [now].
DateTime todayStart(DateTime now, int dayStartHour) =>
    dayStartInstant(logicalDate(now, dayStartHour), dayStartHour);

/// Cộng ngày theo lịch (không cộng 24 giờ, để an toàn khi đổi giờ mùa hè).
DateTime addDays(DateTime date, int days) =>
    DateTime(date.year, date.month, date.day + days);

/// Số ngày lịch từ [from] tới [to].
int daysBetween(DateTime from, DateTime to) =>
    DateTime.utc(to.year, to.month, to.day)
        .difference(DateTime.utc(from.year, from.month, from.day))
        .inDays;

/// Daily có lịch [repeatDays] (bit 0 = Thứ 2) có phải làm vào [date] không.
bool isDueOn(int repeatDays, DateTime date) =>
    repeatDays & (1 << (date.weekday - 1)) != 0;
