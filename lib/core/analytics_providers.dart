import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_manager/core/providers.dart';

final analyticsSummaryProvider = FutureProvider<AnalyticsSummary>((ref) async {
  final db = ref.read(databaseProvider);
  final now = DateTime.now();

  // Last 7 days
  final sevenDaysAgo = now.subtract(const Duration(days: 7));
  final last7 = await db.getTransactions(start: sevenDaysAgo, end: now);
  final last7Income = last7
      .where((t) => t.type == 'Income')
      .fold<double>(0, (p, e) => p + e.amount);
  final last7Expense = last7
      .where((t) => t.type == 'Expense')
      .fold<double>(0, (p, e) => p + e.amount);

  // ATM this month
  final monthStart = DateTime(now.year, now.month, 1);
  final atmThisMonthTransactions = await db.getTransactions(
    start: monthStart,
    end: now,
  );
  final atmThisMonth = atmThisMonthTransactions
      .where((t) => t.type == 'ATM Cash Out')
      .fold<double>(0, (p, e) => p + e.amount);

  // Cash balance
  final cashBalance = await db.getWalletBalanceByName('Cash') ?? 0.0;

  return AnalyticsSummary(
    last7Income: last7Income,
    last7Expense: last7Expense,
    atmThisMonth: atmThisMonth,
    cashBalance: cashBalance,
  );
});

final monthlyIncomeExpenseProvider = FutureProvider<List<MonthlyPoint>>((
  ref,
) async {
  final db = ref.read(databaseProvider);
  final now = DateTime.now();
  final List<MonthlyPoint> points = [];

  for (int i = 11; i >= 0; i--) {
    final m = DateTime(now.year, now.month - i, 1);
    final start = DateTime(m.year, m.month, 1);
    final end = DateTime(
      m.year,
      m.month + 1,
      1,
    ).subtract(const Duration(seconds: 1));
    final txs = await db.getTransactions(start: start, end: end);
    final income = txs
        .where((t) => t.type == 'Income')
        .fold<double>(0, (p, e) => p + e.amount);
    final expense = txs
        .where((t) => t.type == 'Expense')
        .fold<double>(0, (p, e) => p + e.amount);
    points.add(
      MonthlyPoint(
        month: DateTime(start.year, start.month),
        income: income,
        expense: expense,
      ),
    );
  }

  return points;
});

final categoryExpensesProvider = FutureProvider<List<CategoryPoint>>((
  ref,
) async {
  final db = ref.read(databaseProvider);
  final txs = await db.getTransactions();
  final Map<int, double> sums = {};

  for (final t in txs.where((t) => t.type == 'Expense')) {
    final cid = t.categoryId;
    if (cid == null) continue;
    sums[cid] = (sums[cid] ?? 0) + t.amount;
  }

  final cats = await db.getAllCategories();
  final result = <CategoryPoint>[];
  for (final c in cats) {
    final sum = sums[c.id] ?? 0.0;
    if (sum > 0) result.add(CategoryPoint(categoryName: c.name, amount: sum));
  }
  return result;
});

class AnalyticsSummary {
  final double last7Income;
  final double last7Expense;
  final double atmThisMonth;
  final double cashBalance;
  AnalyticsSummary({
    required this.last7Income,
    required this.last7Expense,
    required this.atmThisMonth,
    required this.cashBalance,
  });
}

class MonthlyPoint {
  final DateTime month;
  final double income;
  final double expense;
  MonthlyPoint({
    required this.month,
    required this.income,
    required this.expense,
  });
}

class CategoryPoint {
  final String categoryName;
  final double amount;
  CategoryPoint({required this.categoryName, required this.amount});
}
