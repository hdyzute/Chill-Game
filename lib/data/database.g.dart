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
    repeatDays,
    cost,
    value,
    streak,
    completed,
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

  /// Hằng ngày: các ngày lặp, xem [weekdayLabels].
  final int repeatDays;

  /// Phần thưởng: giá bằng xu.
  final int cost;
  final double value;
  final int streak;
  final bool completed;
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
    required this.repeatDays,
    required this.cost,
    required this.value,
    required this.streak,
    required this.completed,
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
    map['repeat_days'] = Variable<int>(repeatDays);
    map['cost'] = Variable<int>(cost);
    map['value'] = Variable<double>(value);
    map['streak'] = Variable<int>(streak);
    map['completed'] = Variable<bool>(completed);
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
      repeatDays: Value(repeatDays),
      cost: Value(cost),
      value: Value(value),
      streak: Value(streak),
      completed: Value(completed),
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
      repeatDays: serializer.fromJson<int>(json['repeatDays']),
      cost: serializer.fromJson<int>(json['cost']),
      value: serializer.fromJson<double>(json['value']),
      streak: serializer.fromJson<int>(json['streak']),
      completed: serializer.fromJson<bool>(json['completed']),
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
      'repeatDays': serializer.toJson<int>(repeatDays),
      'cost': serializer.toJson<int>(cost),
      'value': serializer.toJson<double>(value),
      'streak': serializer.toJson<int>(streak),
      'completed': serializer.toJson<bool>(completed),
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
    int? repeatDays,
    int? cost,
    double? value,
    int? streak,
    bool? completed,
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
    repeatDays: repeatDays ?? this.repeatDays,
    cost: cost ?? this.cost,
    value: value ?? this.value,
    streak: streak ?? this.streak,
    completed: completed ?? this.completed,
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
      repeatDays: data.repeatDays.present
          ? data.repeatDays.value
          : this.repeatDays,
      cost: data.cost.present ? data.cost.value : this.cost,
      value: data.value.present ? data.value.value : this.value,
      streak: data.streak.present ? data.streak.value : this.streak,
      completed: data.completed.present ? data.completed.value : this.completed,
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
          ..write('repeatDays: $repeatDays, ')
          ..write('cost: $cost, ')
          ..write('value: $value, ')
          ..write('streak: $streak, ')
          ..write('completed: $completed, ')
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
    repeatDays,
    cost,
    value,
    streak,
    completed,
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
          other.repeatDays == this.repeatDays &&
          other.cost == this.cost &&
          other.value == this.value &&
          other.streak == this.streak &&
          other.completed == this.completed &&
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
  final Value<int> repeatDays;
  final Value<int> cost;
  final Value<double> value;
  final Value<int> streak;
  final Value<bool> completed;
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
    this.repeatDays = const Value.absent(),
    this.cost = const Value.absent(),
    this.value = const Value.absent(),
    this.streak = const Value.absent(),
    this.completed = const Value.absent(),
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
    this.repeatDays = const Value.absent(),
    this.cost = const Value.absent(),
    this.value = const Value.absent(),
    this.streak = const Value.absent(),
    this.completed = const Value.absent(),
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
    Expression<int>? repeatDays,
    Expression<int>? cost,
    Expression<double>? value,
    Expression<int>? streak,
    Expression<bool>? completed,
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
      if (repeatDays != null) 'repeat_days': repeatDays,
      if (cost != null) 'cost': cost,
      if (value != null) 'value': value,
      if (streak != null) 'streak': streak,
      if (completed != null) 'completed': completed,
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
    Value<int>? repeatDays,
    Value<int>? cost,
    Value<double>? value,
    Value<int>? streak,
    Value<bool>? completed,
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
      repeatDays: repeatDays ?? this.repeatDays,
      cost: cost ?? this.cost,
      value: value ?? this.value,
      streak: streak ?? this.streak,
      completed: completed ?? this.completed,
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
          ..write('repeatDays: $repeatDays, ')
          ..write('cost: $cost, ')
          ..write('value: $value, ')
          ..write('streak: $streak, ')
          ..write('completed: $completed, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TasksTable tasks = $TasksTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [tasks];
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
  Value<int> repeatDays,
  Value<int> cost,
  Value<double> value,
  Value<int> streak,
  Value<bool> completed,
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
  Value<int> repeatDays,
  Value<int> cost,
  Value<double> value,
  Value<int> streak,
  Value<bool> completed,
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
                Value<int> repeatDays = const Value.absent(),
                Value<int> cost = const Value.absent(),
                Value<double> value = const Value.absent(),
                Value<int> streak = const Value.absent(),
                Value<bool> completed = const Value.absent(),
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
                repeatDays: repeatDays,
                cost: cost,
                value: value,
                streak: streak,
                completed: completed,
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
                Value<int> repeatDays = const Value.absent(),
                Value<int> cost = const Value.absent(),
                Value<double> value = const Value.absent(),
                Value<int> streak = const Value.absent(),
                Value<bool> completed = const Value.absent(),
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
                repeatDays: repeatDays,
                cost: cost,
                value: value,
                streak: streak,
                completed: completed,
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

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db, _db.tasks);
}
