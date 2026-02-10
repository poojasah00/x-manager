import 'package:drift/drift.dart';
import 'package:x_manager/data/local/app_database.dart';

Future<void> seedSampleData(AppDatabase db) async {
  final existingBank = await db.getWalletByName('Bank');
  final existingCash = await db.getWalletByName('Cash');
  if (existingBank == null) {
    await db.insertWallet(
      WalletsCompanion(
        name: Value('Bank'),
        balance: Value(1000.0),
        type: Value('bank'),
      ),
    );
  }
  if (existingCash == null) {
    await db.insertWallet(
      WalletsCompanion(
        name: Value('Cash'),
        balance: Value(200.0),
        type: Value('cash'),
      ),
    );
  }

  // Insert basic categories if none exist
  final cats = await db.select(db.categories).get();
  if (cats.isEmpty) {
    await db
        .into(db.categories)
        .insert(CategoriesCompanion.insert(name: 'Salary', type: 'income'));
    await db
        .into(db.categories)
        .insert(CategoriesCompanion.insert(name: 'Groceries', type: 'expense'));
    await db
        .into(db.categories)
        .insert(CategoriesCompanion.insert(name: 'Transport', type: 'expense'));
  }
}
