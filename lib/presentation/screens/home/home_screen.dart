import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_manager/core/providers.dart';
import 'package:x_manager/core/analytics_providers.dart';
import '../analytics/analytics_screen.dart';
import '../history/history_screen.dart';
import '../transaction/add_transaction_screen.dart';
import '../notification/notification_screen.dart';
import '../../widgets/bottom_bar.dart';
import '../../widgets/balance_progress.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String selectedFilter = 'Monthly';
  int selectedNavIndex = 0;
  double scrollOffset = 0;

  @override
  Widget build(BuildContext context) {
    final balancesAsync = ref.watch(balancesProvider);
    final transactionsAsync = ref.watch(transactionsProvider);

    return Scaffold(
      body: balancesAsync.when(
        data: (balances) {
          return Stack(
            children: [
              // Teal gradient header background
              Container(
                height: 300,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFF1abc9c), const Color(0xFF16a085)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              // Rounded background panel that overlaps the header
              Positioned(
                top: 240,
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                ),
              ),
              // Header (non-scrollable)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Hi, Welcome Back',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const Text(
                              'Good Morning',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const NotificationScreen(),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color.fromARGB(60, 180, 57, 57),
                            ),
                            padding: const EdgeInsets.all(10),
                            child: const Icon(
                              Icons.notifications_outlined,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    BalanceExpenseProgressCheck(balances: balances),
                  ],
                ),
              ),
              // Scrollable content positioned to scroll under rounded panel
              Positioned(
                top: 240,
                left: 0,
                right: 0,
                bottom: 0,
                child: NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification scrollInfo) {
                    setState(() {
                      scrollOffset = scrollInfo.metrics.pixels;
                    });
                    return false;
                  },
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        // Goals/Savings card
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF1abc9c),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white12,
                                  ),
                                  padding: const EdgeInsets.all(16),
                                  child: const Icon(
                                    Icons.directions_car_outlined,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Revenue Last Week',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white70,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        '\$4,000.00',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        height: 1,
                                        color: Colors.white24,
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Food Last Week',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white70,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        '-\$100.00',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Time filter buttons
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color.fromARGB(
                                    255,
                                    85,
                                    81,
                                    81,
                                  ).withValues(alpha: 0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 8,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: ['Daily', 'Weekly', 'Monthly']
                                  .map(
                                    (filter) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selectedFilter = filter;
                                          });
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: selectedFilter == filter
                                                ? const Color(0xFF1abc9c)
                                                : Colors.grey[100],
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 10,
                                          ),
                                          child: Text(
                                            filter,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: selectedFilter == filter
                                                  ? Colors.white
                                                  : Colors.grey[700],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Transaction list
                        transactionsAsync.when(
                          data: (transactions) {
                            return Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(32),
                                  topRight: Radius.circular(32),
                                ),
                              ),
                              child: transactions.isEmpty
                                  ? const Center(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 40,
                                        ),
                                        child: Text('No transactions yet'),
                                      ),
                                    )
                                  : ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: transactions.length,
                                      itemBuilder: (context, index) {
                                        final txn = transactions[index];
                                        final icon = _getTransactionIcon(
                                          txn.type,
                                        );
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 12,
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: const Color(
                                                    0xFF5b7cfa,
                                                  ).withValues(alpha: 0.2),
                                                ),
                                                padding: const EdgeInsets.all(
                                                  12,
                                                ),
                                                child: Icon(
                                                  icon,
                                                  color: const Color(
                                                    0xFF5b7cfa,
                                                  ),
                                                  size: 24,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      txn.type,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      '${txn.date.hour}:${txn.date.minute.toString().padLeft(2, '0')} - ${_formatDate(txn.date)}',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey[500],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    txn.type == 'Income'
                                                        ? '+\$${txn.amount.toStringAsFixed(2)}'
                                                        : '-\$${txn.amount.toStringAsFixed(2)}',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14,
                                                      color:
                                                          txn.type == 'Income'
                                                          ? Colors.green
                                                          : const Color(
                                                              0xFF7c3aed,
                                                            ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                            );
                          },
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (e, s) => Center(
                            child: Text('Error loading transactions: $e'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Sticky filter buttons overlay
              if (scrollOffset > 220)
                Positioned(
                  top: 240,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(
                            255,
                            77,
                            76,
                            76,
                          ).withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: ['Daily', 'Weekly', 'Monthly']
                          .map(
                            (filter) => Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedFilter = filter;
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: selectedFilter == filter
                                        ? const Color(0xFF1abc9c)
                                        : Colors.grey[100],
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                  child: Text(
                                    filter,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: selectedFilter == filter
                                          ? Colors.white
                                          : Colors.grey[700],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: selectedNavIndex,
        onItemSelected: (index) {
          setState(() {
            selectedNavIndex = index;
          });
          _handleNavigation(index);
        },
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 0),
        child: FloatingActionButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
          ),
          backgroundColor: const Color(0xFF1abc9c),
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  // _buildNavItem moved to CustomBottomNavBar for reuse

  void _handleNavigation(int index) {
    switch (index) {
      case 1:
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const AnalyticsScreen()));
        break;
      case 4:
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const HistoryScreen()));
        break;
      default:
        break;
    }
  }

  IconData _getTransactionIcon(String type) {
    switch (type) {
      case 'Income':
        return Icons.trending_up;
      case 'Expense':
        return Icons.shopping_bag_outlined;
      case 'ATM Cash Out':
        return Icons.atm_outlined;
      default:
        return Icons.payment;
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} - ${months[date.month - 1]} ${date.day.toString().padLeft(2, '0')}';
  }
}
