import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_mobile/components/transaction_state.dart';
import 'package:project_mobile/models/transaction.dart';
import 'transaction_item.dart';

class TransactionsList extends StatelessWidget {
  final bool isLoading;
  final String? errorMessage;
  final List<Transaction> currentTransactions;
  final String selectedMonth;
  final Set<int> incomeCategories;
  final Future<void> Function() onRefresh;

  const TransactionsList({
    Key? key,
    required this.isLoading,
    required this.errorMessage,
    required this.currentTransactions,
    required this.selectedMonth,
    required this.incomeCategories,
    required this.onRefresh,
  }) : super(key: key);

  Map<String, List<Transaction>> get groupedTransactions {
    final Map<String, List<Transaction>> grouped = {};
    
    for (Transaction transaction in currentTransactions) {
      final dateKey = _getDateKey(transaction.transactionDate);
      if (grouped[dateKey] == null) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(transaction);
    }
    
    // Sort by date (newest first)
    grouped.forEach((key, value) {
      value.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
    });
    
    return grouped;
  }

  String _getDateKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final transactionDate = DateTime(date.year, date.month, date.day);
    
    if (transactionDate.isAtSameMomentAs(today)) {
      return 'Today';
    } else if (transactionDate.isAtSameMomentAs(yesterday)) {
      return 'Yesterday';
    } else {
      return DateFormat('MMMM dd, yyyy').format(date);
    }
  }

  List<Widget> _buildTransactionSections() {
    List<Widget> sections = [];
    
    groupedTransactions.forEach((dateKey, transactions) {
      sections.add(
        Padding(
          padding: const EdgeInsets.only(top: 24, bottom: 12),
          child: Text(
            dateKey,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
          ),
        ),
      );
      
      for (Transaction transaction in transactions) {
        sections.add(
          TransactionItem(
            transaction: transaction,
            incomeCategories: incomeCategories,
          ),
        );
      }
    });
    
    return sections;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const LoadingWidget();
    }

    if (errorMessage != null) {
      return TransactionErrorWidget(
        errorMessage: errorMessage!,
        onRetry: onRefresh,
      );
    }

    if (currentTransactions.isEmpty) {
      return EmptyStateWidget(
        selectedMonth: selectedMonth,
        onRefresh: onRefresh,
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: const Color(0xFF7F3DFF),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: _buildTransactionSections(),
      ),
    );
  }
}