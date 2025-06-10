import 'package:flutter/material.dart';
import 'package:project_mobile/models/transaction.dart';
import 'package:project_mobile/components/income_chart.dart';
import 'package:project_mobile/components/transaction_chart_list.dart';

class IncomeViewComponent extends StatelessWidget {
  final List<Transaction> transactions;

  const IncomeViewComponent({
    super.key,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Chart Section
          IncomeChart(transactions: transactions),
          
          // Transactions List
          TransactionsListChart(
            transactions: transactions,
            isIncome: true,
            title: 'Recent Income',
          ),
        ],
      ),
    );
  }
}