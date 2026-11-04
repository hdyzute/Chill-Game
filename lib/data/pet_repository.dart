import 'package:drift/drift.dart';

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

  Future<void> rename(int id, String name) =>
      (_db.update(_db.pets)..where((p) => p.id.equals(id)))
          .write(PetsCompanion(name: Value(name.trim())));
}
