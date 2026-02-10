import 'package:flutter_test/flutter_test.dart';
import 'package:x_manager/data/local/app_database.dart';
import 'package:x_manager/data/repositories/transaction_repository.dart';
import 'package:x_manager/data/sample_data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Transaction logic', () {
    late AppDatabase db;
    late TransactionRepository repo;

    setUp(() async {
      db = AppDatabase.inMemory();
      await seedSampleData(db);
      repo = TransactionRepository(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('ATM Cash Out transfers from Bank to Cash', () async {
      final bank = await db.getWalletByName('Bank');
      final cash = await db.getWalletByName('Cash');
      expect(bank, isNotNull);
      expect(cash, isNotNull);

      final initialBank = bank!.balance;
      final initialCash = cash!.balance;

      await repo.addTransaction(
        amount: 150.0,
        date: DateTime.now(),
        type: 'ATM Cash Out',
        paymentMode: 'Online',
        walletId: bank.id,
      );

      final bankAfter = await db.getWalletByName('Bank');
      final cashAfter = await db.getWalletByName('Cash');

      expect(bankAfter!.balance, equals(initialBank - 150.0));
      expect(cashAfter!.balance, equals(initialCash + 150.0));
    });

    test('Expense paid in cash deducts from Cash wallet', () async {
      final cash = await db.getWalletByName('Cash');
      final initialCash = cash!.balance;

      await repo.addTransaction(
        amount: 25.5,
        date: DateTime.now(),
        type: 'Expense',
        paymentMode: 'Cash',
        walletId: cash.id,
      );

      final cashAfter = await db.getWalletByName('Cash');
      expect(cashAfter!.balance, equals(initialCash - 25.5));
    });

    test('Income received online adds to Bank wallet', () async {
      final bank = await db.getWalletByName('Bank');
      final initialBank = bank!.balance;

      await repo.addTransaction(
        amount: 500.0,
        date: DateTime.now(),
        type: 'Income',
        paymentMode: 'Online',
        walletId: bank.id,
      );

      final bankAfter = await db.getWalletByName('Bank');
      expect(bankAfter!.balance, equals(initialBank + 500.0));
    });
  });
}
