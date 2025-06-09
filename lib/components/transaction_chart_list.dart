import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_mobile/models/transaction.dart';

class TransactionsListChart extends StatelessWidget {
  final List<Transaction> transactions;
  final bool isIncome;
  final String title;
  final int maxItems;

  const TransactionsListChart({
    super.key,
    required this.transactions,
    required this.isIncome,
    required this.title,
    this.maxItems = 10,
  });

  List<Transaction> get _filteredTransactions {
    return transactions
        .where((tx) => isIncome ? tx.categoryId > 6 : tx.categoryId <= 6)
        .toList()
      ..sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
  }

  @override
  Widget build(BuildContext context) {
    final filteredTransactions = _filteredTransactions;

    if (filteredTransactions.isEmpty) {
      return Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'No ${isIncome ? 'income' : 'expense'} transactions found',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ),
          ...filteredTransactions.take(maxItems).map((tx) => _buildTransactionItem(tx)),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Transaction transaction) {
    final categoryNames = {
      1: 'Transportation',
      2: 'Shopping',
      3: 'Subscription',
      4: 'Insurance',
      5: 'Groceries',
      6: 'Others',
      7: 'Salary',
      8: 'Freelance',
      9: 'Investment',
      10: 'Other Income',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isIncome ? Colors.green[50] : Colors.red[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isIncome ? Icons.trending_up : Icons.trending_down,
              color: isIncome ? Colors.green : Colors.red,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  '${categoryNames[transaction.categoryId] ?? 'Unknown'} • ${DateFormat('MMM dd').format(transaction.transactionDate)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  transaction.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isIncome ? '+' : '-'} Rp ${transaction.amount}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isIncome ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}