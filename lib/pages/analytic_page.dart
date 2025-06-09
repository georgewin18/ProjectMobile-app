import 'package:flutter/material.dart';
import 'package:project_mobile/components/financial_report_banner.dart';
import 'package:project_mobile/components/month_dropdown.dart';
import 'package:project_mobile/components/transaction_list.dart';
import 'package:project_mobile/models/transaction.dart';
import 'package:project_mobile/services/api_service.dart';
import 'package:project_mobile/pages/chart_page.dart';  // ✅ NEW: Import chart_page

class AnalyticPage extends StatefulWidget {
  const AnalyticPage({Key? key}) : super(key: key);

  @override
  State<AnalyticPage> createState() => _AnalyticPageState();
}

class _AnalyticPageState extends State<AnalyticPage> {
  late String selectedMonth;  // ✅ CHANGED: Made late to initialize in initState
  
  final List<String> months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  // Kategori yang dianggap sebagai income (berdasarkan ID)
  final Set<int> incomeCategories = {7, 8, 9, 10}; // Salary, Bonus, Commission, Others

  List<Transaction> allTransactions = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _setCurrentMonth();
    _loadTransactions();
  }

  void _setCurrentMonth() {
    final now = DateTime.now();
    final currentMonthIndex = now.month - 1;
    selectedMonth = months[currentMonthIndex];
  }

  Future<void> _loadTransactions() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final data = await ApiService.getTransactions();
      
      setState(() {
        allTransactions = data.map((json) => Transaction.fromJson(json)).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load transactions: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  List<Transaction> get currentTransactions {
    if (allTransactions.isEmpty) return [];
    
    final monthIndex = months.indexOf(selectedMonth) + 1;
    
    return allTransactions.where((transaction) {
      return transaction.transactionDate.month == monthIndex;
    }).toList();
  }

  Future<void> _refreshTransactions() async {
    await _loadTransactions();
  }

  void _onMonthChanged(String newMonth) {
    setState(() {
      selectedMonth = newMonth;
    });
  }

  void _onFinancialReportTap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ChartPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        title: Row(
          children: [
            MonthDropdown(
              selectedMonth: selectedMonth,
              months: months,
              onMonthChanged: _onMonthChanged,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Financial Report Banner
          FinancialReportBanner(
            onTap: _onFinancialReportTap,
          ),
          
          // Transactions List
          Expanded(
            child: TransactionsList(
              isLoading: isLoading,
              errorMessage: errorMessage,
              currentTransactions: currentTransactions,
              selectedMonth: selectedMonth,
              incomeCategories: incomeCategories,
              onRefresh: _refreshTransactions,
            ),
          ),
        ],
      ),
    );
  }
}