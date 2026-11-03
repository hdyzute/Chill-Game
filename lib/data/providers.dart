import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database.dart';
import 'score_service.dart';
import 'task_repository.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final taskRepositoryProvider =
    Provider((ref) => TaskRepository(ref.watch(databaseProvider)));

final tasksProvider = StreamProvider<List<Task>>(
    (ref) => ref.watch(taskRepositoryProvider).watchAll());

final scoreServiceProvider =
    Provider((ref) => ScoreService(ref.watch(databaseProvider)));

final coinsProvider =
    StreamProvider<int>((ref) => ref.watch(scoreServiceProvider).watchCoins());

final todayCountsProvider = StreamProvider<Map<int, int>>(
    (ref) => ref.watch(scoreServiceProvider).watchTodayCounts());
