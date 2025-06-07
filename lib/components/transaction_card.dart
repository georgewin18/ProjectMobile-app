import 'package:flutter/material.dart';

class TransactionCard extends StatelessWidget {
  final String description;
  final double amount;
  final int categoryId;
  final DateTime transactionDate;
  final Category? category;

  const TransactionCard({
    super.key,
    required this.description,
    required this.amount,
    required this.categoryId,
    required this.transactionDate,
    this.category,
  });

  @override
  Widget build(BuildContext context) {
    final isExpense = amount < 0;
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _buildIcon(),
          SizedBox(width: 12),
          Expanded(
            child: _buildDetails(),
          ),
          _buildAmount(isExpense),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: category?.color.withOpacity(0.2) ?? Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        category?.icon ?? Icons.category,
        color: category?.color ?? Colors.grey,
        size: 24,
      ),
    );
  }

  Widget _buildDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          category?.name ?? 'Unknown',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4),
        Text(
          description,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildAmount(bool isExpense) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '${isExpense ? '-' : '+'} ${_formatCurrency(amount.abs())}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isExpense ? Colors.red : Colors.green,
          ),
        ),
        SizedBox(height: 4),
        Text(
          _formatTime(),
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  String _formatCurrency(double amount) {
    String formatted = amount.toStringAsFixed(0);
    String result = '';
    int counter = 0;
    
    for (int i = formatted.length - 1; i >= 0; i--) {
      if (counter == 3) {
        result = '.' + result;
        counter = 0;
      }
      result = formatted[i] + result;
      counter++;
    }
    
    return 'Rp $result';
  }

  String _formatTime() {
    final hour = transactionDate.hour;
    final minute = transactionDate.minute.toString().padLeft(2, '0');
    final period = hour < 12 ? 'AM' : 'PM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    
    return '$displayHour:$minute $period';
  }
}

// Category model
class Category {
  final int id;
  final String name;
  final IconData icon;
  final Color color;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });
}