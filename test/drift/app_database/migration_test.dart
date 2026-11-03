// dart format width=80
// ignore_for_file: unused_local_variable, unused_import
import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:linh_thu_ky_luat/data/database.dart';
import 'package:flutter_test/flutter_test.dart';

import 'generated/schema.dart';

import 'generated/schema_v1.dart' as v1;
import 'generated/schema_v2.dart' as v2;
import 'generated/schema_v3.dart' as v3;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  group('simple database migrations', () {
    // These simple tests verify all possible schema updates with a simple (no
    // data) migration. This is a quick way to ensure that written database
    // migrations properly alter the schema.
    const versions = GeneratedHelper.versions;
    for (final (i, fromVersion) in versions.indexed) {
      group('from $fromVersion', () {
        for (final toVersion in versions.skip(i + 1)) {
          test('to $toVersion', () async {
            final schema = await verifier.schemaAt(fromVersion);
            final db = AppDatabase(schema.newConnection());
            await verifier.migrateAndValidate(db, toVersion);
            await db.close();
          });
        }
      });
    }
  });

  // Người dùng đã có task ở v1 trên điện thoại: nâng cấp không được mất task,
  // và phải có sẵn ví 0 xu.
  test('nâng cấp v1 lên v2 giữ nguyên task và tạo ví', () async {
    const oldTasksData = [
      v1.TasksData(
        id: 1,
        title: 'Chạy bộ',
        notes: null,
        type: 'daily',
        difficulty: 'medium',
        element: 'fire',
        habitUp: 1,
        habitDown: 0,
        repeatDays: 0x15,
        cost: 0,
        value: 0,
        streak: 0,
        completed: 0,
        sortOrder: 0,
        createdAt: 1793600000,
      ),
    ];
    const expectedNewTasksData = [
      v2.TasksData(
        id: 1,
        title: 'Chạy bộ',
        notes: null,
        type: 'daily',
        difficulty: 'medium',
        element: 'fire',
        habitUp: 1,
        habitDown: 0,
        repeatDays: 0x15,
        cost: 0,
        value: 0,
        streak: 0,
        completed: 0,
        sortOrder: 0,
        createdAt: 1793600000,
      ),
    ];

    await verifier.testWithDataIntegrity(
      oldVersion: 1,
      newVersion: 2,
      createOld: v1.DatabaseAtV1.new,
      createNew: v2.DatabaseAtV2.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) {
        batch.insertAll(oldDb.tasks, oldTasksData);
      },
      validateItems: (newDb) async {
        expect(await newDb.select(newDb.tasks).get(), expectedNewTasksData);
        expect(await newDb.select(newDb.profiles).get(),
            [const v2.ProfilesData(id: profileId, coins: 0)]);
      },
    );
  });

  test('nâng cấp v2 lên v3: thói quen cũ có mục tiêu 1 lần/ngày, giữ xu',
      () async {
    await verifier.testWithDataIntegrity(
      oldVersion: 2,
      newVersion: 3,
      createOld: v2.DatabaseAtV2.new,
      createNew: v3.DatabaseAtV3.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) {
        batch.insertAll(oldDb.tasks, const [
          v2.TasksData(
            id: 1,
            title: 'Uống nước',
            notes: null,
            type: 'habit',
            difficulty: 'easy',
            element: 'wood',
            habitUp: 1,
            habitDown: 0,
            repeatDays: 0x7f,
            cost: 0,
            value: 2.5,
            streak: 0,
            completed: 0,
            sortOrder: 0,
            createdAt: 1793600000,
          ),
        ]);
        batch.insert(oldDb.profiles,
            const v2.ProfilesData(id: profileId, coins: 120));
      },
      validateItems: (newDb) async {
        final task = await newDb.select(newDb.tasks).getSingle();
        expect(task.title, 'Uống nước');
        expect(task.value, 2.5);
        expect(task.dailyTarget, 1);
        expect((await newDb.select(newDb.profiles).getSingle()).coins, 120);
      },
    );
  });
}
