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

  /// Giờ nhắc trong ngày, tính bằng phút từ 0:00 (480 = 8:00). Null = không nhắc.
  /// Chỉ dùng cho daily và thói quen tốt.
  IntColumn get reminderMinutes => integer().nullable()();

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

  /// Tên và hệ của task lúc chấm, để lịch sử không đổi khi task bị sửa hay
  /// xóa. Null với dòng cũ của task đã xóa trước bản 6.
  TextColumn get title => text().nullable()();
  TextColumn get element => textEnum<TaskElement>().nullable()();

  /// Linh vật nhặt được ở lần chấm này, để hoàn tác lấy lại đúng món đó.
  TextColumn get dropItem => textEnum<SpiritItem>().nullable()();
  IntColumn get dropCount => integer().withDefault(const Constant(0))();
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

/// Linh thú đã ký khế ước. Bản đầu chỉ có một con (dòng đầu tiên).
class Pets extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 20)();

  /// Lúc ký khế ước. Trứng chỉ tính việc tốt từ ngày (logic) này.
  DateTimeColumn get createdAt => dateTime()();

  /// Tổng EXP từ linh vật đã hấp thụ; cấp tính từ đây (xem growth.dart).
  IntColumn get exp => integer().withDefault(const Constant(0))();

  /// Điểm từng hệ, quyết định nhánh khi tiến hóa.
  IntColumn get firePoints => integer().withDefault(const Constant(0))();
  IntColumn get waterPoints => integer().withDefault(const Constant(0))();
  IntColumn get woodPoints => integer().withDefault(const Constant(0))();

  /// Nhánh đã tiến hóa (Trưởng thành). Null khi chưa tiến hóa.
  TextColumn get branch => textEnum<TaskElement>().nullable()();
  DateTimeColumn get evolvedAt => dateTime().nullable()();
}

/// Túi linh vật: số lượng từng loại. Chỉ ScoreService ghi vào (rơi đồ và
/// hoàn tác), giống ví xu.
class InventoryItems extends Table {
  TextColumn get item => textEnum<SpiritItem>()();
  IntColumn get count => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {item};
}

/// Linh điền: cây đang trồng ở từng ô (0 tới Field.plots − 1). Ô trống thì
/// không có dòng; thu hoạch xong thì xóa dòng. Chỉ ScoreService ghi, vì gieo
/// hạt tốn xu và thu hoạch thêm linh vật vào túi.
class Plantings extends Table {
  IntColumn get plot => integer()();
  TextColumn get element => textEnum<TaskElement>()();
  DateTimeColumn get plantedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {plot};
}

@DriftDatabase(
    tables: [Tasks, TaskLogs, Profiles, Pets, InventoryItems, Plantings])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'linh_thu'));

  @override
  int get schemaVersion => 10;

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
          from4To5: (m, schema) async {
            await m.addColumn(schema.tasks, schema.tasks.reminderMinutes);
          },
          from5To6: (m, schema) async {
            await m.addColumn(schema.taskLogs, schema.taskLogs.title);
            await m.addColumn(schema.taskLogs, schema.taskLogs.element);
            // Điền tên và hệ cho nhật ký cũ từ task còn tồn tại.
            await customStatement('''
              UPDATE task_logs SET
                title = (SELECT title FROM tasks WHERE tasks.id = task_logs.task_id),
                element = (SELECT element FROM tasks WHERE tasks.id = task_logs.task_id)
            ''');
          },
          from6To7: (m, schema) async {
            await m.createTable(schema.pets);
          },
          from7To8: (m, schema) async {
            await m.addColumn(schema.taskLogs, schema.taskLogs.dropItem);
            await m.addColumn(schema.taskLogs, schema.taskLogs.dropCount);
            await m.createTable(schema.inventoryItems);
          },
          from8To9: (m, schema) async {
            await m.addColumn(schema.pets, schema.pets.exp);
            await m.addColumn(schema.pets, schema.pets.firePoints);
            await m.addColumn(schema.pets, schema.pets.waterPoints);
            await m.addColumn(schema.pets, schema.pets.woodPoints);
            await m.addColumn(schema.pets, schema.pets.branch);
            await m.addColumn(schema.pets, schema.pets.evolvedAt);
          },
          from9To10: (m, schema) async {
            await m.createTable(schema.plantings);
          },
        ),
        beforeOpen: (_) => into(profiles).insert(
          const ProfilesCompanion(id: Value(profileId)),
          mode: InsertMode.insertOrIgnore,
        ),
      );
}
