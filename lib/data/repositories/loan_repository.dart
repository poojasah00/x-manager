import 'package:x_manager/data/local/app_database.dart';
import 'package:drift/drift.dart' show Value;

class LoanRepository {
  final AppDatabase db;
  LoanRepository(this.db);

  Future<int> addLoan({
    required String person,
    required double amount,
    required DateTime dueDate,
  }) {
    return db.insertLoan(
      LoansCompanion.insert(
        person: person,
        amount: amount,
        dueDate: dueDate,
        status: 'Unpaid',
        remaining: amount,
      ),
    );
  }

  Future<void> recordPayment({
    required int loanId,
    required double amount,
  }) async {
    final loan = await db.getLoanById(loanId);
    if (loan == null) throw Exception('Loan not found');
    final newRemaining = (loan.remaining - amount).clamp(0.0, double.infinity);
    final newStatus = newRemaining <= 0 ? 'Paid' : 'Unpaid';
    await db.updateLoan(
      loanId,
      LoansCompanion(
        person: Value(loan.person),
        amount: Value(loan.amount),
        dueDate: Value(loan.dueDate),
        status: Value(newStatus),
        remaining: Value(newRemaining),
      ),
    );
  }

  Future<void> markPaid(int loanId) async {
    final loan = await db.getLoanById(loanId);
    if (loan == null) throw Exception('Loan not found');
    await db.updateLoan(
      loanId,
      LoansCompanion(status: Value('Paid'), remaining: Value(0.0)),
    );
  }

  Future<void> markUnpaid(int loanId, double remaining) async {
    await db.updateLoan(
      loanId,
      LoansCompanion(status: Value('Unpaid'), remaining: Value(remaining)),
    );
  }

  Future<List<Loan>> getAllLoans() => db.getAllLoans();
}
