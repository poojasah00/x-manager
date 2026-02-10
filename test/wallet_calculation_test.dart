import 'package:flutter_test/flutter_test.dart';
import 'package:x_manager/data/local/app_database.dart';
import 'package:x_manager/data/sample_data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Seeded wallets exist with expected balances', () async {
    final db = AppDatabase.inMemory();
    await seedSampleData(db);

    final bank = await db.getWalletByName('Bank');
    final cash = await db.getWalletByName('Cash');

    expect(bank, isNotNull);
    expect(cash, isNotNull);
    expect(bank!.balance, equals(1000.0));
    expect(cash!.balance, equals(200.0));

    await db.close();
  });
}
