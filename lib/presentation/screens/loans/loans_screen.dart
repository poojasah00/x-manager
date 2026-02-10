import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:x_manager/core/providers.dart';
import 'package:x_manager/data/local/app_database.dart';

class LoansScreen extends ConsumerWidget {
  const LoansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loansAsync = ref.watch(loansProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Loans')),
      body: loansAsync.when(
        data: (loans) {
          if (loans.isEmpty) return const Center(child: Text('No loans'));
          return ListView.separated(
            itemCount: loans.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final l = loans[index];
              return ListTile(
                title: Text(
                  '${l.person} • ${NumberFormat.simpleCurrency().format(l.amount)}',
                ),
                subtitle: Text(
                  'Due: ${DateFormat.yMMMd().format(l.dueDate)} • Remaining: ${l.remaining.toStringAsFixed(2)}',
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (v) async {
                    if (v == 'pay') {
                      final amt = await _showPaymentDialog(context);
                      if (amt != null && amt > 0) {
                        await ref
                            .read(loanRepositoryProvider)
                            .recordPayment(loanId: l.id, amount: amt);
                        final _ = ref.refresh(loansProvider);
                      }
                    } else if (v == 'markpaid') {
                      await ref.read(loanRepositoryProvider).markPaid(l.id);
                      final _ = ref.refresh(loansProvider);
                    } else if (v == 'delete') {
                      await ref.read(databaseProvider).deleteLoan(l.id);
                      final _ = ref.refresh(loansProvider);
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'pay',
                      child: Text('Record Payment'),
                    ),
                    const PopupMenuItem(
                      value: 'markpaid',
                      child: Text('Mark Paid'),
                    ),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final res = await showDialog<LoansCompanion>(
            context: context,
            builder: (_) => const _AddLoanDialog(),
          );
          if (res != null) {
            await ref.read(databaseProvider).insertLoan(res);
            final _ = ref.refresh(loansProvider);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<double?> _showPaymentDialog(BuildContext context) async {
    final controller = TextEditingController();
    final res = await showDialog<double?>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Record Payment'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Amount'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(double.tryParse(controller.text)),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    return res;
  }
}

class _AddLoanDialog extends StatefulWidget {
  const _AddLoanDialog();

  @override
  State<_AddLoanDialog> createState() => _AddLoanDialogState();
}

class _AddLoanDialogState extends State<_AddLoanDialog> {
  final _name = TextEditingController();
  final _amount = TextEditingController();
  DateTime _due = DateTime.now().add(const Duration(days: 30));

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Loan'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Person'),
          ),
          TextField(
            controller: _amount,
            decoration: const InputDecoration(labelText: 'Amount'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Due Date'),
            subtitle: Text(DateFormat.yMMMd().format(_due)),
            trailing: IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: _due,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                );
                if (d != null) setState(() => _due = d);
              },
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final name = _name.text.trim();
            final amount = double.tryParse(_amount.text) ?? 0.0;
            if (name.isEmpty || amount <= 0) return;
            final companion = LoansCompanion.insert(
              person: name,
              amount: amount,
              dueDate: _due,
              status: 'Unpaid',
              remaining: amount,
            );
            Navigator.of(context).pop(companion);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
