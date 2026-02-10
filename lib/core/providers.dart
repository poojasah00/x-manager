import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_manager/data/local/app_database.dart';
import 'package:x_manager/data/repositories/transaction_repository.dart';
import 'package:x_manager/data/repositories/loan_repository.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() {
    db.close();
  });
  return db;
});

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final db = ref.read(databaseProvider);
  return TransactionRepository(db);
});

final loanRepositoryProvider = Provider<LoanRepository>((ref) {
  final db = ref.read(databaseProvider);
  return LoanRepository(db);
});

final loansProvider = FutureProvider<List<Loan>>((ref) async {
  final repo = ref.read(loanRepositoryProvider);
  return repo.getAllLoans();
});

final walletsProvider = FutureProvider<List<Wallet>>((ref) async {
  final db = ref.read(databaseProvider);
  return db.getAllWallets();
});

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final db = ref.read(databaseProvider);
  return db.getAllCategories();
});

final balancesProvider = FutureProvider<Map<String, double>>((ref) async {
  final db = ref.read(databaseProvider);
  final bank = await db.getWalletBalanceByName('Bank');
  final cash = await db.getWalletBalanceByName('Cash');
  final b = bank ?? 0.0;
  final c = cash ?? 0.0;
  return {'bank': b, 'cash': c, 'total': b + c};
});

final transactionSearchQueryProvider = StateProvider<String>((ref) => '');
final transactionSortByProvider = StateProvider<String>((ref) => 'dateDesc');

final transactionsProvider = FutureProvider<List<Transaction>>((ref) async {
  final db = ref.read(databaseProvider);
  final query = ref.watch(transactionSearchQueryProvider);
  final sortBy = ref.watch(transactionSortByProvider);
  return db.getTransactions(query: query, sortBy: sortBy);
});
