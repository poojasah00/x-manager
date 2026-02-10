import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:x_manager/data/local/app_database.dart';
import 'package:x_manager/data/sample_data.dart';
import 'package:x_manager/core/providers.dart';
import 'package:x_manager/core/analytics_providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Analytics summary computes correct values', () async {
    final db = AppDatabase.inMemory();
    await seedSampleData(db);

    // add some transactions
    await db.insertTransaction(
      TransactionsCompanion.insert(
        amount: 100.0,
        date: DateTime.now().subtract(const Duration(days: 1)),
        type: 'Income',
        paymentMode: 'Online',
        walletId: 1,
      ),
    );
    await db.insertTransaction(
      TransactionsCompanion.insert(
        amount: 40.0,
        date: DateTime.now().subtract(const Duration(days: 1)),
        type: 'Expense',
        paymentMode: 'Cash',
        walletId: 2,
      ),
    );
    await db.insertTransaction(
      TransactionsCompanion.insert(
        amount: 200.0,
        date: DateTime.now(),
        type: 'ATM Cash Out',
        paymentMode: 'Online',
        walletId: 1,
      ),
    );

    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    final summary = await container.read(analyticsSummaryProvider.future);
    expect(summary.last7Income, greaterThanOrEqualTo(100.0));
    expect(summary.last7Expense, greaterThanOrEqualTo(40.0));
    expect(summary.atmThisMonth, greaterThanOrEqualTo(200.0));

    await db.close();
  });
}
