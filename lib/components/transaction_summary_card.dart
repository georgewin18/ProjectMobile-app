import 'package:flutter/material.dart';

class TransactionSummaryCard extends StatelessWidget {
  final String label;
  final String amount;
  final EdgeInsetsGeometry? margin;

  const TransactionSummaryCard({
    super.key,
    required this.label,
    required this.amount,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    IconData icon;

    switch (label.toLowerCase()) {
      case 'income':
        bgColor = Colors.green[800]!;
        icon = Icons.download_rounded;
        break;
      case 'expenses':
        bgColor = Colors.red;
        icon = Icons.upload_rounded;
        break;
      default:
        bgColor = Colors.grey;
        icon = Icons.help_outline;
    }

    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12),
        margin: margin ?? EdgeInsets.zero,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(24)
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: bgColor,
                size: 24,
              ),
            ),

            SizedBox(width: 4),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white
                  ),
                ),
                Text(
                  amount,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}