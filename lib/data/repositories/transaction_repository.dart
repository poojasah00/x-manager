import 'package:drift/drift.dart';
import 'package:x_manager/data/local/app_database.dart';

class TransactionRepository {
  final AppDatabase db;
  TransactionRepository(this.db);

  /// Adds a transaction and updates wallets accordingly. Handles ATM Cash Out by
  /// transferring from Bank to Cash.
  Future<void> addTransaction({
    required double amount,
    required DateTime date,
    required String type,
    required String paymentMode,
    required int walletId,
    int? categoryId,
    String? note,
  }) async {
    return await db.transaction(() async {
      // Insert transaction
      await db.insertTransaction(
        TransactionsCompanion.insert(
          amount: amount,
          date: date,
          type: type,
          paymentMode: paymentMode,
          walletId: walletId,
          categoryId: Value(categoryId),
          note: Value(note),
        ),
      );

      // Update wallets based on type
      if (type == 'ATM Cash Out') {
        // Deduct from bank (walletId provided should be Bank) and add to Cash
        final bank = await db.getWalletByName('Bank');
        final cash = await db.getWalletByName('Cash');
        if (bank != null && cash != null) {
          await db.updateWalletBalance(bank.id, bank.balance - amount);
          await db.updateWalletBalance(cash.id, cash.balance + amount);
        }
      } else if (type == 'Expense') {
        final w = await db.getWalletByName(
          paymentMode == 'Cash' ? 'Cash' : 'Bank',
        );
        if (w != null) {
          await db.updateWalletBalance(w.id, w.balance - amount);
        }
      } else if (type == 'Income') {
        final w = await db.getWalletByName(
          paymentMode == 'Cash' ? 'Cash' : 'Bank',
        );
        if (w != null) {
          await db.updateWalletBalance(w.id, w.balance + amount);
        }
      }
      // Loans handling should be implemented here as needed.
    });
  }
}
