import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_mobile/models/budget.dart';
import 'package:project_mobile/services/api_service.dart';

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final NumberFormat _formatter = NumberFormat.decimalPattern();
  String? _selectedCategory;

  List<Budget> _allBudgets = [];
  bool _isLoadingBudgets = true;
  Budget? _triggeredBudget;

  final List<String> _categories = [
    'Transportation',
    'Shopping',
    'Subscription',
    'Insurance',
    'Groceries',
    'Others',
  ];

  @override
  void initState() {
    super.initState();
    _fetchBudgets();
  }

  Future<void> _fetchBudgets() async {
    try {
      final List<dynamic> budgetData = await ApiService.getBudgets();
      if (mounted) {
        setState(() {
          _allBudgets = budgetData.map((json) => Budget.fromJson(json)).toList();
          _isLoadingBudgets = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingBudgets = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load budget data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _checkBudgetAlert(String? selectedCategoryName) {
    setState(() {
      _triggeredBudget = null;
    });

    if (selectedCategoryName == null) return;

    final categoryId = (_categories.indexOf(selectedCategoryName) + 1).toString();
    final now = DateTime.now();

    try {
      final budgetForMonth = _allBudgets.firstWhere(
        (b) =>
          b.categoryId == int.tryParse(categoryId) &&
          b.startDate.month == now.month &&
          b.startDate.year == now.year,
      );

      if (budgetForMonth.alertValue != null && budgetForMonth.totalBudget > 0) {
        double usagePercentage = (budgetForMonth.usedAmount / budgetForMonth.totalBudget) * 100;
        if (usagePercentage >= budgetForMonth.alertValue!) {
          setState(() {
            _triggeredBudget = budgetForMonth;
          });
        }
      }
    } catch (e) {
      debugPrint('No budget found for category ID $categoryId in the current month.');
    }
  }

  Widget _buildBudgetWarning() {
    if (_triggeredBudget == null) {
      return SizedBox.shrink();
    }
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withAlpha(15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange, width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.warning, color: Colors.orange[800], size: 28),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "You've reached ${_triggeredBudget!.alertValue}% usage of budget for this category!",
              style: TextStyle(
                color: Colors.orange[900],
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool amountEdited = false;

    return Scaffold(
      backgroundColor: Colors.red[400],

      appBar: AppBar(
        backgroundColor: Colors.red[400],
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Expense', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),

      body: Column(
        children: [
          SizedBox(height: 32),

          Padding(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'How much?',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _amountController..text = _amountController.text.isEmpty
                  ? '0'
                  : _amountController.text,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.start,
              style: TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold
              ),

              onChanged: (value) {
                final raw = value.replaceAll(',', '');
                if (raw.isEmpty) {
                  _amountController.text = '0';
                } else {
                  final number = int.tryParse(raw);
                  if (number != null) {
                    final newText = _formatter.format(number);
                    _amountController.value = TextEditingValue(
                      text: newText,
                      selection: TextSelection.collapsed(offset: newText.length),
                    );
                  }
                }
              },

              onTap: () {
                if (!amountEdited && _amountController.text == '0') {
                  _amountController.clear();
                  amountEdited = true;
                }
              },
              decoration: InputDecoration(
                border: InputBorder.none,
                prefixText: 'Rp ',
                prefixStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
          ),

          SizedBox(height: 16),

          Expanded(
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  SizedBox(height: 24),

                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Category',
                      filled: true,
                      fillColor: Colors.grey.withAlpha(5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: Colors.grey.withAlpha(40),
                          width: 1
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: Colors.grey.withAlpha(40),
                          width: 1
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: Colors.purple,
                          width: 1.5
                        ),
                      )
                    ),
                    value: _selectedCategory,
                    hint: _isLoadingBudgets ? Text('Loading budgets...') : Text('Select Category'),
                    items: _categories
                      .map((cat) =>
                        DropdownMenuItem(value: cat, child: Text(cat)))
                      .toList(),
                    onChanged: _isLoadingBudgets ? null : (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                      _checkBudgetAlert(value);
                    }
                  ),

                  SizedBox(height: 16),

                  TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      filled: true,
                      fillColor: Colors.grey.withAlpha(5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: Colors.grey.withAlpha(40),
                          width: 1
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: Colors.grey.withAlpha(40),
                          width: 1
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: Colors.purple,
                          width: 1.5
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  _buildBudgetWarning(),

                  Spacer(),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        final rawAmount = _amountController.text.replaceAll(',', '');
                        final amount = double.tryParse(rawAmount) ?? 0;
                        final description = _descriptionController.text;
                        final selectedCategoryIndex = _categories.indexOf(_selectedCategory ?? '');

                        if (amount <= 0 || _selectedCategory == null || description.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Please fill all fields'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        final categoryId = (selectedCategoryIndex + 1).toString();

                        try {
                          await ApiService.createTransaction(
                            description: description,
                            amount: amount,
                            categoryId: categoryId,
                            date: DateTime.now()
                          );

                          Navigator.pop(context, true);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to save transaction!'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          debugPrint('ERROR: $e');
                        }

                        debugPrint('AMOUNT: $amount');
                        debugPrint('CATEGORY_ID: $categoryId');
                        debugPrint('DESCRIPTION: $description');
                      },
                      child: Text(
                        'Save',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}