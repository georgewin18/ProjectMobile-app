import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_mobile/components/budget_card.dart';
import 'package:project_mobile/models/budget.dart';
import 'package:project_mobile/pages/create_budget_page.dart';
import 'package:project_mobile/services/api_service.dart';

class BudgetPage extends StatefulWidget {
  const BudgetPage({super.key});

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  List<Budget> _budgetItems = [];
  List<Budget> _filteredBudgetItems = [];
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAndFilterBudget();
  }

  Future<void> _loadAndFilterBudget() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final List<dynamic> budgetData = await ApiService.getBudgets();
      _budgetItems = budgetData.map((json) => Budget.fromJson(json)).toList();

      if (!mounted) return;

      _filterBudgetsForSelectedMonth();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load budgets: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterBudgetsForSelectedMonth() {
    setState(() {
      _filteredBudgetItems = _budgetItems.where((budget)  {
        return budget.startDate.month == _selectedDate.month &&
            budget.startDate.year == _selectedDate.year;
      }).toList();
    });
  }
  
  void _changeMonth(int increment) {
    setState(() {
      _selectedDate = DateTime(
        _selectedDate.year,
        _selectedDate.month + increment,
        1,
      );
      _filterBudgetsForSelectedMonth();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,

      body: Column(
        children: [
          SizedBox(height: 48),

          _appbar(),

          SizedBox(height: 40),

          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),

              child: Column(
                children: [
                  SizedBox(height: 12),

                  Expanded(
                    child: _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : _filteredBudgetItems.isEmpty
                        ? Center(
                          child: Text(
                            'No budgets for this month',
                            style: TextStyle(color: Colors.grey[600]),
                          )
                        )
                        : ListView.builder(
                          itemCount: _filteredBudgetItems.length,
                          itemBuilder: (context, index) {
                            return BudgetCard(budget: _filteredBudgetItems[index]);
                          },
                        )
                  ),

                  Padding(
                    padding: EdgeInsets.all(16),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)
                          )
                      ),
                      child: Text(
                        "Create a Budget",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CreateBudgetPage(selectedDate: _selectedDate)
                          )
                        );

                        if (result != null) {
                          _loadAndFilterBudget();
                        }
                      },
                    )
                  ),

                  SizedBox(height: 32),
                ],
              ),
            ),
          )
        ],
      )
    );
  }

  Widget _appbar() {
    String formattedDate = DateFormat('MMMM yyyy', 'en_US').format(_selectedDate);
    
    return Container(
      height: 84,
      padding: EdgeInsets.symmetric(vertical: 16 , horizontal: 40),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: Icon(Icons.chevron_left, color: Colors.white),
              onPressed: () => _changeMonth(-1),
            ),
          ),

          Center(
            child: Text(
              formattedDate,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24
              ),
            ),
          ),

          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: Icon(Icons.chevron_right, color: Colors.white),
              onPressed: () => _changeMonth(1),
            ),
          ),
        ],
      ),
    );
  }
}