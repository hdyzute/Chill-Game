// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $TasksTable extends Tasks with TableInfo<$TasksTable, Task> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<TaskType, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<TaskType>($TasksTable.$convertertype);
  @override
  late final GeneratedColumnWithTypeConverter<Difficulty, String> difficulty =
      GeneratedColumn<String>(
        'difficulty',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Difficulty>($TasksTable.$converterdifficulty);
  @override
  late final GeneratedColumnWithTypeConverter<TaskElement?, String> element =
      GeneratedColumn<String>(
        'element',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<TaskElement?>($TasksTable.$converterelementn);
  static const VerificationMeta _habitUpMeta = const VerificationMeta(
    'habitUp',
  );
  @override
  late final GeneratedColumn<bool> habitUp = GeneratedColumn<bool>(
    'habit_up',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("habit_up" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _habitDownMeta = const VerificationMeta(
    'habitDown',
  );
  @override
  late final GeneratedColumn<bool> habitDown = GeneratedColumn<bool>(
    'habit_down',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("habit_down" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _dailyTargetMeta = const VerificationMeta(
    'dailyTarget',
  );
  @override
  late final GeneratedColumn<int> dailyTarget = GeneratedColumn<int>(
    'daily_target',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _repeatDaysMeta = const VerificationMeta(
    'repeatDays',
  );
  @override
  late final GeneratedColumn<int> repeatDays = GeneratedColumn<int>(
    'repeat_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(everyDayMask),
  );
  static const VerificationMeta _costMeta = const VerificationMeta('cost');
  @override
  late final GeneratedColumn<int> cost = GeneratedColumn<int>(
    'cost',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<double> value = GeneratedColumn<double>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _streakMeta = const VerificationMeta('streak');
  @override
  late final GeneratedColumn<int> streak = GeneratedColumn<int>(
    'streak',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _completedMeta = const VerificationMeta(
    'completed',
  );
  @override
  late final GeneratedColumn<bool> completed = GeneratedColumn<bool>(
    'completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _archivedMeta = const VerificationMeta(
    'archived',
  );
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
    'archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    notes,
    type,
    difficulty,
    element,
    habitUp,
    habitDown,
    dailyTarget,
    repeatDays,
    cost,
    value,
    streak,
    completed,
    archived,
    sortOrder,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Task> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('habit_up')) {
      context.handle(
        _habitUpMeta,
        habitUp.isAcceptableOrUnknown(data['habit_up']!, _habitUpMeta),
      );
    }
    if (data.containsKey('habit_down')) {
      context.handle(
        _habitDownMeta,
        habitDown.isAcceptableOrUnknown(data['habit_down']!, _habitDownMeta),
      );
    }
    if (data.containsKey('daily_target')) {
      context.handle(
        _dailyTargetMeta,
        dailyTarget.isAcceptableOrUnknown(
          data['daily_target']!,
          _dailyTargetMeta,
        ),
      );
    }
    if (data.containsKey('repeat_days')) {
      context.handle(
        _repeatDaysMeta,
        repeatDays.isAcceptableOrUnknown(data['repeat_days']!, _repeatDaysMeta),
      );
    }
    if (data.containsKey('cost')) {
      context.handle(
        _costMeta,
        cost.isAcceptableOrUnknown(data['cost']!, _costMeta),
      );
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    }
    if (data.containsKey('streak')) {
      context.handle(
        _streakMeta,
        streak.isAcceptableOrUnknown(data['streak']!, _streakMeta),
      );
    }
    if (data.containsKey('completed')) {
      context.handle(
        _completedMeta,
        completed.isAcceptableOrUnknown(data['completed']!, _completedMeta),
      );
    }
    if (data.containsKey('archived')) {
      context.handle(
        _archivedMeta,
        archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Task map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Task(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      type: $TasksTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      difficulty: $TasksTable.$converterdifficulty.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}difficulty'],
        )!,
      ),
      element: $TasksTable.$converterelementn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}element'],
        ),
      ),
      habitUp: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}habit_up'],
      )!,
      habitDown: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}habit_down'],
      )!,
      dailyTarget: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}daily_target'],
      )!,
      repeatDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}repeat_days'],
      )!,
      cost: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cost'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}value'],
      )!,
      streak: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}streak'],
      )!,
      completed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}completed'],
      )!,
      archived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}archived'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TasksTable createAlias(String alias) {
    return $TasksTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TaskType, String, String> $convertertype =
      const EnumNameConverter<TaskType>(TaskType.values);
  static JsonTypeConverter2<Difficulty, String, String> $converterdifficulty =
      const EnumNameConverter<Difficulty>(Difficulty.values);
  static JsonTypeConverter2<TaskElement, String, String> $converterelement =
      const EnumNameConverter<TaskElement>(TaskElement.values);
  static JsonTypeConverter2<TaskElement?, String?, String?> $converterelementn =
      JsonTypeConverter2.asNullable($converterelement);
}

class Task extends DataClass implements Insertable<Task> {
  final int id;
  final String title;
  final String? notes;
  final TaskType type;
  final Difficulty difficulty;

  /// Null với phần thưởng.
  final TaskElement? element;

  /// Thói quen: có nút "+" (việc tốt) và/hoặc "−" (việc xấu).
  final bool habitUp;
  final bool habitDown;

  /// Thói quen tốt: số lần được thưởng mỗi ngày, chống bấm liên tục để cày xu.
  final int dailyTarget;

  /// Hằng ngày: các ngày lặp, xem [weekdayLabels].
  final int repeatDays;

  /// Phần thưởng: giá bằng xu.
  final int cost;
  final double value;
  final int streak;
  final bool completed;

  /// Việc cần làm đã xong từ hôm trước: ẩn khỏi danh sách, giữ cho lịch sử.
  final bool archived;
  final int sortOrder;
  final DateTime createdAt;
  const Task({
    required this.id,
    required this.title,
    this.notes,
    required this.type,
    required this.difficulty,
    this.element,
    required this.habitUp,
    required this.habitDown,
    required this.dailyTarget,
    required this.repeatDays,
    required this.cost,
    required this.value,
    required this.streak,
    required this.completed,
    required this.archived,
    required this.sortOrder,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    {
      map['type'] = Variable<String>($TasksTable.$convertertype.toSql(type));
    }
    {
      map['difficulty'] = Variable<String>(
        $TasksTable.$converterdifficulty.toSql(difficulty),
      );
    }
    if (!nullToAbsent || element != null) {
      map['element'] = Variable<String>(
        $TasksTable.$converterelementn.toSql(element),
      );
    }
    map['habit_up'] = Variable<bool>(habitUp);
    map['habit_down'] = Variable<bool>(habitDown);
    map['daily_target'] = Variable<int>(dailyTarget);
    map['repeat_days'] = Variable<int>(repeatDays);
    map['cost'] = Variable<int>(cost);
    map['value'] = Variable<double>(value);
    map['streak'] = Variable<int>(streak);
    map['completed'] = Variable<bool>(completed);
    map['archived'] = Variable<bool>(archived);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TasksCompanion toCompanion(bool nullToAbsent) {
    return TasksCompanion(
      id: Value(id),
      title: Value(title),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      type: Value(type),
      difficulty: Value(difficulty),
      element: element == null && nullToAbsent
          ? const Value.absent()
          : Value(element),
      habitUp: Value(habitUp),
      habitDown: Value(habitDown),
      dailyTarget: Value(dailyTarget),
      repeatDays: Value(repeatDays),
      cost: Value(cost),
      value: Value(value),
      streak: Value(streak),
      completed: Value(completed),
      archived: Value(archived),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
    );
  }

  factory Task.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Task(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      notes: serializer.fromJson<String?>(json['notes']),
      type: $TasksTable.$convertertype.fromJson(
        serializer.fromJson<String>(json['type']),
      ),
      difficulty: $TasksTable.$converterdifficulty.fromJson(
        serializer.fromJson<String>(json['difficulty']),
      ),
      element: $TasksTable.$converterelementn.fromJson(
        serializer.fromJson<String?>(json['element']),
      ),
      habitUp: serializer.fromJson<bool>(json['habitUp']),
      habitDown: serializer.fromJson<bool>(json['habitDown']),
      dailyTarget: serializer.fromJson<int>(json['dailyTarget']),
      repeatDays: serializer.fromJson<int>(json['repeatDays']),
      cost: serializer.fromJson<int>(json['cost']),
      value: serializer.fromJson<double>(json['value']),
      streak: serializer.fromJson<int>(json['streak']),
      completed: serializer.fromJson<bool>(json['completed']),
      archived: serializer.fromJson<bool>(json['archived']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'notes': serializer.toJson<String?>(notes),
      'type': serializer.toJson<String>(
        $TasksTable.$convertertype.toJson(type),
      ),
      'difficulty': serializer.toJson<String>(
        $TasksTable.$converterdifficulty.toJson(difficulty),
      ),
      'element': serializer.toJson<String?>(
        $TasksTable.$converterelementn.toJson(element),
      ),
      'habitUp': serializer.toJson<bool>(habitUp),
      'habitDown': serializer.toJson<bool>(habitDown),
      'dailyTarget': serializer.toJson<int>(dailyTarget),
      'repeatDays': serializer.toJson<int>(repeatDays),
      'cost': serializer.toJson<int>(cost),
      'value': serializer.toJson<double>(value),
      'streak': serializer.toJson<int>(streak),
      'completed': serializer.toJson<bool>(completed),
      'archived': serializer.toJson<bool>(archived),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Task copyWith({
    int? id,
    String? title,
    Value<String?> notes = const Value.absent(),
    TaskType? type,
    Difficulty? difficulty,
    Value<TaskElement?> element = const Value.absent(),
    bool? habitUp,
    bool? habitDown,
    int? dailyTarget,
    int? repeatDays,
    int? cost,
    double? value,
    int? streak,
    bool? completed,
    bool? archived,
    int? sortOrder,
    DateTime? createdAt,
  }) => Task(
    id: id ?? this.id,
    title: title ?? this.title,
    notes: notes.present ? notes.value : this.notes,
    type: type ?? this.type,
    difficulty: difficulty ?? this.difficulty,
    element: element.present ? element.value : this.element,
    habitUp: habitUp ?? this.habitUp,
    habitDown: habitDown ?? this.habitDown,
    dailyTarget: dailyTarget ?? this.dailyTarget,
    repeatDays: repeatDays ?? this.repeatDays,
    cost: cost ?? this.cost,
    value: value ?? this.value,
    streak: streak ?? this.streak,
    completed: completed ?? this.completed,
    archived: archived ?? this.archived,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
  );
  Task copyWithCompanion(TasksCompanion data) {
    return Task(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      notes: data.notes.present ? data.notes.value : this.notes,
      type: data.type.present ? data.type.value : this.type,
      difficulty: data.difficulty.present
          ? data.difficulty.value
          : this.difficulty,
      element: data.element.present ? data.element.value : this.element,
      habitUp: data.habitUp.present ? data.habitUp.value : this.habitUp,
      habitDown: data.habitDown.present ? data.habitDown.value : this.habitDown,
      dailyTarget: data.dailyTarget.present
          ? data.dailyTarget.value
          : this.dailyTarget,
      repeatDays: data.repeatDays.present
          ? data.repeatDays.value
          : this.repeatDays,
      cost: data.cost.present ? data.cost.value : this.cost,
      value: data.value.present ? data.value.value : this.value,
      streak: data.streak.present ? data.streak.value : this.streak,
      completed: data.completed.present ? data.completed.value : this.completed,
      archived: data.archived.present ? data.archived.value : this.archived,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Task(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('notes: $notes, ')
          ..write('type: $type, ')
          ..write('difficulty: $difficulty, ')
          ..write('element: $element, ')
          ..write('habitUp: $habitUp, ')
          ..write('habitDown: $habitDown, ')
          ..write('dailyTarget: $dailyTarget, ')
          ..write('repeatDays: $repeatDays, ')
          ..write('cost: $cost, ')
          ..write('value: $value, ')
          ..write('streak: $streak, ')
          ..write('completed: $completed, ')
          ..write('archived: $archived, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    notes,
    type,
    difficulty,
    element,
    habitUp,
    habitDown,
    dailyTarget,
    repeatDays,
    cost,
    value,
    streak,
    completed,
    archived,
    sortOrder,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Task &&
          other.id == this.id &&
          other.title == this.title &&
          other.notes == this.notes &&
          other.type == this.type &&
          other.difficulty == this.difficulty &&
          other.element == this.element &&
          other.habitUp == this.habitUp &&
          other.habitDown == this.habitDown &&
          other.dailyTarget == this.dailyTarget &&
          other.repeatDays == this.repeatDays &&
          other.cost == this.cost &&
          other.value == this.value &&
          other.streak == this.streak &&
          other.completed == this.completed &&
          other.archived == this.archived &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt);
}

class TasksCompanion extends UpdateCompanion<Task> {
  final Value<int> id;
  final Value<String> title;
  final Value<String?> notes;
  final Value<TaskType> type;
  final Value<Difficulty> difficulty;
  final Value<TaskElement?> element;
  final Value<bool> habitUp;
  final Value<bool> habitDown;
  final Value<int> dailyTarget;
  final Value<int> repeatDays;
  final Value<int> cost;
  final Value<double> value;
  final Value<int> streak;
  final Value<bool> completed;
  final Value<bool> archived;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  const TasksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.notes = const Value.absent(),
    this.type = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.element = const Value.absent(),
    this.habitUp = const Value.absent(),
    this.habitDown = const Value.absent(),
    this.dailyTarget = const Value.absent(),
    this.repeatDays = const Value.absent(),
    this.cost = const Value.absent(),
    this.value = const Value.absent(),
    this.streak = const Value.absent(),
    this.completed = const Value.absent(),
    this.archived = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  TasksCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.notes = const Value.absent(),
    required TaskType type,
    required Difficulty difficulty,
    this.element = const Value.absent(),
    this.habitUp = const Value.absent(),
    this.habitDown = const Value.absent(),
    this.dailyTarget = const Value.absent(),
    this.repeatDays = const Value.absent(),
    this.cost = const Value.absent(),
    this.value = const Value.absent(),
    this.streak = const Value.absent(),
    this.completed = const Value.absent(),
    this.archived = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : title = Value(title),
       type = Value(type),
       difficulty = Value(difficulty);
  static Insertable<Task> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? notes,
    Expression<String>? type,
    Expression<String>? difficulty,
    Expression<String>? element,
    Expression<bool>? habitUp,
    Expression<bool>? habitDown,
    Expression<int>? dailyTarget,
    Expression<int>? repeatDays,
    Expression<int>? cost,
    Expression<double>? value,
    Expression<int>? streak,
    Expression<bool>? completed,
    Expression<bool>? archived,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (notes != null) 'notes': notes,
      if (type != null) 'type': type,
      if (difficulty != null) 'difficulty': difficulty,
      if (element != null) 'element': element,
      if (habitUp != null) 'habit_up': habitUp,
      if (habitDown != null) 'habit_down': habitDown,
      if (dailyTarget != null) 'daily_target': dailyTarget,
      if (repeatDays != null) 'repeat_days': repeatDays,
      if (cost != null) 'cost': cost,
      if (value != null) 'value': value,
      if (streak != null) 'streak': streak,
      if (completed != null) 'completed': completed,
      if (archived != null) 'archived': archived,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  TasksCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String?>? notes,
    Value<TaskType>? type,
    Value<Difficulty>? difficulty,
    Value<TaskElement?>? element,
    Value<bool>? habitUp,
    Value<bool>? habitDown,
    Value<int>? dailyTarget,
    Value<int>? repeatDays,
    Value<int>? cost,
    Value<double>? value,
    Value<int>? streak,
    Value<bool>? completed,
    Value<bool>? archived,
    Value<int>? sortOrder,
    Value<DateTime>? createdAt,
  }) {
    return TasksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      type: type ?? this.type,
      difficulty: difficulty ?? this.difficulty,
      element: element ?? this.element,
      habitUp: habitUp ?? this.habitUp,
      habitDown: habitDown ?? this.habitDown,
      dailyTarget: dailyTarget ?? this.dailyTarget,
      repeatDays: repeatDays ?? this.repeatDays,
      cost: cost ?? this.cost,
      value: value ?? this.value,
      streak: streak ?? this.streak,
      completed: completed ?? this.completed,
      archived: archived ?? this.archived,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
        $TasksTable.$convertertype.toSql(type.value),
      );
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<String>(
        $TasksTable.$converterdifficulty.toSql(difficulty.value),
      );
    }
    if (element.present) {
      map['element'] = Variable<String>(
        $TasksTable.$converterelementn.toSql(element.value),
      );
    }
    if (habitUp.present) {
      map['habit_up'] = Variable<bool>(habitUp.value);
    }
    if (habitDown.present) {
      map['habit_down'] = Variable<bool>(habitDown.value);
    }
    if (dailyTarget.present) {
      map['daily_target'] = Variable<int>(dailyTarget.value);
    }
    if (repeatDays.present) {
      map['repeat_days'] = Variable<int>(repeatDays.value);
    }
    if (cost.present) {
      map['cost'] = Variable<int>(cost.value);
    }
    if (value.present) {
      map['value'] = Variable<double>(value.value);
    }
    if (streak.present) {
      map['streak'] = Variable<int>(streak.value);
    }
    if (completed.present) {
      map['completed'] = Variable<bool>(completed.value);
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('notes: $notes, ')
          ..write('type: $type, ')
          ..write('difficulty: $difficulty, ')
          ..write('element: $element, ')
          ..write('habitUp: $habitUp, ')
          ..write('habitDown: $habitDown, ')
          ..write('dailyTarget: $dailyTarget, ')
          ..write('repeatDays: $repeatDays, ')
          ..write('cost: $cost, ')
          ..write('value: $value, ')
          ..write('streak: $streak, ')
          ..write('completed: $completed, ')
          ..write('archived: $archived, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $TaskLogsTable extends TaskLogs with TableInfo<$TaskLogsTable, TaskLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TaskLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<int> taskId = GeneratedColumn<int>(
    'task_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<LogKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<LogKind>($TaskLogsTable.$converterkind);
  static const VerificationMeta _valueDeltaMeta = const VerificationMeta(
    'valueDelta',
  );
  @override
  late final GeneratedColumn<double> valueDelta = GeneratedColumn<double>(
    'value_delta',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _coinsDeltaMeta = const VerificationMeta(
    'coinsDelta',
  );
  @override
  late final GeneratedColumn<int> coinsDelta = GeneratedColumn<int>(
    'coins_delta',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _streakDeltaMeta = const VerificationMeta(
    'streakDelta',
  );
  @override
  late final GeneratedColumn<int> streakDelta = GeneratedColumn<int>(
    'streak_delta',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _criticalMeta = const VerificationMeta(
    'critical',
  );
  @override
  late final GeneratedColumn<bool> critical = GeneratedColumn<bool>(
    'critical',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("critical" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    taskId,
    kind,
    valueDelta,
    coinsDelta,
    streakDelta,
    critical,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'task_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<TaskLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('value_delta')) {
      context.handle(
        _valueDeltaMeta,
        valueDelta.isAcceptableOrUnknown(data['value_delta']!, _valueDeltaMeta),
      );
    }
    if (data.containsKey('coins_delta')) {
      context.handle(
        _coinsDeltaMeta,
        coinsDelta.isAcceptableOrUnknown(data['coins_delta']!, _coinsDeltaMeta),
      );
    }
    if (data.containsKey('streak_delta')) {
      context.handle(
        _streakDeltaMeta,
        streakDelta.isAcceptableOrUnknown(
          data['streak_delta']!,
          _streakDeltaMeta,
        ),
      );
    }
    if (data.containsKey('critical')) {
      context.handle(
        _criticalMeta,
        critical.isAcceptableOrUnknown(data['critical']!, _criticalMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TaskLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}task_id'],
      )!,
      kind: $TaskLogsTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      valueDelta: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}value_delta'],
      )!,
      coinsDelta: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}coins_delta'],
      )!,
      streakDelta: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}streak_delta'],
      )!,
      critical: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}critical'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TaskLogsTable createAlias(String alias) {
    return $TaskLogsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<LogKind, String, String> $converterkind =
      const EnumNameConverter<LogKind>(LogKind.values);
}

class TaskLog extends DataClass implements Insertable<TaskLog> {
  final int id;
  final int taskId;
  final LogKind kind;
  final double valueDelta;
  final int coinsDelta;
  final int streakDelta;
  final bool critical;
  final DateTime createdAt;
  const TaskLog({
    required this.id,
    required this.taskId,
    required this.kind,
    required this.valueDelta,
    required this.coinsDelta,
    required this.streakDelta,
    required this.critical,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['task_id'] = Variable<int>(taskId);
    {
      map['kind'] = Variable<String>($TaskLogsTable.$converterkind.toSql(kind));
    }
    map['value_delta'] = Variable<double>(valueDelta);
    map['coins_delta'] = Variable<int>(coinsDelta);
    map['streak_delta'] = Variable<int>(streakDelta);
    map['critical'] = Variable<bool>(critical);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TaskLogsCompanion toCompanion(bool nullToAbsent) {
    return TaskLogsCompanion(
      id: Value(id),
      taskId: Value(taskId),
      kind: Value(kind),
      valueDelta: Value(valueDelta),
      coinsDelta: Value(coinsDelta),
      streakDelta: Value(streakDelta),
      critical: Value(critical),
      createdAt: Value(createdAt),
    );
  }

  factory TaskLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskLog(
      id: serializer.fromJson<int>(json['id']),
      taskId: serializer.fromJson<int>(json['taskId']),
      kind: $TaskLogsTable.$converterkind.fromJson(
        serializer.fromJson<String>(json['kind']),
      ),
      valueDelta: serializer.fromJson<double>(json['valueDelta']),
      coinsDelta: serializer.fromJson<int>(json['coinsDelta']),
      streakDelta: serializer.fromJson<int>(json['streakDelta']),
      critical: serializer.fromJson<bool>(json['critical']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'taskId': serializer.toJson<int>(taskId),
      'kind': serializer.toJson<String>(
        $TaskLogsTable.$converterkind.toJson(kind),
      ),
      'valueDelta': serializer.toJson<double>(valueDelta),
      'coinsDelta': serializer.toJson<int>(coinsDelta),
      'streakDelta': serializer.toJson<int>(streakDelta),
      'critical': serializer.toJson<bool>(critical),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  TaskLog copyWith({
    int? id,
    int? taskId,
    LogKind? kind,
    double? valueDelta,
    int? coinsDelta,
    int? streakDelta,
    bool? critical,
    DateTime? createdAt,
  }) => TaskLog(
    id: id ?? this.id,
    taskId: taskId ?? this.taskId,
    kind: kind ?? this.kind,
    valueDelta: valueDelta ?? this.valueDelta,
    coinsDelta: coinsDelta ?? this.coinsDelta,
    streakDelta: streakDelta ?? this.streakDelta,
    critical: critical ?? this.critical,
    createdAt: createdAt ?? this.createdAt,
  );
  TaskLog copyWithCompanion(TaskLogsCompanion data) {
    return TaskLog(
      id: data.id.present ? data.id.value : this.id,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      kind: data.kind.present ? data.kind.value : this.kind,
      valueDelta: data.valueDelta.present
          ? data.valueDelta.value
          : this.valueDelta,
      coinsDelta: data.coinsDelta.present
          ? data.coinsDelta.value
          : this.coinsDelta,
      streakDelta: data.streakDelta.present
          ? data.streakDelta.value
          : this.streakDelta,
      critical: data.critical.present ? data.critical.value : this.critical,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskLog(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('kind: $kind, ')
          ..write('valueDelta: $valueDelta, ')
          ..write('coinsDelta: $coinsDelta, ')
          ..write('streakDelta: $streakDelta, ')
          ..write('critical: $critical, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    taskId,
    kind,
    valueDelta,
    coinsDelta,
    streakDelta,
    critical,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskLog &&
          other.id == this.id &&
          other.taskId == this.taskId &&
          other.kind == this.kind &&
          other.valueDelta == this.valueDelta &&
          other.coinsDelta == this.coinsDelta &&
          other.streakDelta == this.streakDelta &&
          other.critical == this.critical &&
          other.createdAt == this.createdAt);
}

class TaskLogsCompanion extends UpdateCompanion<TaskLog> {
  final Value<int> id;
  final Value<int> taskId;
  final Value<LogKind> kind;
  final Value<double> valueDelta;
  final Value<int> coinsDelta;
  final Value<int> streakDelta;
  final Value<bool> critical;
  final Value<DateTime> createdAt;
  const TaskLogsCompanion({
    this.id = const Value.absent(),
    this.taskId = const Value.absent(),
    this.kind = const Value.absent(),
    this.valueDelta = const Value.absent(),
    this.coinsDelta = const Value.absent(),
    this.streakDelta = const Value.absent(),
    this.critical = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  TaskLogsCompanion.insert({
    this.id = const Value.absent(),
    required int taskId,
    required LogKind kind,
    this.valueDelta = const Value.absent(),
    this.coinsDelta = const Value.absent(),
    this.streakDelta = const Value.absent(),
    this.critical = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : taskId = Value(taskId),
       kind = Value(kind);
  static Insertable<TaskLog> custom({
    Expression<int>? id,
    Expression<int>? taskId,
    Expression<String>? kind,
    Expression<double>? valueDelta,
    Expression<int>? coinsDelta,
    Expression<int>? streakDelta,
    Expression<bool>? critical,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (taskId != null) 'task_id': taskId,
      if (kind != null) 'kind': kind,
      if (valueDelta != null) 'value_delta': valueDelta,
      if (coinsDelta != null) 'coins_delta': coinsDelta,
      if (streakDelta != null) 'streak_delta': streakDelta,
      if (critical != null) 'critical': critical,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  TaskLogsCompanion copyWith({
    Value<int>? id,
    Value<int>? taskId,
    Value<LogKind>? kind,
    Value<double>? valueDelta,
    Value<int>? coinsDelta,
    Value<int>? streakDelta,
    Value<bool>? critical,
    Value<DateTime>? createdAt,
  }) {
    return TaskLogsCompanion(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      kind: kind ?? this.kind,
      valueDelta: valueDelta ?? this.valueDelta,
      coinsDelta: coinsDelta ?? this.coinsDelta,
      streakDelta: streakDelta ?? this.streakDelta,
      critical: critical ?? this.critical,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<int>(taskId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(
        $TaskLogsTable.$converterkind.toSql(kind.value),
      );
    }
    if (valueDelta.present) {
      map['value_delta'] = Variable<double>(valueDelta.value);
    }
    if (coinsDelta.present) {
      map['coins_delta'] = Variable<int>(coinsDelta.value);
    }
    if (streakDelta.present) {
      map['streak_delta'] = Variable<int>(streakDelta.value);
    }
    if (critical.present) {
      map['critical'] = Variable<bool>(critical.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TaskLogsCompanion(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('kind: $kind, ')
          ..write('valueDelta: $valueDelta, ')
          ..write('coinsDelta: $coinsDelta, ')
          ..write('streakDelta: $streakDelta, ')
          ..write('critical: $critical, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ProfilesTable extends Profiles with TableInfo<$ProfilesTable, Profile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coinsMeta = const VerificationMeta('coins');
  @override
  late final GeneratedColumn<int> coins = GeneratedColumn<int>(
    'coins',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _dayStartHourMeta = const VerificationMeta(
    'dayStartHour',
  );
  @override
  late final GeneratedColumn<int> dayStartHour = GeneratedColumn<int>(
    'day_start_hour',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _restingMeta = const VerificationMeta(
    'resting',
  );
  @override
  late final GeneratedColumn<bool> resting = GeneratedColumn<bool>(
    'resting',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("resting" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _lastRolloverDateMeta = const VerificationMeta(
    'lastRolloverDate',
  );
  @override
  late final GeneratedColumn<DateTime> lastRolloverDate =
      GeneratedColumn<DateTime>(
        'last_rollover_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    coins,
    dayStartHour,
    resting,
    lastRolloverDate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<Profile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('coins')) {
      context.handle(
        _coinsMeta,
        coins.isAcceptableOrUnknown(data['coins']!, _coinsMeta),
      );
    }
    if (data.containsKey('day_start_hour')) {
      context.handle(
        _dayStartHourMeta,
        dayStartHour.isAcceptableOrUnknown(
          data['day_start_hour']!,
          _dayStartHourMeta,
        ),
      );
    }
    if (data.containsKey('resting')) {
      context.handle(
        _restingMeta,
        resting.isAcceptableOrUnknown(data['resting']!, _restingMeta),
      );
    }
    if (data.containsKey('last_rollover_date')) {
      context.handle(
        _lastRolloverDateMeta,
        lastRolloverDate.isAcceptableOrUnknown(
          data['last_rollover_date']!,
          _lastRolloverDateMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Profile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Profile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      coins: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}coins'],
      )!,
      dayStartHour: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_start_hour'],
      )!,
      resting: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}resting'],
      )!,
      lastRolloverDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_rollover_date'],
      ),
    );
  }

  @override
  $ProfilesTable createAlias(String alias) {
    return $ProfilesTable(attachedDatabase, alias);
  }
}

class Profile extends DataClass implements Insertable<Profile> {
  final int id;
  final int coins;

  /// Giờ bắt đầu ngày mới (0–12), cho người thức khuya.
  final int dayStartHour;

  /// Bế quan: bỏ lỡ daily không bị đứt chuỗi.
  final bool resting;

  /// Ngày (logic) đã xử lý sang ngày gần nhất. Null khi chưa mở app lần nào.
  final DateTime? lastRolloverDate;
  const Profile({
    required this.id,
    required this.coins,
    required this.dayStartHour,
    required this.resting,
    this.lastRolloverDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['coins'] = Variable<int>(coins);
    map['day_start_hour'] = Variable<int>(dayStartHour);
    map['resting'] = Variable<bool>(resting);
    if (!nullToAbsent || lastRolloverDate != null) {
      map['last_rollover_date'] = Variable<DateTime>(lastRolloverDate);
    }
    return map;
  }

  ProfilesCompanion toCompanion(bool nullToAbsent) {
    return ProfilesCompanion(
      id: Value(id),
      coins: Value(coins),
      dayStartHour: Value(dayStartHour),
      resting: Value(resting),
      lastRolloverDate: lastRolloverDate == null && nullToAbsent
          ? const Value.absent()
          : Value(lastRolloverDate),
    );
  }

  factory Profile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Profile(
      id: serializer.fromJson<int>(json['id']),
      coins: serializer.fromJson<int>(json['coins']),
      dayStartHour: serializer.fromJson<int>(json['dayStartHour']),
      resting: serializer.fromJson<bool>(json['resting']),
      lastRolloverDate: serializer.fromJson<DateTime?>(
        json['lastRolloverDate'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'coins': serializer.toJson<int>(coins),
      'dayStartHour': serializer.toJson<int>(dayStartHour),
      'resting': serializer.toJson<bool>(resting),
      'lastRolloverDate': serializer.toJson<DateTime?>(lastRolloverDate),
    };
  }

  Profile copyWith({
    int? id,
    int? coins,
    int? dayStartHour,
    bool? resting,
    Value<DateTime?> lastRolloverDate = const Value.absent(),
  }) => Profile(
    id: id ?? this.id,
    coins: coins ?? this.coins,
    dayStartHour: dayStartHour ?? this.dayStartHour,
    resting: resting ?? this.resting,
    lastRolloverDate: lastRolloverDate.present
        ? lastRolloverDate.value
        : this.lastRolloverDate,
  );
  Profile copyWithCompanion(ProfilesCompanion data) {
    return Profile(
      id: data.id.present ? data.id.value : this.id,
      coins: data.coins.present ? data.coins.value : this.coins,
      dayStartHour: data.dayStartHour.present
          ? data.dayStartHour.value
          : this.dayStartHour,
      resting: data.resting.present ? data.resting.value : this.resting,
      lastRolloverDate: data.lastRolloverDate.present
          ? data.lastRolloverDate.value
          : this.lastRolloverDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Profile(')
          ..write('id: $id, ')
          ..write('coins: $coins, ')
          ..write('dayStartHour: $dayStartHour, ')
          ..write('resting: $resting, ')
          ..write('lastRolloverDate: $lastRolloverDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, coins, dayStartHour, resting, lastRolloverDate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Profile &&
          other.id == this.id &&
          other.coins == this.coins &&
          other.dayStartHour == this.dayStartHour &&
          other.resting == this.resting &&
          other.lastRolloverDate == this.lastRolloverDate);
}

class ProfilesCompanion extends UpdateCompanion<Profile> {
  final Value<int> id;
  final Value<int> coins;
  final Value<int> dayStartHour;
  final Value<bool> resting;
  final Value<DateTime?> lastRolloverDate;
  const ProfilesCompanion({
    this.id = const Value.absent(),
    this.coins = const Value.absent(),
    this.dayStartHour = const Value.absent(),
    this.resting = const Value.absent(),
    this.lastRolloverDate = const Value.absent(),
  });
  ProfilesCompanion.insert({
    this.id = const Value.absent(),
    this.coins = const Value.absent(),
    this.dayStartHour = const Value.absent(),
    this.resting = const Value.absent(),
    this.lastRolloverDate = const Value.absent(),
  });
  static Insertable<Profile> custom({
    Expression<int>? id,
    Expression<int>? coins,
    Expression<int>? dayStartHour,
    Expression<bool>? resting,
    Expression<DateTime>? lastRolloverDate,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (coins != null) 'coins': coins,
      if (dayStartHour != null) 'day_start_hour': dayStartHour,
      if (resting != null) 'resting': resting,
      if (lastRolloverDate != null) 'last_rollover_date': lastRolloverDate,
    });
  }

  ProfilesCompanion copyWith({
    Value<int>? id,
    Value<int>? coins,
    Value<int>? dayStartHour,
    Value<bool>? resting,
    Value<DateTime?>? lastRolloverDate,
  }) {
    return ProfilesCompanion(
      id: id ?? this.id,
      coins: coins ?? this.coins,
      dayStartHour: dayStartHour ?? this.dayStartHour,
      resting: resting ?? this.resting,
      lastRolloverDate: lastRolloverDate ?? this.lastRolloverDate,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (coins.present) {
      map['coins'] = Variable<int>(coins.value);
    }
    if (dayStartHour.present) {
      map['day_start_hour'] = Variable<int>(dayStartHour.value);
    }
    if (resting.present) {
      map['resting'] = Variable<bool>(resting.value);
    }
    if (lastRolloverDate.present) {
      map['last_rollover_date'] = Variable<DateTime>(lastRolloverDate.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfilesCompanion(')
          ..write('id: $id, ')
          ..write('coins: $coins, ')
          ..write('dayStartHour: $dayStartHour, ')
          ..write('resting: $resting, ')
          ..write('lastRolloverDate: $lastRolloverDate')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TasksTable tasks = $TasksTable(this);
  late final $TaskLogsTable taskLogs = $TaskLogsTable(this);
  late final $ProfilesTable profiles = $ProfilesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    tasks,
    taskLogs,
    profiles,
  ];
}

typedef $$TasksTableCreateCompanionBuilder = TasksCompanion Function({
  Value<int> id,
  required String title,
  Value<String?> notes,
  required TaskType type,
  required Difficulty difficulty,
  Value<TaskElement?> element,
  Value<bool> habitUp,
  Value<bool> habitDown,
  Value<int> dailyTarget,
  Value<int> repeatDays,
  Value<int> cost,
  Value<double> value,
  Value<int> streak,
  Value<bool> completed,
  Value<bool> archived,
  Value<int> sortOrder,
  Value<DateTime> createdAt,
});
typedef $$TasksTableUpdateCompanionBuilder = TasksCompanion Function({
  Value<int> id,
  Value<String> title,
  Value<String?> notes,
  Value<TaskType> type,
  Value<Difficulty> difficulty,
  Value<TaskElement?> element,
  Value<bool> habitUp,
  Value<bool> habitDown,
  Value<int> dailyTarget,
  Value<int> repeatDays,
  Value<int> cost,
  Value<double> value,
  Value<int> streak,
  Value<bool> completed,
  Value<bool> archived,
  Value<int> sortOrder,
  Value<DateTime> createdAt,
});

class $$TasksTableFilterComposer extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TaskType, TaskType, String> get type =>
      $composableBuilder(
        column: $table.type,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Difficulty, Difficulty, String>
  get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<TaskElement?, TaskElement, String>
  get element => $composableBuilder(
    column: $table.element,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get habitUp => $composableBuilder(
    column: $table.habitUp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get habitDown => $composableBuilder(
    column: $table.habitDown,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dailyTarget => $composableBuilder(
    column: $table.dailyTarget,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get repeatDays => $composableBuilder(
    column: $table.repeatDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cost => $composableBuilder(
    column: $table.cost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get streak => $composableBuilder(
    column: $table.streak,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TasksTableOrderingComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get element => $composableBuilder(
    column: $table.element,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get habitUp => $composableBuilder(
    column: $table.habitUp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get habitDown => $composableBuilder(
    column: $table.habitDown,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dailyTarget => $composableBuilder(
    column: $table.dailyTarget,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get repeatDays => $composableBuilder(
    column: $table.repeatDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cost => $composableBuilder(
    column: $table.cost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get streak => $composableBuilder(
    column: $table.streak,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TaskType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Difficulty, String> get difficulty =>
      $composableBuilder(
        column: $table.difficulty,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<TaskElement?, String> get element =>
      $composableBuilder(column: $table.element, builder: (column) => column);

  GeneratedColumn<bool> get habitUp =>
      $composableBuilder(column: $table.habitUp, builder: (column) => column);

  GeneratedColumn<bool> get habitDown =>
      $composableBuilder(column: $table.habitDown, builder: (column) => column);

  GeneratedColumn<int> get dailyTarget => $composableBuilder(
    column: $table.dailyTarget,
    builder: (column) => column,
  );

  GeneratedColumn<int> get repeatDays => $composableBuilder(
    column: $table.repeatDays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cost =>
      $composableBuilder(column: $table.cost, builder: (column) => column);

  GeneratedColumn<double> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<int> get streak =>
      $composableBuilder(column: $table.streak, builder: (column) => column);

  GeneratedColumn<bool> get completed =>
      $composableBuilder(column: $table.completed, builder: (column) => column);

  GeneratedColumn<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$TasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TasksTable,
          Task,
          $$TasksTableFilterComposer,
          $$TasksTableOrderingComposer,
          $$TasksTableAnnotationComposer,
          $$TasksTableCreateCompanionBuilder,
          $$TasksTableUpdateCompanionBuilder,
          (Task, BaseReferences<_$AppDatabase, $TasksTable, Task>),
          Task,
          PrefetchHooks Function()
        > {
  $$TasksTableTableManager(_$AppDatabase db, $TasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<TaskType> type = const Value.absent(),
                Value<Difficulty> difficulty = const Value.absent(),
                Value<TaskElement?> element = const Value.absent(),
                Value<bool> habitUp = const Value.absent(),
                Value<bool> habitDown = const Value.absent(),
                Value<int> dailyTarget = const Value.absent(),
                Value<int> repeatDays = const Value.absent(),
                Value<int> cost = const Value.absent(),
                Value<double> value = const Value.absent(),
                Value<int> streak = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => TasksCompanion(
                id: id,
                title: title,
                notes: notes,
                type: type,
                difficulty: difficulty,
                element: element,
                habitUp: habitUp,
                habitDown: habitDown,
                dailyTarget: dailyTarget,
                repeatDays: repeatDays,
                cost: cost,
                value: value,
                streak: streak,
                completed: completed,
                archived: archived,
                sortOrder: sortOrder,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                Value<String?> notes = const Value.absent(),
                required TaskType type,
                required Difficulty difficulty,
                Value<TaskElement?> element = const Value.absent(),
                Value<bool> habitUp = const Value.absent(),
                Value<bool> habitDown = const Value.absent(),
                Value<int> dailyTarget = const Value.absent(),
                Value<int> repeatDays = const Value.absent(),
                Value<int> cost = const Value.absent(),
                Value<double> value = const Value.absent(),
                Value<int> streak = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => TasksCompanion.insert(
                id: id,
                title: title,
                notes: notes,
                type: type,
                difficulty: difficulty,
                element: element,
                habitUp: habitUp,
                habitDown: habitDown,
                dailyTarget: dailyTarget,
                repeatDays: repeatDays,
                cost: cost,
                value: value,
                streak: streak,
                completed: completed,
                archived: archived,
                sortOrder: sortOrder,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TasksTable, Task>(table),
                  BaseReferences<_$AppDatabase, $TasksTable, Task>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TasksTable,
      Task,
      $$TasksTableFilterComposer,
      $$TasksTableOrderingComposer,
      $$TasksTableAnnotationComposer,
      $$TasksTableCreateCompanionBuilder,
      $$TasksTableUpdateCompanionBuilder,
      (Task, BaseReferences<_$AppDatabase, $TasksTable, Task>),
      Task,
      PrefetchHooks Function()
    >;
typedef $$TaskLogsTableCreateCompanionBuilder = TaskLogsCompanion Function({
  Value<int> id,
  required int taskId,
  required LogKind kind,
  Value<double> valueDelta,
  Value<int> coinsDelta,
  Value<int> streakDelta,
  Value<bool> critical,
  Value<DateTime> createdAt,
});
typedef $$TaskLogsTableUpdateCompanionBuilder = TaskLogsCompanion Function({
  Value<int> id,
  Value<int> taskId,
  Value<LogKind> kind,
  Value<double> valueDelta,
  Value<int> coinsDelta,
  Value<int> streakDelta,
  Value<bool> critical,
  Value<DateTime> createdAt,
});

class $$TaskLogsTableFilterComposer
    extends Composer<_$AppDatabase, $TaskLogsTable> {
  $$TaskLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<LogKind, LogKind, String> get kind =>
      $composableBuilder(
        column: $table.kind,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<double> get valueDelta => $composableBuilder(
    column: $table.valueDelta,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get coinsDelta => $composableBuilder(
    column: $table.coinsDelta,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get streakDelta => $composableBuilder(
    column: $table.streakDelta,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get critical => $composableBuilder(
    column: $table.critical,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TaskLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $TaskLogsTable> {
  $$TaskLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get valueDelta => $composableBuilder(
    column: $table.valueDelta,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get coinsDelta => $composableBuilder(
    column: $table.coinsDelta,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get streakDelta => $composableBuilder(
    column: $table.streakDelta,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get critical => $composableBuilder(
    column: $table.critical,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TaskLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TaskLogsTable> {
  $$TaskLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get taskId =>
      $composableBuilder(column: $table.taskId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<LogKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<double> get valueDelta => $composableBuilder(
    column: $table.valueDelta,
    builder: (column) => column,
  );

  GeneratedColumn<int> get coinsDelta => $composableBuilder(
    column: $table.coinsDelta,
    builder: (column) => column,
  );

  GeneratedColumn<int> get streakDelta => $composableBuilder(
    column: $table.streakDelta,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get critical =>
      $composableBuilder(column: $table.critical, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$TaskLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TaskLogsTable,
          TaskLog,
          $$TaskLogsTableFilterComposer,
          $$TaskLogsTableOrderingComposer,
          $$TaskLogsTableAnnotationComposer,
          $$TaskLogsTableCreateCompanionBuilder,
          $$TaskLogsTableUpdateCompanionBuilder,
          (TaskLog, BaseReferences<_$AppDatabase, $TaskLogsTable, TaskLog>),
          TaskLog,
          PrefetchHooks Function()
        > {
  $$TaskLogsTableTableManager(_$AppDatabase db, $TaskLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TaskLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TaskLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TaskLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> taskId = const Value.absent(),
                Value<LogKind> kind = const Value.absent(),
                Value<double> valueDelta = const Value.absent(),
                Value<int> coinsDelta = const Value.absent(),
                Value<int> streakDelta = const Value.absent(),
                Value<bool> critical = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => TaskLogsCompanion(
                id: id,
                taskId: taskId,
                kind: kind,
                valueDelta: valueDelta,
                coinsDelta: coinsDelta,
                streakDelta: streakDelta,
                critical: critical,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int taskId,
                required LogKind kind,
                Value<double> valueDelta = const Value.absent(),
                Value<int> coinsDelta = const Value.absent(),
                Value<int> streakDelta = const Value.absent(),
                Value<bool> critical = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => TaskLogsCompanion.insert(
                id: id,
                taskId: taskId,
                kind: kind,
                valueDelta: valueDelta,
                coinsDelta: coinsDelta,
                streakDelta: streakDelta,
                critical: critical,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TaskLogsTable, TaskLog>(table),
                  BaseReferences<_$AppDatabase, $TaskLogsTable, TaskLog>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TaskLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TaskLogsTable,
      TaskLog,
      $$TaskLogsTableFilterComposer,
      $$TaskLogsTableOrderingComposer,
      $$TaskLogsTableAnnotationComposer,
      $$TaskLogsTableCreateCompanionBuilder,
      $$TaskLogsTableUpdateCompanionBuilder,
      (TaskLog, BaseReferences<_$AppDatabase, $TaskLogsTable, TaskLog>),
      TaskLog,
      PrefetchHooks Function()
    >;
typedef $$ProfilesTableCreateCompanionBuilder = ProfilesCompanion Function({
  Value<int> id,
  Value<int> coins,
  Value<int> dayStartHour,
  Value<bool> resting,
  Value<DateTime?> lastRolloverDate,
});
typedef $$ProfilesTableUpdateCompanionBuilder = ProfilesCompanion Function({
  Value<int> id,
  Value<int> coins,
  Value<int> dayStartHour,
  Value<bool> resting,
  Value<DateTime?> lastRolloverDate,
});

class $$ProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get coins => $composableBuilder(
    column: $table.coins,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dayStartHour => $composableBuilder(
    column: $table.dayStartHour,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get resting => $composableBuilder(
    column: $table.resting,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastRolloverDate => $composableBuilder(
    column: $table.lastRolloverDate,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get coins => $composableBuilder(
    column: $table.coins,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dayStartHour => $composableBuilder(
    column: $table.dayStartHour,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get resting => $composableBuilder(
    column: $table.resting,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastRolloverDate => $composableBuilder(
    column: $table.lastRolloverDate,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get coins =>
      $composableBuilder(column: $table.coins, builder: (column) => column);

  GeneratedColumn<int> get dayStartHour => $composableBuilder(
    column: $table.dayStartHour,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get resting =>
      $composableBuilder(column: $table.resting, builder: (column) => column);

  GeneratedColumn<DateTime> get lastRolloverDate => $composableBuilder(
    column: $table.lastRolloverDate,
    builder: (column) => column,
  );
}

class $$ProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProfilesTable,
          Profile,
          $$ProfilesTableFilterComposer,
          $$ProfilesTableOrderingComposer,
          $$ProfilesTableAnnotationComposer,
          $$ProfilesTableCreateCompanionBuilder,
          $$ProfilesTableUpdateCompanionBuilder,
          (Profile, BaseReferences<_$AppDatabase, $ProfilesTable, Profile>),
          Profile,
          PrefetchHooks Function()
        > {
  $$ProfilesTableTableManager(_$AppDatabase db, $ProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> coins = const Value.absent(),
                Value<int> dayStartHour = const Value.absent(),
                Value<bool> resting = const Value.absent(),
                Value<DateTime?> lastRolloverDate = const Value.absent(),
              }) => ProfilesCompanion(
                id: id,
                coins: coins,
                dayStartHour: dayStartHour,
                resting: resting,
                lastRolloverDate: lastRolloverDate,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> coins = const Value.absent(),
                Value<int> dayStartHour = const Value.absent(),
                Value<bool> resting = const Value.absent(),
                Value<DateTime?> lastRolloverDate = const Value.absent(),
              }) => ProfilesCompanion.insert(
                id: id,
                coins: coins,
                dayStartHour: dayStartHour,
                resting: resting,
                lastRolloverDate: lastRolloverDate,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProfilesTable, Profile>(table),
                  BaseReferences<_$AppDatabase, $ProfilesTable, Profile>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProfilesTable,
      Profile,
      $$ProfilesTableFilterComposer,
      $$ProfilesTableOrderingComposer,
      $$ProfilesTableAnnotationComposer,
      $$ProfilesTableCreateCompanionBuilder,
      $$ProfilesTableUpdateCompanionBuilder,
      (Profile, BaseReferences<_$AppDatabase, $ProfilesTable, Profile>),
      Profile,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db, _db.tasks);
  $$TaskLogsTableTableManager get taskLogs =>
      $$TaskLogsTableTableManager(_db, _db.taskLogs);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db, _db.profiles);
}
