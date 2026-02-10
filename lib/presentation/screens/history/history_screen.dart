import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:x_manager/core/providers.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txAsync = ref.watch(transactionsProvider);
    final searchController = TextEditingController(
      text: ref.read(transactionSearchQueryProvider),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showSortDialog(context, ref);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search by note or type',
              ),
              onChanged: (v) {
                ref.read(transactionSearchQueryProvider.notifier).state = v;
                final _ = ref.refresh(transactionsProvider);
              },
            ),
          ),
          Expanded(
            child: txAsync.when(
              data: (txs) {
                if (txs.isEmpty)
                  return const Center(child: Text('No transactions'));
                return ListView.separated(
                  itemCount: txs.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final t = txs[index];
                    return ListTile(
                      title: Text('${t.type} • ${t.amount.toStringAsFixed(2)}'),
                      subtitle: Text(
                        '${t.note ?? ''} • ${DateFormat.yMMMd().format(t.date)}',
                      ),
                      trailing: Text(t.paymentMode),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  void _showSortDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) {
        final sort = ref.read(transactionSortByProvider);
        return AlertDialog(
          title: const Text('Sort by'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                value: 'dateDesc',
                groupValue: sort,
                title: const Text('Date (newest)'),
                onChanged: (v) {
                  ref.read(transactionSortByProvider.notifier).state = v!;
                  final _ = ref.refresh(transactionsProvider);
                  Navigator.of(context).pop();
                },
              ),
              RadioListTile<String>(
                value: 'dateAsc',
                groupValue: sort,
                title: const Text('Date (oldest)'),
                onChanged: (v) {
                  ref.read(transactionSortByProvider.notifier).state = v!;
                  final _ = ref.refresh(transactionsProvider);
                  Navigator.of(context).pop();
                },
              ),
              RadioListTile<String>(
                value: 'amountDesc',
                groupValue: sort,
                title: const Text('Amount (high -> low)'),
                onChanged: (v) {
                  ref.read(transactionSortByProvider.notifier).state = v!;
                  final _ = ref.refresh(transactionsProvider);
                  Navigator.of(context).pop();
                },
              ),
              RadioListTile<String>(
                value: 'amountAsc',
                groupValue: sort,
                title: const Text('Amount (low -> high)'),
                onChanged: (v) {
                  ref.read(transactionSortByProvider.notifier).state = v!;
                  final _ = ref.refresh(transactionsProvider);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
