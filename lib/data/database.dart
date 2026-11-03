import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'task_enums.dart';

export 'task_enums.dart';

part 'database.g.dart';

class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 100)();
  TextColumn get notes => text().nullable()();
  TextColumn get type => textEnum<TaskType>()();
  TextColumn get difficulty => textEnum<Difficulty>()();

  /// Null với phần thưởng.
  TextColumn get element => textEnum<TaskElement>().nullable()();

  /// Thói quen: có nút "+" (việc tốt) và/hoặc "−" (việc xấu).
  BoolColumn get habitUp => boolean().withDefault(const Constant(true))();
  BoolColumn get habitDown => boolean().withDefault(const Constant(false))();

  /// Hằng ngày: các ngày lặp, xem [weekdayLabels].
  IntColumn get repeatDays =>
      integer().withDefault(const Constant(everyDayMask))();

  /// Phần thưởng: giá bằng xu.
  IntColumn get cost => integer().withDefault(const Constant(0))();

  // Trạng thái chấm điểm, dùng từ bước 1.2.
  RealColumn get value => real().withDefault(const Constant(0))();
  IntColumn get streak => integer().withDefault(const Constant(0))();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();

  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [Tasks])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'linh_thu'));

  @override
  int get schemaVersion => 1;
}
