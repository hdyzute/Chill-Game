import 'package:drift/drift.dart';

import '../domain/growth.dart';
import 'database.dart';

/// Linh thú của người dùng. Bản đầu chỉ có một con.
class PetRepository {
  PetRepository(this._db, {DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _clock;

  /// Linh thú đầu tiên, null khi chưa ký khế ước.
  Stream<Pet?> watch() => (_db.select(_db.pets)
        ..orderBy([(p) => OrderingTerm(expression: p.id)])
        ..limit(1))
      .watchSingleOrNull();

  /// Ký khế ước. Đã có linh thú thì ném [StateError] (bấm hai lần quá nhanh).
  Future<void> create(String name) => _db.transaction(() async {
        final existing = await _db.select(_db.pets).get();
        if (existing.isNotEmpty) throw StateError('Đã có linh thú');
        await _db.into(_db.pets).insert(PetsCompanion.insert(
              name: name.trim(),
              createdAt: _clock(),
            ));
      });

  /// Tiến hóa thành Trưởng thành theo [branch]. Nhánh được chốt, không đổi
  /// lại được; gọi lần nữa thì không làm gì.
  Future<void> evolve(int id, TaskElement branch) =>
      (_db.update(_db.pets)..where((p) => p.id.equals(id) & p.branch.isNull()))
          .write(PetsCompanion(
        branch: Value(branch),
        evolvedAt: Value(_clock()),
      ));

  Future<void> rename(int id, String name) =>
      (_db.update(_db.pets)..where((p) => p.id.equals(id)))
          .write(PetsCompanion(name: Value(name.trim())));
}

/// Cấp và điểm hệ của linh thú. EXP và điểm do ScoreService ghi (hấp thụ
/// và hoàn tác).
extension PetGrowth on Pet {
  int get level => Growth.levelFor(exp);

  Map<TaskElement, int> get points => {
        TaskElement.fire: firePoints,
        TaskElement.water: waterPoints,
        TaskElement.wood: woodPoints,
      };
}
