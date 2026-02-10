import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

class Wallets extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  RealColumn get balance => real().withDefault(const Constant(0.0))();
  TextColumn get type => text()(); // 'bank' | 'cash'
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get type => text()(); // income | expense
  TextColumn get color => text().nullable()();
}

class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get amount => real()();
  DateTimeColumn get date => dateTime()();
  TextColumn get type =>
      text()(); // Income, Expense, Loan Given, Loan Taken, ATM Cash Out
  TextColumn get paymentMode => text()(); // Cash or Online
  IntColumn get walletId => integer().references(Wallets, #id)();
  IntColumn get categoryId =>
      integer().nullable().references(Categories, #id)();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class Loans extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get person => text()();
  RealColumn get amount => real()();
  DateTimeColumn get dueDate => dateTime()();
  TextColumn get status => text()(); // Paid / Unpaid
  RealColumn get remaining => real()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [Wallets, Categories, Transactions, Loans])
class AppDatabase extends _$AppDatabase {
  /// Default file-based constructor (used by the app).
  AppDatabase() : super(_openConnection());

  /// Connect to a custom [QueryExecutor] (useful for tests).
  AppDatabase.connect(QueryExecutor e) : super(e);

  /// Create an in-memory database (recommended for tests).
  factory AppDatabase.inMemory() =>
      AppDatabase.connect(NativeDatabase.memory());

  @override
  int get schemaVersion => 1;

  Future<double?> getWalletBalanceByName(String name) async {
    final q = select(wallets)..where((w) => w.name.equals(name));
    final r = await q.getSingleOrNull();
    return r?.balance;
  }

  Future<Wallet?> getWalletByName(String name) async {
    final q = select(wallets)..where((w) => w.name.equals(name));
    return q.getSingleOrNull();
  }

  Future<int> updateWalletBalance(int id, double newBalance) {
    return (update(wallets)..where((w) => w.id.equals(id))).write(
      WalletsCompanion(balance: Value(newBalance)),
    );
  }

  Future<int> insertWallet(WalletsCompanion entry) =>
      into(wallets).insert(entry);

  Future<int> updateWallet(int id, WalletsCompanion entry) =>
      (update(wallets)..where((w) => w.id.equals(id))).write(entry);

  Future<int> deleteWallet(int id) =>
      (delete(wallets)..where((w) => w.id.equals(id))).go();

  Future<int> insertTransaction(TransactionsCompanion entry) =>
      into(transactions).insert(entry);

  Future<List<Wallet>> getAllWallets() => select(wallets).get();

  Future<int> insertCategory(CategoriesCompanion entry) =>
      into(categories).insert(entry);

  Future<int> updateCategory(int id, CategoriesCompanion entry) =>
      (update(categories)..where((c) => c.id.equals(id))).write(entry);

  Future<int> deleteCategory(int id) =>
      (delete(categories)..where((c) => c.id.equals(id))).go();

  Future<List<Category>> getAllCategories() => select(categories).get();

  // Loans CRUD
  Future<int> insertLoan(LoansCompanion entry) => into(loans).insert(entry);

  Future<int> updateLoan(int id, LoansCompanion entry) =>
      (update(loans)..where((l) => l.id.equals(id))).write(entry);

  Future<int> deleteLoan(int id) =>
      (delete(loans)..where((l) => l.id.equals(id))).go();

  Future<List<Loan>> getAllLoans() => select(loans).get();

  Future<Loan?> getLoanById(int id) =>
      (select(loans)..where((l) => l.id.equals(id))).getSingleOrNull();

  Future<List<Transaction>> getLastTransactions({int limit = 50}) {
    return (select(transactions)
          ..orderBy([
            (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc),
          ])
          ..limit(limit))
        .get();
  }

  /// Fetch transactions with optional filters (keyword in note/type, date range).
  Future<List<Transaction>> getTransactions({
    String? query,
    DateTime? start,
    DateTime? end,
    String sortBy = 'dateDesc',
  }) async {
    var q = select(transactions)
      ..orderBy([
        (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc),
      ]);

    final rows = await q.get();

    var filtered = rows.where((r) {
      if (start != null && r.date.isBefore(start)) return false;
      if (end != null && r.date.isAfter(end)) return false;
      if (query != null && query.isNotEmpty) {
        final qLower = query.toLowerCase();
        if ((r.note ?? '').toLowerCase().contains(qLower) ||
            r.type.toLowerCase().contains(qLower)) {
          return true;
        }
        return false;
      }
      return true;
    }).toList();

    if (sortBy == 'amountAsc') {
      filtered.sort((a, b) => a.amount.compareTo(b.amount));
    } else if (sortBy == 'amountDesc') {
      filtered.sort((a, b) => b.amount.compareTo(a.amount));
    } else if (sortBy == 'dateAsc') {
      filtered.sort((a, b) => a.date.compareTo(b.date));
    } else {
      filtered.sort((a, b) => b.date.compareTo(a.date));
    }

    return filtered;
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(dbFolder.path, 'drift'));
    if (!dir.existsSync()) dir.createSync(recursive: true);
    final file = File(p.join(dir.path, 'app.sqlite'));
    return NativeDatabase(file);
  });
}
