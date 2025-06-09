import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:project_mobile/models/transaction.dart';
import 'package:project_mobile/services/api_service.dart';

class ChartPage extends StatefulWidget {
  const ChartPage({super.key});

  @override
  State<ChartPage> createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Transaction> transactions = [];
  bool isLoading = true;
  
  DateTime selectedDate = DateTime.now();
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchTransactionData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> fetchTransactionData() async {
    try {
      final data = await ApiService.getTransactions();
      final fetched = data.map((json) => Transaction.fromJson(json)).toList();

      setState(() {
        transactions = fetched;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('FETCH ERROR: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  List<Transaction> _getFilteredTransactions(bool isIncome) {
    return transactions.where((tx) {
      final isCorrectType = isIncome ? tx.categoryId > 6 : tx.categoryId <= 6;
      return isCorrectType && 
             tx.transactionDate.year == selectedDate.year &&
             tx.transactionDate.month == selectedDate.month;
    }).toList()..sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
  }

  List<FlSpot> _getDailyIncomeData() {
    final daysInMonth = DateTime(selectedDate.year, selectedDate.month + 1, 0).day;
    
    Map<int, double> dailyIncome = {};
    
    for (int i = 1; i <= daysInMonth; i++) {
      dailyIncome[i] = 0;
    }
    
    final incomeTransactions = _getFilteredTransactions(true);
    
    for (var tx in incomeTransactions) {
      final day = tx.transactionDate.day;
      dailyIncome[day] = (dailyIncome[day] ?? 0) + tx.amount;
    }
    
    return dailyIncome.entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
        .toList();
  }

  List<PieChartSectionData> _getExpenseCategoryData() {
    final expenseTransactions = _getFilteredTransactions(false);
    
    Map<int, double> categoryExpenses = {};
    for (var tx in expenseTransactions) {
      categoryExpenses[tx.categoryId] = (categoryExpenses[tx.categoryId] ?? 0) + tx.amount;
    }
    
    final categoryColors = [
      const Color(0xFFFF6B6B), 
      const Color(0xFF4ECDC4), 
      const Color(0xFF45B7D1), 
      const Color(0xFF96CEB4), 
      const Color(0xFFFFA07A), 
      const Color(0xFFDDA0DD), 
    ];
    
    double totalExpenses = categoryExpenses.values.fold(0, (sum, amount) => sum + amount);
    
    return categoryExpenses.entries.map((entry) {
      final percentage = totalExpenses > 0 ? (entry.value / totalExpenses) * 100 : 0;
      return PieChartSectionData(
        color: categoryColors[(entry.key - 1) % categoryColors.length],
        value: entry.value,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  // Get total amount for selected month
  double _getTotalAmount(bool isIncome) {
    final filteredTransactions = _getFilteredTransactions(isIncome);
    return filteredTransactions.fold(0, (sum, tx) => sum + tx.amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () { Navigator.pop(context); },
        ),
        title: const Text(
          'Financial Report',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Custom Tab Bar
                Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: const Color(0xFF66A3FE),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.black,
                    labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                    tabs: const [
                      Tab(text: 'Expense'),
                      Tab(text: 'Income'),
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildExpenseView(),
                      _buildIncomeView(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildExpenseView() {
    final expenseData = _getExpenseCategoryData();
    final totalExpenses = _getTotalAmount(false);
    final expenseTransactions = _getFilteredTransactions(false);

    return SingleChildScrollView(
      child: Column(
        children: [
          // Chart Section
          Container(
            height: 400,
            padding: const EdgeInsets.all(16),
            child: expenseData.isEmpty
                ? const Center(child: Text('No expense data available'))
                : Column(
                    children: [
                      // Total Amount
                      Text(
                        'Rp $totalExpenses',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Pie Chart
                      Expanded(
                        child: PieChart(
                          PieChartData(
                            sections: expenseData,
                            centerSpaceRadius: 60,
                            sectionsSpace: 2,
                            startDegreeOffset: -90,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
          
          // Legend
          if (expenseData.isNotEmpty) _buildExpenseLegend(expenseData),
          
          // Transactions List
          Container(
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
                    'Recent Expenses',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
                ...expenseTransactions.take(10).map((tx) => _buildTransactionItem(tx, false)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeView() {
    final incomeData = _getDailyIncomeData();
    final totalIncome = _getTotalAmount(true);
    final incomeTransactions = _getFilteredTransactions(true);
    final daysInMonth = DateTime(selectedDate.year, selectedDate.month + 1, 0).day;

    double maxY = 0;
    if (incomeData.isNotEmpty) {
      maxY = incomeData.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
    }
    maxY = maxY > 0 ? maxY * 1.2 : 100000;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Chart Section
          Container(
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
          ),
          
          // Transactions List
          Container(
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
                    'Recent Income',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
                ...incomeTransactions.take(10).map((tx) => _buildTransactionItem(tx, true)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseLegend(List<PieChartSectionData> sections) {
    final categoryNames = {
      1: 'Transportation',
      2: 'Shopping',
      3: 'Subscription',
      4: 'Insurance',
      5: 'Groceries',
      6: 'Others',
    };

    final expenseTransactions = _getFilteredTransactions(false);
    Map<int, double> categoryExpenses = {};
    for (var tx in expenseTransactions) {
      categoryExpenses[tx.categoryId] = (categoryExpenses[tx.categoryId] ?? 0) + tx.amount;
    }

    final sortedCategories = categoryExpenses.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: sortedCategories.map((entry) {
          final categoryId = entry.key;
          final amount = entry.value;
          final sectionIndex = categoryExpenses.keys.toList().indexOf(categoryId);
          
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: sections[sectionIndex].color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    categoryNames[categoryId] ?? 'Unknown',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  '- Rp $amount',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTransactionItem(Transaction transaction, bool isIncome) {
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