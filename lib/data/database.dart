import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'database.steps.dart';
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

  /// Thói quen tốt: số lần được thưởng mỗi ngày, chống bấm liên tục để cày xu.
  IntColumn get dailyTarget => integer().withDefault(const Constant(1))();

  /// Hằng ngày: các ngày lặp, xem [weekdayLabels].
  IntColumn get repeatDays =>
      integer().withDefault(const Constant(everyDayMask))();

  /// Phần thưởng: giá bằng xu.
  IntColumn get cost => integer().withDefault(const Constant(0))();

  // Trạng thái chấm điểm, dùng từ bước 1.2.
  RealColumn get value => real().withDefault(const Constant(0))();
  IntColumn get streak => integer().withDefault(const Constant(0))();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();

  /// Việc cần làm đã xong từ hôm trước: ẩn khỏi danh sách, giữ cho lịch sử.
  BoolColumn get archived => boolean().withDefault(const Constant(false))();

  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Mỗi lần chấm điểm một dòng. Lưu đúng phần đã cộng để bỏ tick hoàn lại
/// chính xác. Không dùng khóa ngoại: xóa task vẫn giữ lịch sử.
class TaskLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get taskId => integer()();
  TextColumn get kind => textEnum<LogKind>()();
  RealColumn get valueDelta => real().withDefault(const Constant(0))();
  IntColumn get coinsDelta => integer().withDefault(const Constant(0))();
  IntColumn get streakDelta => integer().withDefault(const Constant(0))();
  BoolColumn get critical => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Một dòng duy nhất (id = [profileId]) giữ ví và cài đặt của người dùng.
class Profiles extends Table {
  IntColumn get id => integer()();
  IntColumn get coins => integer().withDefault(const Constant(0))();

  /// Giờ bắt đầu ngày mới (0–12), cho người thức khuya.
  IntColumn get dayStartHour => integer().withDefault(const Constant(0))();

  /// Bế quan: bỏ lỡ daily không bị đứt chuỗi.
  BoolColumn get resting => boolean().withDefault(const Constant(false))();

  /// Ngày (logic) đã xử lý sang ngày gần nhất. Null khi chưa mở app lần nào.
  DateTimeColumn get lastRolloverDate => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

const profileId = 1;

@DriftDatabase(tables: [Tasks, TaskLogs, Profiles])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'linh_thu'));

  @override
  int get schemaVersion => 4;

  // Khi đổi bảng: tăng schemaVersion, chạy `dart run build_runner build`
  // rồi `dart run drift_dev make-migrations`, sau đó viết bước fromXToY.
  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: stepByStep(
          from1To2: (m, schema) async {
            await m.createTable(schema.taskLogs);
            await m.createTable(schema.profiles);
          },
          from2To3: (m, schema) async {
            await m.addColumn(schema.tasks, schema.tasks.dailyTarget);
          },
          from3To4: (m, schema) async {
            await m.addColumn(schema.tasks, schema.tasks.archived);
            await m.addColumn(schema.profiles, schema.profiles.dayStartHour);
            await m.addColumn(schema.profiles, schema.profiles.resting);
            await m.addColumn(
                schema.profiles, schema.profiles.lastRolloverDate);
          },
        ),
        beforeOpen: (_) => into(profiles).insert(
          const ProfilesCompanion(id: Value(profileId)),
          mode: InsertMode.insertOrIgnore,
        ),
      );
}
