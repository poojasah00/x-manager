import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_manager/data/models/transaction_type.dart';

// Previously the types were loaded from a JSON asset; after simplification
// we now return a hardcoded list directly.
final transactionTypesProvider = FutureProvider<List<TransactionType>>((
  ref,
) async {
  return [
    TransactionType(id: 'income', label: 'Income'),
    TransactionType(id: 'expense', label: 'Expense'),
    TransactionType(id: 'lent', label: 'Lent'),
    TransactionType(id: 'borrow', label: 'Borrow'),
    TransactionType(id: 'withdrawal', label: 'Withdrawal'),
    TransactionType(id: 'savings', label: 'Savings'),
  ];
});

final transactionTypeByIdProvider =
    FutureProvider.family<TransactionType?, String>((ref, id) async {
      final types = await ref.watch(transactionTypesProvider.future);
      try {
        return types.firstWhere((t) => t.id == id);
      } catch (e) {
        return null;
      }
    });
