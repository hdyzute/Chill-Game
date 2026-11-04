import 'package:drift/drift.dart';

import 'database.dart';

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

  /// Thời điểm của mọi lần làm việc tốt, để tính chuỗi ngày.
  Stream<List<DateTime>> watchCompletionTimes() {
    final query = _db.selectOnly(_db.taskLogs)
      ..addColumns([_db.taskLogs.createdAt])
      ..where(_db.taskLogs.kind.equalsValue(LogKind.complete));
    return query
        .watch()
        .map((rows) => [for (final r in rows) r.read(_db.taskLogs.createdAt)!]);
  }
}
