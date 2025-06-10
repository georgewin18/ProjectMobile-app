import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:project_mobile/models/transaction.dart';

class IncomeChart extends StatelessWidget {
  final List<Transaction> transactions;

  const IncomeChart({
    super.key,
    required this.transactions,
  });

  List<FlSpot> _getDailyIncomeData() {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    
    Map<int, double> dailyIncome = {};
    
    for (int i = 1; i <= daysInMonth; i++) {
      dailyIncome[i] = 0;
    }
    
    final incomeTransactions = transactions.where((tx) => tx.categoryId > 6).toList();
    
    for (var tx in incomeTransactions) {
      final day = tx.transactionDate.day;
      dailyIncome[day] = (dailyIncome[day] ?? 0) + tx.amount;
    }
    
    return dailyIncome.entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
        .toList();
  }

  double _getTotalIncome() {
    final incomeTransactions = transactions.where((tx) => tx.categoryId > 6).toList();
    return incomeTransactions.fold(0, (sum, tx) => sum + tx.amount);
  }

  @override
  Widget build(BuildContext context) {
    final incomeData = _getDailyIncomeData();
    final totalIncome = _getTotalIncome();
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

    double maxY = 0;
    if (incomeData.isNotEmpty) {
      maxY = incomeData.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
    }
    maxY = maxY > 0 ? maxY * 1.2 : 100000;

    return Container(
      height: 400,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Total Amount
          Text(
            'Rp $totalIncome',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          // Line Chart
          Expanded(
            child: incomeData.isEmpty || incomeData.every((spot) => spot.y == 0)
                ? const Center(child: Text('No income data available'))
                : LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: maxY / 5,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: Colors.grey[300]!,
                            strokeWidth: 1,
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: daysInMonth > 28 ? 5 : 3,
                            getTitlesWidget: (value, meta) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  '${value.toInt()}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      minX: 1,
                      maxX: daysInMonth.toDouble(),
                      minY: 0,
                      maxY: maxY,
                      lineBarsData: [
                        LineChartBarData(
                          spots: incomeData,
                          isCurved: true,
                          color: const Color(0xFF66A3FE),
                          barWidth: 3,
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                const Color(0xFF66A3FE).withOpacity(0.3),
                                const Color(0xFF66A3FE).withOpacity(0.05),
                              ],
                            ),
                          ),
                          dotData: FlDotData(show: false),
                          preventCurveOverShooting: true,
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}