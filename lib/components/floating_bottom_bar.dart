import 'package:flutter/material.dart';

class FloatingBottomBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const FloatingBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      color: Colors.white,
      child: SizedBox(
        height: 70,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(5, (index) {
            if (index == 2) {
              return const SizedBox(width: 40); // space for FAB
            }

            IconData icon;
            switch (index) {
              case 0:
                icon = Icons.home;
                break;
              case 1:
                icon = Icons.bar_chart;
                break;
              case 3:
                icon = Icons.pie_chart;
                break;
              case 4:
              default:
                icon = Icons.person;
            }

            final isSelected = currentIndex == index;

            return IconButton(
              icon: Icon(
                icon,
                color: isSelected ? Colors.blue : Colors.grey,
              ),
              onPressed: () => onTap(index),
            );
          }),
        ),
      ),
    );
  }
}