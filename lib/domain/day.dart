/// Mốc bắt đầu "hôm nay" theo giờ máy.
///
/// Hiện là nửa đêm. Bước 1.3 sẽ thêm giờ bắt đầu ngày tùy chỉnh
/// (cho người thức khuya), lúc đó chỉ cần sửa ở đây.
DateTime startOfDay(DateTime now) => DateTime(now.year, now.month, now.day);
