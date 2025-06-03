import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_mobile/models/transaction.dart';

enum FilterRange { today, week, month, year }

class HistoryTransaction extends StatefulWidget {
  final List<Transaction> transactions;

  const HistoryTransaction({
    super.key,
    required this.transactions,
  });

  @override
  State<HistoryTransaction> createState() => _HistoryTransactionState();
}

class _HistoryTransactionState extends State<HistoryTransaction> {
  FilterRange selectedRange = FilterRange.today;

  List<Transaction> filterTransactions(List<Transaction> transactions, FilterRange range) {
    final now = DateTime.now();

    DateTime startOfDay(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
    DateTime endOfDay(DateTime dt) => DateTime(dt.year, dt.month, dt.day, 23, 59, 59, 999);

    return transactions.where((tx) {
      final date = tx.transactionDate;

      switch (range) {
        case FilterRange.today:
          final start = startOfDay(now);
          final end = endOfDay(now);
          return date.isAfter(start.subtract(Duration(milliseconds: 1))) &&
              date.isBefore(end.add(Duration(milliseconds: 1)));

        case FilterRange.week:
          final startOfWeek = startOfDay(now.subtract(Duration(days: now.weekday - 1)));
          final endOfWeek = endOfDay(startOfWeek.add(const Duration(days: 6)));
          return date.isAfter(startOfWeek.subtract(const Duration(milliseconds: 1))) &&
              date.isBefore(endOfWeek.add(const Duration(milliseconds: 1)));

        case FilterRange.month:
          final start = DateTime.utc(now.year, now.month, 1);
          final end = endOfDay(DateTime.utc(now.year, now.month + 1, 0));
          return date.isAfter(start.subtract(const Duration(milliseconds: 1))) &&
              date.isBefore(end.add(const Duration(milliseconds: 1)));

        case FilterRange.year:
          final start = DateTime.utc(now.year, 1, 1);
          final end = endOfDay(DateTime.utc(now.year, 12, 31));
          return date.isAfter(start.subtract(const Duration(milliseconds: 1))) &&
              date.isBefore(end.add(const Duration(milliseconds: 1)));
      }
    }).toList();
  }

  Widget buildRangeTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: FilterRange.values.map((range) {
          final label = range.name[0].toUpperCase() + range.name.substring(1);
          final isSelected = selectedRange == range;
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedRange = range;
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              margin: EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.amber : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.black : Colors.grey,
                ),
              ),
            ),
          );
        }).toList(),
      )
    );
  }

  Widget buildTransactionItem(Transaction tx) {
    final categoryData = {
      1: {'label': 'Transportation', 'icon': Icons.emoji_transportation, 'color': Colors.green},
      2: {'label': 'Shopping', 'icon': Icons.shopping_bag, 'color': Colors.orange},
      3: {'label': 'Subscription', 'icon': Icons.subscriptions, 'color': Colors.purple},
      4: {'label': 'Insurance', 'icon': Icons.shield, 'color': Colors.blue},
      5: {'label': 'Groceries', 'icon': Icons.local_grocery_store, 'color': Colors.red},
      6: {'label': 'Others', 'icon': Icons.category, 'color': Colors.pink},
      7: {'label': 'Salary', 'icon': Icons.money, 'color': Colors.green},
      8: {'label': 'Bonus', 'icon': Icons.monetization_on_rounded, 'color': Colors.yellowAccent},
      9: {'label': 'Commission', 'icon': Icons.trending_up, 'color': Colors.teal},
      10: {'label': 'Others', 'icon': Icons.category, 'color': Colors.pink}
    };

    final category = categoryData[tx.categoryId] ?? {
      'label': 'Others',
      'icon': Icons.help_outline,
      'color': Colors.grey,
    };

    final formattedAmount = NumberFormat.decimalPattern().format(tx.amount);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              category['icon'] as IconData,
              color: category['color'] as Color,
              size: 40,
            ),
          ),

          SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category['label'] as String,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  tx.description,
                  style: TextStyle(color: Colors.grey[600]),
                )
              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${tx.categoryId > 6 ? '+' : '-'} Rp $formattedAmount",
                style: TextStyle(
                  color: tx.categoryId > 6 ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                DateFormat.Hm().format(tx.transactionDate),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12
                ),
              )
            ]
          )
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = filterTransactions(widget.transactions, selectedRange);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Text(
            'Recent Transaction',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18
            ),
          ),
        ),
        buildRangeTabs(),

        const SizedBox(height: 8),

        SizedBox(
          height: MediaQuery.of(context).size.height * 0.4,
          child: ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              return buildTransactionItem(filtered[index]);
            },
          )
        ),
      ],
    );
  }
}