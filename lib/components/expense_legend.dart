import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_mobile/models/transaction.dart';

class ExpenseLegend extends StatelessWidget {
  final List<Transaction> transactions;

  const ExpenseLegend({
    super.key,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    final categoryNames = {
      1: 'Transportation',
      2: 'Shopping',
      3: 'Subscription',
      4: 'Insurance',
      5: 'Groceries',
      6: 'Others',
    };

    final categoryColors = [
      const Color(0xFFFF6B6B), 
      const Color(0xFF4ECDC4), 
      const Color(0xFF45B7D1), 
      const Color(0xFF96CEB4), 
      const Color(0xFFFFA07A), 
      const Color(0xFFDDA0DD), 
    ];

    final expenseTransactions = transactions.where((tx) => tx.categoryId <= 6).toList();
    Map<int, double> categoryExpenses = {};
    
    for (var tx in expenseTransactions) {
      categoryExpenses[tx.categoryId] = (categoryExpenses[tx.categoryId] ?? 0) + tx.amount;
    }

    final sortedCategories = categoryExpenses.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (sortedCategories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: sortedCategories.map((entry) {
          final categoryId = entry.key;
          final amount = entry.value;
          final colorIndex = (categoryId - 1) % categoryColors.length;
          
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: categoryColors[colorIndex],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    categoryNames[categoryId] ?? 'Unknown',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  '- Rp ${NumberFormat.decimalPattern().format(amount)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}