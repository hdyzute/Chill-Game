import 'package:drift/drift.dart';

import 'database.dart';

/// Một lần làm việc tốt: lúc nào, thuộc hệ nào (null nếu task không có hệ).
typedef Completion = ({DateTime at, TaskElement? element});

/// Đọc nhật ký chấm điểm cho tab Lịch sử. Chỉ đọc; ghi qua ScoreService.
class HistoryRepository {
  HistoryRepository(this._db);

  final AppDatabase _db;

  /// Nhật ký trong khoảng [from, to), theo thứ tự thời gian.
  Stream<List<TaskLog>> watchBetween(DateTime from, DateTime to) {
    final query = _db.select(_db.taskLogs)
      ..where((l) =>
          l.createdAt.isBiggerOrEqualValue(from) &
          l.createdAt.isSmallerThanValue(to))
      ..orderBy([
        (l) => OrderingTerm(expression: l.createdAt),
        (l) => OrderingTerm(expression: l.id),
      ]);
    return query.watch();
  }

  /// Thời điểm và hệ của mọi lần làm việc tốt, để tính chuỗi ngày và độ
  /// lớn của cây trên Linh điền.
  Stream<List<Completion>> watchCompletions() {
    final logs = _db.taskLogs;
    final query = _db.selectOnly(logs)
      ..addColumns([logs.createdAt, logs.element])
      ..where(logs.kind.equalsValue(LogKind.complete));
    return query.watch().map((rows) => [
          for (final r in rows)
            (
              at: r.read(logs.createdAt)!,
              element: r.readWithConverter<TaskElement?, String>(logs.element),
            ),
        ]);
  }
}
