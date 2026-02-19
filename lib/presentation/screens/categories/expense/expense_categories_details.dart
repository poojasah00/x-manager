import 'package:flutter/material.dart';
import 'package:x_manager/presentation/screens/transaction/add_transaction_screen.dart';
import '../../../widgets/balance_progress.dart';

class CategoriesDetailsScreen extends StatelessWidget {
  final String categoryName;
  final int categoryId;
  final List<Map<String, dynamic>> transactions;

  const CategoriesDetailsScreen({
    Key? key,
    required this.categoryName,
    required this.categoryId,
    required this.transactions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate summary values (mocked for now)
    final double totalBalance = 7783.00;
    final double totalExpense = 1187.40;
    final double progress = 0.3;
    final double goal = 20000.00;

    // Group transactions by month
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var txn in transactions) {
      final date = txn['date'] as DateTime;
      final month = _monthYear(date);
      grouped.putIfAbsent(month, () => []).add(txn);
    }
    final months = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return Scaffold(
      backgroundColor: const Color(0xFF1abc9c),
      body: Stack(
        children: [
          // Teal gradient header background
          Container(
            height: 300,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1abc9c), Color(0xFF16a085)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Rounded white panel
          Positioned(
            top: 260,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFeafaf1),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      Text(
                        categoryName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(
                          Icons.notifications_outlined,
                          color: Colors.black87,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ),
                // Summary
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: BalanceExpenseProgressCheck(
                    balances: {
                      'totalBalance': totalBalance,
                      'totalExpense': totalExpense,
                      'progress': progress,
                      'goal': goal,
                    },
                  ),
                ),
                const SizedBox(height: 16),
                // Transactions List
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(top: 24, left: 0, right: 0),
                    children: [
                      for (final month in months) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 8,
                          ),
                          child: Text(
                            month,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        for (final txn in grouped[month]!)
                          _TransactionTile(txn: txn),
                      ],
                    ],
                  ),
                ),
                // Add Expenses Button centered, no background container
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1abc9c),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => AddTransactionScreen(
                              initialType: 'expense',
                              initialCategoryId: categoryId,
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        'Add Expenses',
                        style: TextStyle(fontSize: 14, color: Colors.white),
                      ),
                    ),
                  ),
                ),
                // Bottom Navigation (mocked)
                Padding(
                  padding: const EdgeInsets.only(bottom: 22),
                  child: _MockBottomNav(selectedIndex: 3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _monthYear(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]}';
  }
}

class _TransactionTile extends StatelessWidget {
  final Map<String, dynamic> txn;
  const _TransactionTile({required this.txn});

  @override
  Widget build(BuildContext context) {
    final date = txn['date'] as DateTime;
    final time =
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    final day = date.day;
    final month = date.month;
    final title = txn['title'] as String;
    final amount = txn['amount'] as double;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF7ed6df),
              borderRadius: BorderRadius.circular(18),
            ),
            padding: const EdgeInsets.all(16),
            child: const Icon(
              Icons.restaurant_menu,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$time - $day/${month.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ],
            ),
          ),
          Text(
            '- 24${amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF7c3aed),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _MockBottomNav extends StatelessWidget {
  final int selectedIndex;
  const _MockBottomNav({required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return SizedBox.shrink();
  }

  // Navigation icons removed
}
