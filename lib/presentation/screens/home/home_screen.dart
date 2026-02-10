import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_manager/core/providers.dart';
import 'package:x_manager/core/analytics_providers.dart';
import '../analytics/analytics_screen.dart';
import '../history/history_screen.dart';
import '../transaction/add_transaction_screen.dart';
import '../settings/wallets_screen.dart';
import '../settings/categories_screen.dart';
import '../loans/loans_screen.dart';

import '../../widgets/balance_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balancesAsync = ref.watch(balancesProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Finance - Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const HistoryScreen()));
            },
          ),
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'wallets') {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const WalletsScreen()),
                );
              } else if (v == 'categories') {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CategoriesScreen()),
                );
              } else if (v == 'loans') {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const LoansScreen()));
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'wallets', child: Text('Wallets')),
              const PopupMenuItem(
                value: 'categories',
                child: Text('Categories'),
              ),
              const PopupMenuItem(value: 'loans', child: Text('Loans')),
            ],
          ),
        ],
      ),
      body: balancesAsync.when(
        data: (balances) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                BalanceCard(
                  bank: balances['bank'] ?? 0.0,
                  cash: balances['cash'] ?? 0.0,
                  total: balances['total'] ?? 0.0,
                ),
                const SizedBox(height: 20),
                // Quick analytics preview
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Quick Analytics',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Consumer(
                          builder: (context, ref, _) {
                            final summary = ref.watch(analyticsSummaryProvider);
                            return summary.when(
                              data: (s) => Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                    children: [
                                      const Text('7d Exp'),
                                      const SizedBox(height: 6),
                                      Text(s.last7Expense.toStringAsFixed(2)),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      const Text('7d Inc'),
                                      const SizedBox(height: 6),
                                      Text(s.last7Income.toStringAsFixed(2)),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      const Text('ATM M'),
                                      const SizedBox(height: 6),
                                      Text(s.atmThisMonth.toStringAsFixed(2)),
                                    ],
                                  ),
                                ],
                              ),
                              loading: () => const LinearProgressIndicator(),
                              error: (e, s) => Text('Error: $e'),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const AnalyticsScreen(),
                            ),
                          ),
                          child: const Text('Open Analytics'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'add_income',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      const AddTransactionScreen(initialType: 'Income'),
                ),
              );
            },
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.small(
            heroTag: 'add_expense',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      const AddTransactionScreen(initialType: 'Expense'),
                ),
              );
            },
            child: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }
}
