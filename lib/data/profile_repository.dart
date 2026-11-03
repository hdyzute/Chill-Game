import 'package:drift/drift.dart';

import 'database.dart';

/// Cài đặt của người dùng. Ví xu thì do ScoreService quản lý.
class ProfileRepository {
  ProfileRepository(this._db);

  final AppDatabase _db;

  SimpleSelectStatement<$ProfilesTable, Profile> get _query =>
      _db.select(_db.profiles)..where((p) => p.id.equals(profileId));

  Stream<Profile> watch() => _query.watchSingle();

  Future<void> setDayStartHour(int hour) =>
      _write(ProfilesCompanion(dayStartHour: Value(hour)));

  Future<void> setResting(bool resting) =>
      _write(ProfilesCompanion(resting: Value(resting)));

  Future<void> _write(ProfilesCompanion fields) =>
      (_db.update(_db.profiles)..where((p) => p.id.equals(profileId)))
          .write(fields);
}
