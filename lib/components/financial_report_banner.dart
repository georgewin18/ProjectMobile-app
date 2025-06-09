import 'package:flutter/material.dart';

class FinancialReportBanner extends StatelessWidget {
  final VoidCallback onTap;

  const FinancialReportBanner({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFEEE5FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              Expanded(
                child: Text(
                  'See your financial report',
                  style: TextStyle(
                    color: Color(0xFF7F3DFF),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFF7F3DFF),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}