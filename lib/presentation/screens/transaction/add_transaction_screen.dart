import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:x_manager/core/providers.dart';
import 'package:x_manager/core/providers/transaction_type_provider.dart';
import 'package:x_manager/data/models/transaction_type.dart';
import 'package:x_manager/data/local/category_database.dart';
import 'package:x_manager/data/repositories/category_repository.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  final String? initialType;
  final int? initialCategoryId;

  const AddTransactionScreen({
    super.key,
    this.initialType,
    this.initialCategoryId,
  });

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String _type = 'income';
  String _paymentMode = 'Cash';
  DateTime _date = DateTime.now();
  int? _selectedWalletId;
  int? _selectedCategoryId;
  late Future<List<DbCategory>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    if (widget.initialType != null) _type = widget.initialType!;
    if (widget.initialCategoryId != null) {
      _selectedCategoryId = widget.initialCategoryId;
    }
    final categoryDb = CategoryDatabase();
    final categoryRepo = CategoryRepository(categoryDb);
    _categoriesFuture = categoryRepo.getAllCategories();
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
        categoryId: _selectedCategoryId,
        paymentMode: _paymentMode,
        walletId: _selectedWalletId!,
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
    final categoriesAsync = ref.watch(categoriesProvider);
    final walletsAsync = ref.watch(walletsProvider);
    final theme = Theme.of(context);
    final bgColor = const Color(0xFFe9fff3);
    final accentColor = const Color(0xFF1ed495);
    final fieldBg = Colors.white.withOpacity(0.7);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(title: const Text('Add Transaction')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Date
              _RoundedField(
                label: 'Date',
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        DateFormat('MMMM d, yyyy').format(_date),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.calendar_today_rounded,
                        color: accentColor,
                      ),
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
                  ],
                ),
              ),
              const SizedBox(height: 18),
              // Transaction Type
              _RoundedField(
                label: 'Transaction Type',
                child: Consumer(
                  builder: (context, ref, child) {
                    final typesAsync = ref.watch(transactionTypesProvider);
                    return typesAsync.when(
                      data: (types) => Column(
                        children: [
                          DropdownButtonFormField<String>(
                            value: _type,
                            items: types
                                .map(
                                  (t) => DropdownMenuItem(
                                    value: t.id,
                                    child: Text(
                                      t.label,
                                      style: theme.textTheme.bodyLarge
                                          ?.copyWith(color: Colors.black87),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: widget.initialType != null
                                ? null
                                : (v) => setState(() {
                                    _type = v!;
                                  }),
                            decoration: const InputDecoration.collapsed(
                              hintText: '',
                            ),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: Colors.black87,
                            ),
                            dropdownColor: fieldBg,
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ],
                      ),
                      loading: () => const LinearProgressIndicator(),
                      error: (e, s) => Text('Error: $e'),
                    );
                  },
                ),
              ),
              const SizedBox(height: 18),
              // Payment Mode & Wallet (side by side)
              Row(
                children: [
                  Expanded(
                    child: _RoundedField(
                      label: 'Payment Mode',
                      horizontalPadding: 4,
                      child: DropdownButtonFormField<String>(
                        value: _paymentMode,
                        isDense: true,
                        items: ['Cash', 'Online']
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(
                                  e,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: Colors.black87,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _paymentMode = v!),
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 0,
                          ),
                          border: InputBorder.none,
                          hintText: '',
                        ),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.black87,
                        ),
                        dropdownColor: fieldBg,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: walletsAsync.when(
                      data: (wallets) => _RoundedField(
                        label: 'Wallet',
                        horizontalPadding: 4,
                        child: DropdownButtonFormField<int>(
                          value: _selectedWalletId,
                          isDense: true,
                          items: wallets
                              .map(
                                (w) => DropdownMenuItem(
                                  value: w.id,
                                  child: Text(
                                    '${w.name} (${w.balance.toStringAsFixed(2)})',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: Colors.black87,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _selectedWalletId = v),
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 0,
                            ),
                            border: InputBorder.none,
                            hintText: '',
                          ),
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.black87,
                          ),
                          dropdownColor: fieldBg,
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      loading: () => const _RoundedField(
                        label: 'Wallet',
                        horizontalPadding: 4,
                        child: LinearProgressIndicator(),
                      ),
                      error: (e, s) => _RoundedField(
                        label: 'Wallet',
                        horizontalPadding: 4,
                        child: Text('Error: $e'),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              // Category
              if (widget.initialCategoryId != null)
                // Show locked category field when pre-selected
                FutureBuilder<List<DbCategory>>(
                  future: _categoriesFuture,
                  builder: (context, snapshot) {
                    String categoryName = 'Loading...';
                    if (snapshot.hasData) {
                      final cats = snapshot.data ?? [];
                      if (cats.isNotEmpty) {
                        final matching = cats.firstWhere(
                          (c) => c.id == widget.initialCategoryId,
                          orElse: () => cats.first,
                        );
                        categoryName = matching.name;
                      }
                    }
                    return _RoundedField(
                      label: 'Category',
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          categoryName,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    );
                  },
                )
              else
                // Show category selector when not pre-selected
                FutureBuilder<List<DbCategory>>(
                  future: _categoriesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const _RoundedField(
                        label: 'Category',
                        child: LinearProgressIndicator(),
                      );
                    }
                    if (snapshot.hasError) {
                      return _RoundedField(
                        label: 'Category',
                        child: Text('Error: ${snapshot.error}'),
                      );
                    }
                    final cats = snapshot.data ?? [];
                    return _RoundedField(
                      label: 'Category',
                      child: DropdownButtonFormField<int?>(
                        value: _selectedCategoryId,
                        items: [
                          const DropdownMenuItem<int?>(
                            value: null,
                            child: Text('Select the category'),
                          ),
                          ...cats.map(
                            (c) => DropdownMenuItem<int?>(
                              value: c.id,
                              child: Text(c.name),
                            ),
                          ),
                        ],
                        onChanged: (v) =>
                            setState(() => _selectedCategoryId = v),
                        decoration:
                            const InputDecoration.collapsed(hintText: ''),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.black87,
                        ),
                        dropdownColor: fieldBg,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 18),
              // Amount
              _RoundedField(
                label: 'Amount',
                child: TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.black87,
                  ),
                  decoration: const InputDecoration.collapsed(hintText: ''),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Enter amount' : null,
                ),
              ),
              const SizedBox(height: 18),
              // Transaction Title
              _RoundedField(
                label: 'Transaction Title',
                child: TextFormField(
                  controller: _noteController,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.black87,
                  ),
                  decoration: const InputDecoration.collapsed(hintText: ''),
                  maxLines: 1,
                ),
              ),
              const SizedBox(height: 18),
              // Note
              _RoundedField(
                label: 'Note',
                child: TextFormField(
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: accentColor,
                  ),
                  decoration: const InputDecoration.collapsed(
                    hintText: 'Enter Note',
                  ),
                  maxLines: 3,
                ),
              ),
              const SizedBox(height: 32),
              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    elevation: 0,
                  ),
                  onPressed: _submit,
                  child: const Text('Save'),
                ),
              ),
              const SizedBox(height: 24),
              // Bottom Navigation (mocked, for UI only)
              _BottomNavBar(accentColor: accentColor),
            ],
          ),
        ),
      ),
    );
  }
}

// Rounded field container widget
class _RoundedField extends StatelessWidget {
  final String label;
  final Widget child;
  final double horizontalPadding;
  const _RoundedField({
    required this.label,
    required this.child,
    this.horizontalPadding = 18,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 12, bottom: 6),
            child: Text(
              label,
              style: TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 12,
          ),
          child: child,
        ),
      ],
    );
  }
}

// Bottom navigation bar (UI only, not functional)
class _BottomNavBar extends StatelessWidget {
  final Color accentColor;
  const _BottomNavBar({required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          Icon(Icons.home_rounded, size: 28, color: Colors.black38),
          Icon(Icons.bar_chart_rounded, size: 28, color: Colors.black38),
          Icon(Icons.compare_arrows_rounded, size: 28, color: Colors.black38),
          Icon(Icons.layers_rounded, size: 32, color: Color(0xFF1ed495)),
          Icon(Icons.person_outline_rounded, size: 28, color: Colors.black38),
        ],
      ),
    );
  }
}
