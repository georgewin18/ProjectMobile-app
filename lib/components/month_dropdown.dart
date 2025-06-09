import 'package:flutter/material.dart';

class MonthDropdown extends StatelessWidget {
  final String selectedMonth;
  final List<String> months;
  final ValueChanged<String> onMonthChanged;

  const MonthDropdown({
    Key? key,
    required this.selectedMonth,
    required this.months,
    required this.onMonthChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFFF1F1FA),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(40),
        color: Colors.transparent,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedMonth,
          icon: const Padding(
            padding: EdgeInsets.only(left: 8),
            child: Icon(
              Icons.keyboard_arrow_down,
              color: Color(0xFF7F3DFF),
              size: 16,
            ),
          ),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF2D3748),
          ),
          dropdownColor: Colors.white,
          isDense: true,
          items: months.map((String month) {
            return DropdownMenuItem<String>(
              value: month,
              child: Text(
                month,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2D3748),
                ),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              onMonthChanged(newValue);
            }
          },
        ),
      ),
    );
  }
}