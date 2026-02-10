import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:x_manager/core/providers.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  final String? initialType;
  const AddTransactionScreen({super.key, this.initialType});

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String _type = 'Income';
  String _paymentMode = 'Cash';
  DateTime _date = DateTime.now();
  int? _selectedWalletId;
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    if (widget.initialType != null) _type = widget.initialType!;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) return;
    if (_selectedWalletId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a wallet')));
      return;
    }

    try {
      final repo = ref.read(transactionRepositoryProvider);
      await repo.addTransaction(
        amount: amount,
        date: _date,
        type: _type,
        paymentMode: _paymentMode,
        walletId: _selectedWalletId!,
        categoryId: _selectedCategoryId,
        note: _noteController.text.isEmpty ? null : _noteController.text,
      );

      ref.invalidate(balancesProvider);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Transaction added')));
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final walletsAsync = ref.watch(walletsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Add Transaction')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Amount'),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Enter amount' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _type,
                items:
                    [
                          'Income',
                          'Expense',
                          'Loan Given',
                          'Loan Taken',
                          'ATM Cash Out',
                        ]
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                onChanged: (v) => setState(() {
                  _type = v!;
                }),
                decoration: const InputDecoration(
                  labelText: 'Transaction Type',
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _paymentMode,
                      items: ['Cash', 'Online']
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _paymentMode = v!),
                      decoration: const InputDecoration(
                        labelText: 'Payment Mode',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: walletsAsync.when(
                      data: (wallets) {
                        return DropdownButtonFormField<int>(
                          value: _selectedWalletId,
                          items: wallets
                              .map(
                                (w) => DropdownMenuItem(
                                  value: w.id,
                                  child: Text(
                                    '${w.name} (${w.balance.toStringAsFixed(2)})',
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _selectedWalletId = v),
                          decoration: const InputDecoration(
                            labelText: 'Wallet',
                          ),
                        );
                      },
                      loading: () => const LinearProgressIndicator(),
                      error: (e, s) => Text('Error: $e'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              categoriesAsync.when(
                data: (cats) {
                  return DropdownButtonFormField<int?>(
                    value: _selectedCategoryId,
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('None'),
                      ),
                      ...cats.map(
                        (c) => DropdownMenuItem<int?>(
                          value: c.id,
                          child: Text(c.name),
                        ),
                      ),
                    ],
                    onChanged: (v) => setState(() => _selectedCategoryId = v),
                    decoration: const InputDecoration(labelText: 'Category'),
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (e, s) => Text('Error: $e'),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Date'),
                subtitle: Text(DateFormat.yMMMd().format(_date)),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: _date,
                      firstDate: DateTime.now().subtract(
                        const Duration(days: 365 * 5),
                      ),
                      lastDate: DateTime.now().add(
                        const Duration(days: 365 * 5),
                      ),
                    );
                    if (d != null) setState(() => _date = d);
                  },
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(labelText: 'Note'),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _submit, child: const Text('Save')),
            ],
          ),
        ),
      ),
    );
  }
}
