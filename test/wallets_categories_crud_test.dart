import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' show Value;
import 'package:x_manager/data/local/app_database.dart';
import 'package:x_manager/data/sample_data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Wallets and Categories CRUD', () {
    late AppDatabase db;

    setUp(() async {
      db = AppDatabase.inMemory();
      await seedSampleData(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('Create, update, delete wallet', () async {
      final res = await db.insertWallet(
        WalletsCompanion.insert(
          name: 'TestWallet',
          balance: Value(10.0),
          type: 'cash',
        ),
      );
      expect(res, isNonZero);

      final wallets = await db.getAllWallets();
      final w = wallets.firstWhere((e) => e.name == 'TestWallet');
      expect(w.balance, 10.0);

      await db.updateWallet(
        w.id,
        WalletsCompanion(
          balance: Value(25.0),
          name: Value(w.name),
          type: Value(w.type),
        ),
      );
      final w2 = (await db.getAllWallets()).firstWhere((e) => e.id == w.id);
      expect(w2.balance, 25.0);

      await db.deleteWallet(w.id);
      final walletsAfter = await db.getAllWallets();
      expect(walletsAfter.any((e) => e.id == w.id), isFalse);
    });

    test('Create, update, delete category', () async {
      final res = await db.insertCategory(
        CategoriesCompanion.insert(name: 'TestCat', type: 'expense'),
      );
      expect(res, isNonZero);

      final cats = await db.getAllCategories();
      final c = cats.firstWhere((e) => e.name == 'TestCat');
      expect(c.type, 'expense');

      await db.updateCategory(
        c.id,
        CategoriesCompanion(name: Value('UpdatedCat'), type: Value('income')),
      );
      final c2 = (await db.getAllCategories()).firstWhere((e) => e.id == c.id);
      expect(c2.name, 'UpdatedCat');
      expect(c2.type, 'income');

      await db.deleteCategory(c.id);
      final catsAfter = await db.getAllCategories();
      expect(catsAfter.any((e) => e.id == c.id), isFalse);
    });
  });
}
