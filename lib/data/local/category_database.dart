import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'category_database.g.dart';

class DbCategories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get svgIcon => text()(); // SVG asset path or raw SVG string
  TextColumn get transactionType =>
      text()(); // income, expense, loan given, loan taken, atm cash out
}

@DriftDatabase(tables: [DbCategories])
class CategoryDatabase extends _$CategoryDatabase {
  CategoryDatabase() : super(_openCategoryConnection());

  @override
  int get schemaVersion => 1;

  Future<int> insertCategory(DbCategoriesCompanion entry) =>
      into(dbCategories).insert(entry);

  Future<int> updateCategory(int id, DbCategoriesCompanion entry) =>
      (update(dbCategories)..where((c) => c.id.equals(id))).write(entry);

  Future<int> deleteCategory(int id) =>
      (delete(dbCategories)..where((c) => c.id.equals(id))).go();

  Future<List<DbCategory>> getAllCategories() => select(dbCategories).get();
}

LazyDatabase _openCategoryConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(dbFolder.path, 'drift'));
    if (!dir.existsSync()) dir.createSync(recursive: true);
    final file = File(p.join(dir.path, 'category.sqlite'));
    return NativeDatabase(file);
  });
}
