import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:project_mobile/models/transaction.dart';

class ExpenseChart extends StatelessWidget {
  final List<Transaction> transactions;

  const ExpenseChart({
    super.key,
    required this.transactions,
  });

  List<PieChartSectionData> _getExpenseCategoryData() {
    final expenseTransactions = transactions.where((tx) => tx.categoryId <= 6).toList();
    
    Map<int, double> categoryExpenses = {};
    for (var tx in expenseTransactions) {
      categoryExpenses[tx.categoryId] = (categoryExpenses[tx.categoryId] ?? 0) + tx.amount;
    }
    
    final categoryColors = [
      const Color(0xFFFF6B6B), 
      const Color(0xFF4ECDC4), 
      const Color(0xFF45B7D1), 
      const Color(0xFF96CEB4), 
      const Color(0xFFFFA07A), 
      const Color(0xFFDDA0DD), 
    ];
    
    double totalExpenses = categoryExpenses.values.fold(0, (sum, amount) => sum + amount);
    
    return categoryExpenses.entries.map((entry) {
      final percentage = totalExpenses > 0 ? (entry.value / totalExpenses) * 100 : 0;
      return PieChartSectionData(
        color: categoryColors[(entry.key - 1)],
        value: entry.value,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  double _getTotalExpenses() {
    final expenseTransactions = transactions.where((tx) => tx.categoryId <= 6).toList();
    return expenseTransactions.fold(0, (sum, tx) => sum + tx.amount);
  }

  @override
  Widget build(BuildContext context) {
    final expenseData = _getExpenseCategoryData();
    final totalExpenses = _getTotalExpenses();

    return Container(
      height: 400,
      padding: const EdgeInsets.all(16),
      child: expenseData.isEmpty
          ? const Center(child: Text('No expense data available'))
          : Column(
              children: [
                // Total Amount
                Text(
                  'Rp ${NumberFormat.decimalPattern().format(totalExpenses)}',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                // Pie Chart
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sections: expenseData,
                      centerSpaceRadius: 60,
                      sectionsSpace: 2,
                      startDegreeOffset: -90,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}