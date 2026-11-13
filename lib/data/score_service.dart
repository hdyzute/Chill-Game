import 'dart:math';

import 'package:drift/drift.dart';

import '../domain/day.dart';
import '../domain/drops.dart';
import '../domain/growth.dart';
import '../domain/scoring.dart';
import 'database.dart';

/// Chấm điểm task và quản lý ví. Mọi thay đổi chạy trong một transaction,
/// và mỗi lần chấm ghi một [TaskLog] để hoàn tác chính xác.
class ScoreService {
  ScoreService(this._db, {Random? random, DateTime Function()? clock})
      : _random = random ?? Random(),
        _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final Random _random;
  final DateTime Function() _clock;

  // Dùng chung một biểu thức để đọc được cột tổng từ kết quả truy vấn.
  late final _dropSum = _db.taskLogs.dropCount.sum();

  Stream<int> watchCoins() =>
      (_db.select(_db.profiles)..where((p) => p.id.equals(profileId)))
          .watchSingle()
          .map((p) => p.coins);

  /// Số lần hoàn thành từ đầu ngày logic hiện tại. Dùng cho test và chỗ
  /// không cần stream; màn hình dùng [watchCountsSince].
  Future<Map<int, int>> todayCounts() async {
    final profile = await (_db.select(_db.profiles)
          ..where((p) => p.id.equals(profileId)))
        .getSingle();
    return watchCountsSince(todayStart(_clock(), profile.dayStartHour)).first;
  }

  /// Số lần hoàn thành của từng task (taskId → số lần) kể từ [since].
  /// Màn hình truyền mốc đầu ngày logic, và tạo stream mới khi sang ngày.
  Stream<Map<int, int>> watchCountsSince(DateTime since) {
    final count = _db.taskLogs.id.count();
    final query = _db.selectOnly(_db.taskLogs)
      ..addColumns([_db.taskLogs.taskId, count])
      ..where(_completedSince(since))
      ..groupBy([_db.taskLogs.taskId]);
    return query.watch().map((rows) => {
          for (final row in rows)
            row.read(_db.taskLogs.taskId)!: row.read(count)!,
        });
  }

  /// Túi linh vật: số lượng từng loại, chỉ gồm loại đang có.
  Stream<Map<SpiritItem, int>> watchInventory() =>
      _db.select(_db.inventoryItems).watch().map((rows) => {
            for (final r in rows)
              if (r.count > 0) r.item: r.count,
          });

  /// Số linh vật nhặt được kể từ [since] (mốc đầu ngày logic).
  Stream<int> watchDropsSince(DateTime since) => _dropsSinceQuery(since)
      .watchSingle()
      .map((row) => row.read(_dropSum) ?? 0);

  /// Số lần làm thói quen xấu kể từ [since] (mốc đầu ngày logic).
  Stream<int> watchBadSince(DateTime since) {
    final count = _db.taskLogs.id.count();
    final query = _db.selectOnly(_db.taskLogs)
      ..addColumns([count])
      ..where(_db.taskLogs.kind.equalsValue(LogKind.bad) &
          _db.taskLogs.createdAt.isBiggerOrEqualValue(since));
    return query.watchSingle().map((row) => row.read(count)!);
  }

  /// Linh thú hấp thụ một [item] trong túi: +EXP và +điểm hệ. Ném
  /// [StateError] khi túi hết món đó hoặc chưa có linh thú. Trả về linh thú
  /// sau khi hấp thụ.
  Future<Pet> absorb(SpiritItem item) {
    return _db.transaction(() async {
      if (await _itemCount(item) <= 0) {
        throw StateError('Túi không còn ${item.label}');
      }
      final pet = await _pet();
      if (pet == null) throw StateError('Chưa có linh thú');
      await _addItem(item, -1);
      await _growPet(pet, item, 1);
      return (await _pet())!;
    });
  }

  /// Làm xong task ([up]), hoặc làm thói quen xấu (`up: false`).
  Future<TaskLog> score(int taskId, {bool up = true}) {
    return _db.transaction(() async {
      final task = await _task(taskId);
      if (task.type == TaskType.reward) {
        throw ArgumentError('Phần thưởng dùng buyReward');
      }
      final checkable = task.type != TaskType.habit;
      if (checkable && (!up || task.completed)) {
        throw StateError('"${task.title}" không chấm được lúc này');
      }
      if (!checkable && up && await _todayCount(taskId) >= task.dailyTarget) {
        throw StateError('"${task.title}" đã đủ số lần hôm nay');
      }

      final outcome = Scoring.score(
        type: task.type,
        difficulty: task.difficulty,
        value: task.value,
        streak: task.streak,
        up: up,
        critRoll: _random.nextDouble(),
      );

      await _updateTask(
        taskId,
        TasksCompanion(
          value: Value(task.value + outcome.valueDelta),
          streak: Value(task.streak + outcome.streakDelta),
          completed: Value(checkable || task.completed),
        ),
      );
      await _addCoins(outcome.coinsDelta);

      final drop = up
          ? Drops.roll(
              element: task.element,
              difficulty: task.difficulty,
              critical: outcome.critical,
              droppedToday: await _dropsToday(),
              dropRoll: _random.nextDouble(),
              rareRoll: _random.nextDouble(),
            )
          : null;
      if (drop != null) await _addItem(drop.item, drop.count);

      return _insertLog(task, TaskLogsCompanion.insert(
        taskId: taskId,
        kind: up ? LogKind.complete : LogKind.bad,
        valueDelta: Value(outcome.valueDelta),
        coinsDelta: Value(outcome.coinsDelta),
        streakDelta: Value(outcome.streakDelta),
        critical: Value(outcome.critical),
        dropItem: Value(drop?.item),
        dropCount: Value(drop?.count ?? 0),
      ));
    });
  }

  /// Đổi xu lấy phần thưởng. Trả về null nếu chưa đủ xu.
  Future<TaskLog?> buyReward(int taskId) {
    return _db.transaction(() async {
      final task = await _task(taskId);
      if (task.type != TaskType.reward) {
        throw ArgumentError('"${task.title}" không phải phần thưởng');
      }
      if (await _coins() < task.cost) return null;

      await _addCoins(-task.cost);
      return _insertLog(task, TaskLogsCompanion.insert(
        taskId: taskId,
        kind: LogKind.purchase,
        coinsDelta: Value(-task.cost),
      ));
    });
  }

  /// Hoàn tác đúng phần đã cộng trong [logId], rồi xóa dòng nhật ký đó.
  Future<void> undo(int logId) {
    return _db.transaction(() async {
      final log = await (_db.select(_db.taskLogs)
            ..where((l) => l.id.equals(logId)))
          .getSingleOrNull();
      if (log == null) return;

      final task = await (_db.select(_db.tasks)
            ..where((t) => t.id.equals(log.taskId)))
          .getSingleOrNull();
      // Task đã bị xóa thì chỉ hoàn lại xu.
      if (task != null) {
        await _updateTask(
          task.id,
          TasksCompanion(
            value: Value(task.value - log.valueDelta),
            streak: Value(task.streak - log.streakDelta),
            completed: Value(
                log.kind == LogKind.complete && task.type != TaskType.habit
                    ? false
                    : task.completed),
          ),
        );
      }
      // Lỡ tiêu xu rồi mới hoàn tác thì không để ví âm.
      final coins = await _coins();
      await _setCoins(max(0, coins - log.coinsDelta));
      // Linh vật: lấy lại từ túi; món đã cho linh thú hấp thụ thì trừ lại
      // đúng EXP và điểm hệ của nó, để không cày được bằng cách tick, hấp
      // thụ, bỏ tick rồi tick lại.
      final item = log.dropItem;
      if (item != null && log.dropCount > 0) {
        final taken = min(await _itemCount(item), log.dropCount);
        await _addItem(item, -taken);
        final absorbed = log.dropCount - taken;
        final pet = await _pet();
        if (absorbed > 0 && pet != null) {
          await _growPet(pet, item, -absorbed);
        }
      }
      await (_db.delete(_db.taskLogs)..where((l) => l.id.equals(logId))).go();
    });
  }

  /// Bỏ tick daily hoặc việc cần làm: hoàn tác lần hoàn thành gần nhất.
  Future<void> uncheck(int taskId) async {
    final last = await (_db.select(_db.taskLogs)
          ..where((l) => l.taskId.equals(taskId) & l.kind.equalsValue(LogKind.complete))
          ..orderBy([(l) => OrderingTerm.desc(l.id)])
          ..limit(1))
        .getSingleOrNull();
    if (last != null) {
      await undo(last.id);
    } else {
      await _updateTask(taskId, const TasksCompanion(completed: Value(false)));
    }
  }

  Future<Task> _task(int id) =>
      (_db.select(_db.tasks)..where((t) => t.id.equals(id))).getSingle();

  Future<void> _updateTask(int id, TasksCompanion fields) =>
      (_db.update(_db.tasks)..where((t) => t.id.equals(id))).write(fields);

  Future<int> _coins() async =>
      (await (_db.select(_db.profiles)..where((p) => p.id.equals(profileId)))
              .getSingle())
          .coins;

  Future<void> _setCoins(int coins) =>
      (_db.update(_db.profiles)..where((p) => p.id.equals(profileId)))
          .write(ProfilesCompanion(coins: Value(coins)));

  Future<void> _addCoins(int delta) async {
    if (delta == 0) return;
    await _setCoins(await _coins() + delta);
  }

  Future<Pet?> _pet() => (_db.select(_db.pets)
        ..orderBy([(p) => OrderingTerm(expression: p.id)])
        ..limit(1))
      .getSingleOrNull();

  /// Cộng (hoặc trừ khi [times] âm, không xuống dưới 0) EXP và điểm hệ của
  /// [times] món [item].
  Future<void> _growPet(Pet pet, SpiritItem item, int times) {
    int add(int current, int each) => max(0, current + each * times);
    final points = Growth.pointsOf(item);
    return (_db.update(_db.pets)..where((p) => p.id.equals(pet.id)))
        .write(PetsCompanion(
      exp: Value(add(pet.exp, Growth.expOf(item))),
      firePoints: item.element == TaskElement.fire
          ? Value(add(pet.firePoints, points))
          : const Value.absent(),
      waterPoints: item.element == TaskElement.water
          ? Value(add(pet.waterPoints, points))
          : const Value.absent(),
      woodPoints: item.element == TaskElement.wood
          ? Value(add(pet.woodPoints, points))
          : const Value.absent(),
    ));
  }

  Future<int> _itemCount(SpiritItem item) async =>
      (await (_db.select(_db.inventoryItems)
                ..where((i) => i.item.equalsValue(item)))
              .getSingleOrNull())
          ?.count ??
      0;

  /// Cộng (hoặc trừ, không xuống dưới 0) linh vật trong túi.
  Future<void> _addItem(SpiritItem item, int delta) async {
    final count = max(0, await _itemCount(item) + delta);
    await _db.into(_db.inventoryItems).insertOnConflictUpdate(
        InventoryItemsCompanion.insert(item: item, count: Value(count)));
  }

  JoinedSelectStatement<$TaskLogsTable, TaskLog> _dropsSinceQuery(
          DateTime since) =>
      _db.selectOnly(_db.taskLogs)
        ..addColumns([_dropSum])
        ..where(_db.taskLogs.createdAt.isBiggerOrEqualValue(since));

  Future<int> _dropsToday() async {
    final profile = await (_db.select(_db.profiles)
          ..where((p) => p.id.equals(profileId)))
        .getSingle();
    final row =
        await _dropsSinceQuery(todayStart(_clock(), profile.dayStartHour))
            .getSingle();
    return row.read(_dropSum) ?? 0;
  }

  Expression<bool> _completedSince(DateTime since) =>
      _db.taskLogs.kind.equalsValue(LogKind.complete) &
      _db.taskLogs.createdAt.isBiggerOrEqualValue(since);

  Future<int> _todayCount(int taskId) async {
    final profile = await (_db.select(_db.profiles)
          ..where((p) => p.id.equals(profileId)))
        .getSingle();
    final since = todayStart(_clock(), profile.dayStartHour);
    final count = _db.taskLogs.id.count();
    final query = _db.selectOnly(_db.taskLogs)
      ..addColumns([count])
      ..where(_completedSince(since) & _db.taskLogs.taskId.equals(taskId));
    return (await query.getSingle()).read(count)!;
  }

  // Ghi giờ theo _clock (không dùng giờ của SQLite) để "hôm nay" khớp nhau,
  // và chụp lại tên, hệ của task cho lịch sử.
  Future<TaskLog> _insertLog(Task task, TaskLogsCompanion log) =>
      _db.into(_db.taskLogs).insertReturning(log.copyWith(
            createdAt: Value(_clock()),
            title: Value(task.title),
            element: Value(task.element),
          ));
}
