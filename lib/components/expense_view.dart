import 'package:flutter/material.dart';
import 'package:project_mobile/models/transaction.dart';
import 'package:project_mobile/components/expense_chart.dart';
import 'package:project_mobile/components/expense_legend.dart';
import 'package:project_mobile/components/transaction_chart_list.dart';

class ExpenseViewComponent extends StatelessWidget {
  final List<Transaction> transactions;

  const ExpenseViewComponent({
    super.key,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Chart Section
          ExpenseChart(transactions: transactions),
          
          // Legend
          ExpenseLegend(transactions: transactions),
          
          // Transactions List
          TransactionsListChart(
            transactions: transactions,
            isIncome: false,
            title: 'Recent Expenses',
          ),
        ],
      ),
    );
  }
}