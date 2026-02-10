import 'package:flutter/material.dart';

class BalanceCard extends StatelessWidget {
  final double bank;
  final double cash;
  final double total;

  const BalanceCard({
    super.key,
    required this.bank,
    required this.cash,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildColumn('Bank', bank, Colors.blue),
            _buildColumn('Cash', cash, Colors.orange),
            _buildColumn('Total', total, Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildColumn(String label, double amount, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          amount.toStringAsFixed(2),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
