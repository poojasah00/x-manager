import 'package:drift/drift.dart';
import '../local/category_database.dart';

class CategoryRepository {
  final CategoryDatabase db;
  CategoryRepository(this.db);

  Future<List<DbCategory>> getAllCategories() => db.getAllCategories();
  Future<int> insertCategory(DbCategoriesCompanion entry) =>
      db.insertCategory(entry);
  Future<int> updateCategory(int id, DbCategoriesCompanion entry) =>
      db.updateCategory(id, entry);
  Future<int> deleteCategory(int id) => db.deleteCategory(id);
}
