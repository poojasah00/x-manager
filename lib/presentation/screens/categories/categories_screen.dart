import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/balance_progress.dart';
import 'expense/expense_categories_details.dart';
import '../../../data/local/category_database.dart';
import '../../../data/repositories/category_repository.dart';
import '../../../core/providers.dart';
import 'add_category_screen.dart';
import '../transaction/add_transaction_screen.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryDb = CategoryDatabase();
    final categoryRepo = CategoryRepository(categoryDb);
    final txnRepo = ref.read(transactionRepositoryProvider);

    // Example balances data, replace with your actual data structure as needed
    final balances = {
      'balance': 1200.0,
      'expense': 450.0,
      'progress': 0.375, // Example: expense / balance
    };

    return Scaffold(
      backgroundColor: const Color(0xFFeafaf1),
      body: Stack(
        children: [
          // Header background (teal gradient)
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
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.black87,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const Text(
                        'Categories',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
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
                // Balance and expense summary
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: BalanceExpenseProgressCheck(balances: balances),
                ),
                const SizedBox(height: 20),
                // Categories grid
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: FutureBuilder<List<DbCategory>>(
                      future: categoryRepo.getAllCategories(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: \\${snapshot.error}'),
                          );
                        }
                        final categories = snapshot.data ?? [];
                        if (categories.isEmpty) {
                          return const Center(
                            child: Text('No categories found.'),
                          );
                        }
                        return GridView.builder(
                          itemCount: categories.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisSpacing: 18,
                                crossAxisSpacing: 18,
                                childAspectRatio: 1,
                              ),
                          itemBuilder: (context, index) {
                            final cat = categories[index];
                            return GestureDetector(
                              onTap: () {
                                if (cat.transactionType.toLowerCase() ==
                                    'expense') {
                                  // navigate to the category details screen first
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => CategoriesDetailsScreen(
                                        categoryName: cat.name,
                                        categoryId: cat.id,
                                        transactions: [],
                                      ),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Only expense categories can be used for transactions',
                                      ),
                                    ),
                                  );
                                }
                              },
                              onLongPress: () async {
                                // long press shows the category details screen,
                                // passing already-fetched transactions
                                if (cat.transactionType.toLowerCase() ==
                                    'expense') {
                                  final txns = await txnRepo
                                      .getTransactionsByCategory(cat.id);
                                  final mapped = txns
                                      .map(
                                        (t) => {
                                          'date': t.date,
                                          'title': t.note ?? '',
                                          'amount': t.amount,
                                        },
                                      )
                                      .toList();
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => CategoriesDetailsScreen(
                                        categoryName: cat.name,
                                        categoryId: cat.id,
                                        transactions: mapped,
                                      ),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Only expense categories have transactions',
                                      ),
                                    ),
                                  );
                                }
                              },

                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF7ed6df),
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    padding: const EdgeInsets.all(18),
                                    child: cat.svgIcon.isNotEmpty
                                        ? SvgPicture.file(
                                            File(cat.svgIcon),
                                            width: 36,
                                            height: 36,
                                            color: Colors.white,
                                            placeholderBuilder: (context) =>
                                                const CircularProgressIndicator(
                                                  strokeWidth: 1.5,
                                                  color: Colors.white,
                                                ),
                                            fit: BoxFit.contain,
                                          )
                                        : const Icon(
                                            Icons.category,
                                            size: 36,
                                            color: Colors.white,
                                          ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    cat.name,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (ctx) => AddCategoryScreen(database: categoryDb),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Add category',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
    // ...existing code...
  }
}
