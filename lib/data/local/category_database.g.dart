// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_database.dart';

// ignore_for_file: type=lint
class $DbCategoriesTable extends DbCategories
    with TableInfo<$DbCategoriesTable, DbCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DbCategoriesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _svgIconMeta = const VerificationMeta(
    'svgIcon',
  );
  @override
  late final GeneratedColumn<String> svgIcon = GeneratedColumn<String>(
    'svg_icon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transactionTypeMeta = const VerificationMeta(
    'transactionType',
  );
  @override
  late final GeneratedColumn<String> transactionType = GeneratedColumn<String>(
    'transaction_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, svgIcon, transactionType];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'db_categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbCategory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('svg_icon')) {
      context.handle(
        _svgIconMeta,
        svgIcon.isAcceptableOrUnknown(data['svg_icon']!, _svgIconMeta),
      );
    } else if (isInserting) {
      context.missing(_svgIconMeta);
    }
    if (data.containsKey('transaction_type')) {
      context.handle(
        _transactionTypeMeta,
        transactionType.isAcceptableOrUnknown(
          data['transaction_type']!,
          _transactionTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionTypeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbCategory(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      svgIcon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}svg_icon'],
      )!,
      transactionType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaction_type'],
      )!,
    );
  }

  @override
  $DbCategoriesTable createAlias(String alias) {
    return $DbCategoriesTable(attachedDatabase, alias);
  }
}

class DbCategory extends DataClass implements Insertable<DbCategory> {
  final int id;
  final String name;
  final String svgIcon;
  final String transactionType;
  const DbCategory({
    required this.id,
    required this.name,
    required this.svgIcon,
    required this.transactionType,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['svg_icon'] = Variable<String>(svgIcon);
    map['transaction_type'] = Variable<String>(transactionType);
    return map;
  }

  DbCategoriesCompanion toCompanion(bool nullToAbsent) {
    return DbCategoriesCompanion(
      id: Value(id),
      name: Value(name),
      svgIcon: Value(svgIcon),
      transactionType: Value(transactionType),
    );
  }

  factory DbCategory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbCategory(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      svgIcon: serializer.fromJson<String>(json['svgIcon']),
      transactionType: serializer.fromJson<String>(json['transactionType']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'svgIcon': serializer.toJson<String>(svgIcon),
      'transactionType': serializer.toJson<String>(transactionType),
    };
  }

  DbCategory copyWith({
    int? id,
    String? name,
    String? svgIcon,
    String? transactionType,
  }) => DbCategory(
    id: id ?? this.id,
    name: name ?? this.name,
    svgIcon: svgIcon ?? this.svgIcon,
    transactionType: transactionType ?? this.transactionType,
  );
  DbCategory copyWithCompanion(DbCategoriesCompanion data) {
    return DbCategory(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      svgIcon: data.svgIcon.present ? data.svgIcon.value : this.svgIcon,
      transactionType: data.transactionType.present
          ? data.transactionType.value
          : this.transactionType,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbCategory(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('svgIcon: $svgIcon, ')
          ..write('transactionType: $transactionType')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, svgIcon, transactionType);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbCategory &&
          other.id == this.id &&
          other.name == this.name &&
          other.svgIcon == this.svgIcon &&
          other.transactionType == this.transactionType);
}

class DbCategoriesCompanion extends UpdateCompanion<DbCategory> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> svgIcon;
  final Value<String> transactionType;
  const DbCategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.svgIcon = const Value.absent(),
    this.transactionType = const Value.absent(),
  });
  DbCategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String svgIcon,
    required String transactionType,
  }) : name = Value(name),
       svgIcon = Value(svgIcon),
       transactionType = Value(transactionType);
  static Insertable<DbCategory> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? svgIcon,
    Expression<String>? transactionType,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (svgIcon != null) 'svg_icon': svgIcon,
      if (transactionType != null) 'transaction_type': transactionType,
    });
  }

  DbCategoriesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? svgIcon,
    Value<String>? transactionType,
  }) {
    return DbCategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      svgIcon: svgIcon ?? this.svgIcon,
      transactionType: transactionType ?? this.transactionType,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (svgIcon.present) {
      map['svg_icon'] = Variable<String>(svgIcon.value);
    }
    if (transactionType.present) {
      map['transaction_type'] = Variable<String>(transactionType.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DbCategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('svgIcon: $svgIcon, ')
          ..write('transactionType: $transactionType')
          ..write(')'))
        .toString();
  }
}

abstract class _$CategoryDatabase extends GeneratedDatabase {
  _$CategoryDatabase(QueryExecutor e) : super(e);
  $CategoryDatabaseManager get managers => $CategoryDatabaseManager(this);
  late final $DbCategoriesTable dbCategories = $DbCategoriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [dbCategories];
}

typedef $$DbCategoriesTableCreateCompanionBuilder =
    DbCategoriesCompanion Function({
      Value<int> id,
      required String name,
      required String svgIcon,
      required String transactionType,
    });
typedef $$DbCategoriesTableUpdateCompanionBuilder =
    DbCategoriesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> svgIcon,
      Value<String> transactionType,
    });

class $$DbCategoriesTableFilterComposer
    extends Composer<_$CategoryDatabase, $DbCategoriesTable> {
  $$DbCategoriesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get svgIcon => $composableBuilder(
    column: $table.svgIcon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transactionType => $composableBuilder(
    column: $table.transactionType,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DbCategoriesTableOrderingComposer
    extends Composer<_$CategoryDatabase, $DbCategoriesTable> {
  $$DbCategoriesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get svgIcon => $composableBuilder(
    column: $table.svgIcon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transactionType => $composableBuilder(
    column: $table.transactionType,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DbCategoriesTableAnnotationComposer
    extends Composer<_$CategoryDatabase, $DbCategoriesTable> {
  $$DbCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get svgIcon =>
      $composableBuilder(column: $table.svgIcon, builder: (column) => column);

  GeneratedColumn<String> get transactionType => $composableBuilder(
    column: $table.transactionType,
    builder: (column) => column,
  );
}

class $$DbCategoriesTableTableManager
    extends
        RootTableManager<
          _$CategoryDatabase,
          $DbCategoriesTable,
          DbCategory,
          $$DbCategoriesTableFilterComposer,
          $$DbCategoriesTableOrderingComposer,
          $$DbCategoriesTableAnnotationComposer,
          $$DbCategoriesTableCreateCompanionBuilder,
          $$DbCategoriesTableUpdateCompanionBuilder,
          (
            DbCategory,
            BaseReferences<_$CategoryDatabase, $DbCategoriesTable, DbCategory>,
          ),
          DbCategory,
          PrefetchHooks Function()
        > {
  $$DbCategoriesTableTableManager(
    _$CategoryDatabase db,
    $DbCategoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DbCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DbCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DbCategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> svgIcon = const Value.absent(),
                Value<String> transactionType = const Value.absent(),
              }) => DbCategoriesCompanion(
                id: id,
                name: name,
                svgIcon: svgIcon,
                transactionType: transactionType,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String svgIcon,
                required String transactionType,
              }) => DbCategoriesCompanion.insert(
                id: id,
                name: name,
                svgIcon: svgIcon,
                transactionType: transactionType,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DbCategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$CategoryDatabase,
      $DbCategoriesTable,
      DbCategory,
      $$DbCategoriesTableFilterComposer,
      $$DbCategoriesTableOrderingComposer,
      $$DbCategoriesTableAnnotationComposer,
      $$DbCategoriesTableCreateCompanionBuilder,
      $$DbCategoriesTableUpdateCompanionBuilder,
      (
        DbCategory,
        BaseReferences<_$CategoryDatabase, $DbCategoriesTable, DbCategory>,
      ),
      DbCategory,
      PrefetchHooks Function()
    >;

class $CategoryDatabaseManager {
  final _$CategoryDatabase _db;
  $CategoryDatabaseManager(this._db);
  $$DbCategoriesTableTableManager get dbCategories =>
      $$DbCategoriesTableTableManager(_db, _db.dbCategories);
}
