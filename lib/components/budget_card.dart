import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_mobile/models/budget.dart';
import 'package:project_mobile/data/category.dart';

class BudgetCard extends StatelessWidget {
  final Budget budget;

  const BudgetCard({
    super.key,
    required this.budget,
  });

  String _formatString(double amount) {
    final formatted = NumberFormat.decimalPattern().format(amount);
    return formatted;
  }

  @override
  Widget build(BuildContext context) {
    final categoryInfo = categoryData[budget.categoryId] ?? {'label': 'Unknown', 'color': Colors.grey, 'icon': Icons.help};
    final String categoryName = categoryInfo['label'] as String;
    final Color categoryColor = categoryInfo['color'] as Color;

    double remaining = budget.remainingAmount;
    double total = budget.totalBudget;
    bool isExceeded = remaining <= 0;

    double usagePercentage = total > 0 ? (budget.usedAmount / total) * 100 : 0;
    bool isAlertTriggered = false;
    if (budget.alertValue != null && !isExceeded) {
      isAlertTriggered = usagePercentage >= budget.alertValue!;
    }

    double progressValue = total > 0 ? budget.usedAmount / total: 0;
    progressValue = progressValue.clamp(0.0, 1.0);

    Color textColor = isExceeded ? Colors.red : Colors.black;
    Color progressColor;
    IconData? warningIcon;
    String? warningText;

    if (isExceeded) {
      progressColor = Colors.red;
      warningIcon = Icons.error;
      warningText = "You've reach the limit!";
    } else if (isAlertTriggered) {
      progressColor = Colors.orange;
      warningIcon = Icons.warning;
      warningText = "Usage has reached ${budget.alertValue}% limit!";
    } else {
      progressColor = categoryColor;
    }

    if (remaining <= 0) {
      progressValue = 1.0;
    }

    return Card(
      margin: EdgeInsets.only(bottom: 16.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),

      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: categoryColor.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                      categoryName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: categoryColor,
                      )
                  ),
                ),
                Spacer(),
                if (warningIcon != null)
                  Icon(warningIcon, color: progressColor, size: 24),
              ],
            ),
            SizedBox(height: 8),

            Text(
              "Remaining: Rp ${_formatString(remaining)}",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),

            SizedBox(height: 4),

            LinearProgressIndicator(
              value: progressValue,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              minHeight: 10,
              borderRadius: BorderRadius.circular(5),
            ),

            SizedBox(height: 4),

            Text(
              "${_formatString(budget.usedAmount)} of ${_formatString(total)}",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            if (warningText != null)
              Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  warningText,
                  style: TextStyle(
                    fontSize: 12,
                    color: progressColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}