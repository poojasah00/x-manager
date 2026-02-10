import 'package:flutter_test/flutter_test.dart';
import 'package:x_manager/data/local/app_database.dart';
import 'package:x_manager/data/repositories/loan_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Loan management', () {
    late AppDatabase db;
    late LoanRepository repo;

    setUp(() async {
      db = AppDatabase.inMemory();
      repo = LoanRepository(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('Create loan and record payments', () async {
      final id = await repo.addLoan(
        person: 'Alice',
        amount: 500.0,
        dueDate: DateTime.now().add(const Duration(days: 30)),
      );
      final loans = await repo.getAllLoans();
      final loan = loans.firstWhere((l) => l.id == id);
      expect(loan.remaining, 500.0);
      expect(loan.status, 'Unpaid');

      // record partial payment
      await repo.recordPayment(loanId: loan.id, amount: 200.0);
      final loanAfter = (await repo.getAllLoans()).firstWhere(
        (l) => l.id == loan.id,
      );
      expect(loanAfter.remaining, 300.0);
      expect(loanAfter.status, 'Unpaid');

      // record final payment
      await repo.recordPayment(loanId: loan.id, amount: 300.0);
      final loanFinal = (await repo.getAllLoans()).firstWhere(
        (l) => l.id == loan.id,
      );
      expect(loanFinal.remaining, 0.0);
      expect(loanFinal.status, 'Paid');
    });
  });
}
