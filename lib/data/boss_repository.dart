import 'package:drift/drift.dart';

import '../domain/boss.dart';
import 'database.dart';

/// Boss trong Bí cảnh. Nhận thưởng (cộng xu, thêm linh vật) do ScoreService
/// làm, vì chỉ ScoreService được đổi ví và túi.
class BossRepository {
  BossRepository(this._db, {DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _clock;

  /// Boss đang đánh (chưa nhận thưởng), hoặc null.
  Stream<Boss?> watchActive() => (_db.select(_db.bosses)
        ..where((b) => b.claimedAt.isNull())
        ..orderBy([(b) => OrderingTerm.desc(b.id)])
        ..limit(1))
      .watchSingleOrNull();

  /// Số boss đã đánh bại và nhận thưởng.
  Stream<int> watchDefeatedCount() =>
      _defeatedQuery().watchSingle().map((r) => r.read(_defeatedCount)!);

  late final _defeatedCount = _db.bosses.id.count();

  JoinedSelectStatement<$BossesTable, Boss> _defeatedQuery() =>
      _db.selectOnly(_db.bosses)
        ..addColumns([_defeatedCount])
        ..where(_db.bosses.claimedAt.isNotNull());

  /// Khiêu chiến boss tiếp theo. Ném [StateError] khi đang có boss.
  Future<Boss> challengeNext() => _db.transaction(() async {
        final active = await (_db.select(_db.bosses)
              ..where((b) => b.claimedAt.isNull()))
            .get();
        if (active.isNotEmpty) throw StateError('Đang đánh một boss khác');
        // Đọc thẳng, không dùng stream: stream chờ transaction xong mới chạy.
        final defeated =
            (await _defeatedQuery().getSingle()).read(_defeatedCount)!;
        return _db.into(_db.bosses).insertReturning(BossesCompanion.insert(
              kind: BossStats.nextKind(defeated),
              tier: Value(BossStats.nextTier(defeated)),
              startedAt: _clock(),
            ));
      });
}
