import 'package:drift/drift.dart';

import 'database.dart';

class TaskRepository {
  TaskRepository(this._db);

  final AppDatabase _db;

  /// Các task đang hiện (bỏ việc cần làm đã cất).
  Stream<List<Task>> watchAll() {
    final query = _db.select(_db.tasks)
      ..where((t) => t.archived.not())
      ..orderBy([
        (t) => OrderingTerm(expression: t.sortOrder),
        (t) => OrderingTerm(expression: t.id),
      ]);
    return query.watch();
  }

  Future<int> add(TasksCompanion task) => _db.into(_db.tasks).insert(task);

  Future<void> updateFields(int id, TasksCompanion fields) =>
      (_db.update(_db.tasks)..where((t) => t.id.equals(id))).write(fields);

  Future<void> delete(int id) =>
      (_db.delete(_db.tasks)..where((t) => t.id.equals(id))).go();
}
