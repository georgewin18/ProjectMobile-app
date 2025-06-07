import 'package:flutter/material.dart';
import 'package:project_mobile/models/transaction.dart';

class AnalyticPage extends StatefulWidget {
  @override
  _AnalyticPageState createState() => _AnalyticPageState();
}

class Category {
  final int id;
  final String name;
  final IconData icon;
  final Color color;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });
}

class _AnalyticPageState extends State<AnalyticPage> {
  bool _showFilterDialog = false;
  String _selectedFilter = 'Expense';
  String _selectedSort = 'Lowest';
  int? _selectedCategoryId;

  // Data dummy untuk kategori
  final List<Category> _categories = [
    Category(id: 1, name: 'Shopping', icon: Icons.shopping_bag, color: Colors.orange),
    Category(id: 2, name: 'Subscription', icon: Icons.subscriptions, color: Colors.purple),
    Category(id: 3, name: 'Food', icon: Icons.restaurant, color: Colors.red),
    Category(id: 4, name: 'Salary', icon: Icons.account_balance_wallet, color: Colors.green),
    Category(id: 5, name: 'Transportation', icon: Icons.directions_car, color: Colors.blue),
  ];

  // Data dummy untuk transaksi (diurutkan dari terbaru)
  final List<Transaction> _transactions = [
    // Today
    Transaction(
      description: 'Buy some grocery',
      amount: -120000,
      categoryId: 1,
      transactionDate: DateTime.now(),
    ),
    Transaction(
      description: 'Disney+ Annual..',
      amount: -80000,
      categoryId: 2,
      transactionDate: DateTime.now().subtract(Duration(hours: 2)),
    ),
    Transaction(
      description: 'Buy a ramen',
      amount: -32000,
      categoryId: 3,
      transactionDate: DateTime.now().subtract(Duration(hours: 4)),
    ),
    // Yesterday
    Transaction(
      description: 'Salary for July',
      amount: 5000000,
      categoryId: 4,
      transactionDate: DateTime.now().subtract(Duration(days: 1, hours: 2)),
    ),
    Transaction(
      description: 'Charging Tesla',
      amount: -18000,
      categoryId: 5,
      transactionDate: DateTime.now().subtract(Duration(days: 1, hours: 5)),
    ),
    // 2 days ago
    Transaction(
      description: 'Coffee Shop',
      amount: -45000,
      categoryId: 3,
      transactionDate: DateTime.now().subtract(Duration(days: 2, hours: 3)),
    ),
    Transaction(
      description: 'Grab Transportation',
      amount: -25000,
      categoryId: 5,
      transactionDate: DateTime.now().subtract(Duration(days: 2, hours: 7)),
    ),
    // 3 days ago
    Transaction(
      description: 'Netflix Subscription',
      amount: -120000,
      categoryId: 2,
      transactionDate: DateTime.now().subtract(Duration(days: 3, hours: 1)),
    ),
    // 5 days ago
    Transaction(
      description: 'Freelance Project',
      amount: 2500000,
      categoryId: 4,
      transactionDate: DateTime.now().subtract(Duration(days: 5, hours: 4)),
    ),
    Transaction(
      description: 'Buy vegetables',
      amount: -75000,
      categoryId: 1,
      transactionDate: DateTime.now().subtract(Duration(days: 5, hours: 8)),
    ),
  ];

  Category? _getCategoryById(int id) {
    try {
      return _categories.firstWhere((cat) => cat.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Transaction> get _filteredTransactions {
    List<Transaction> filtered = _transactions;

    // Filter by type
    if (_selectedFilter == 'Income') {
      filtered = filtered.where((t) => t.amount > 0).toList();
    } else if (_selectedFilter == 'Expense') {
      filtered = filtered.where((t) => t.amount < 0).toList();
    }

    // Filter by category
    if (_selectedCategoryId != null) {
      filtered = filtered.where((t) => t.categoryId == _selectedCategoryId).toList();
    }

    // Sort
    if (_selectedSort == 'Highest') {
      filtered.sort((a, b) => b.amount.abs().compareTo(a.amount.abs()));
    } else if (_selectedSort == 'Lowest') {
      filtered.sort((a, b) => a.amount.abs().compareTo(b.amount.abs()));
    } else if (_selectedSort == 'Newest') {
      filtered.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
    } else if (_selectedSort == 'Oldest') {
      filtered.sort((a, b) => a.transactionDate.compareTo(b.transactionDate));
    }

    return filtered;
  }

  String _formatCurrency(double amount) {
    // Format to Indonesian Rupiah
    String formatted = amount.toStringAsFixed(0);
    String result = '';
    int counter = 0;
    
    for (int i = formatted.length - 1; i >= 0; i--) {
      if (counter == 3) {
        result = '.' + result;
        counter = 0;
      }
      result = formatted[i] + result;
      counter++;
    }
    
    return 'Rp $result';
  }

  Map<String, List<Transaction>> get _groupedTransactions {
    Map<String, List<Transaction>> grouped = {};
    
    // Sort transactions by date (newest first)
    List<Transaction> sortedTransactions = List.from(_filteredTransactions);
    sortedTransactions.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
    
    for (var transaction in sortedTransactions) {
      String dateKey = _getDateKey(transaction.transactionDate);
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(transaction);
    }

    // Convert to list, sort by date (Today first), then convert back to map
    var entries = grouped.entries.toList();
    entries.sort((a, b) {
      if (a.key == 'Today') return -1;
      if (b.key == 'Today') return 1;
      if (a.key == 'Yesterday') return -1;
      if (b.key == 'Yesterday') return 1;
      
      // For date strings, parse and compare
      try {
        var dateA = _parseDateKey(a.key);
        var dateB = _parseDateKey(b.key);
        return dateB.compareTo(dateA);
      } catch (e) {
        return 0;
      }
    });
    
    return Map.fromEntries(entries);
  }

  DateTime _parseDateKey(String dateKey) {
    var parts = dateKey.split('/');
    return DateTime(
      int.parse(parts[2]), // year
      int.parse(parts[1]), // month
      int.parse(parts[0]), // day
    );
  }

  String _getDateKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));
    final transactionDate = DateTime(date.year, date.month, date.day);

    if (transactionDate == today) {
      return 'Today';
    } else if (transactionDate == yesterday) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildHeader(),
                _buildFinancialReport(),
                Expanded(
                  child: _buildTransactionList(),
                ),
              ],
            ),
            if (_showFilterDialog) _buildFilterDialog(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.keyboard_arrow_down, size: 24),
              SizedBox(width: 4),
              Text(
                'Month',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              setState(() {
                _showFilterDialog = true;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialReport() {
    return GestureDetector(
      onTap: () {
        // Navigate to financial report
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Color(0xFFE8E5FF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'See your financial report',
              style: TextStyle(
                color: Color(0xFF7C3AED),
                fontSize: 16,
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFF7C3AED),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionList() {
    final groupedTransactions = _groupedTransactions;
    
    return ListView.builder(
      padding: EdgeInsets.only(bottom: 80),
      itemCount: groupedTransactions.length,
      itemBuilder: (context, index) {
        String dateKey = groupedTransactions.keys.elementAt(index);
        List<Transaction> transactions = groupedTransactions[dateKey]!;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                dateKey,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...transactions.map((transaction) => _buildTransactionItem(transaction)),
          ],
        );
      },
    );
  }

  Widget _buildTransactionItem(Transaction transaction) {
    final category = _getCategoryById(transaction.categoryId);
    final isExpense = transaction.amount < 0;
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: category?.color.withOpacity(0.2) ?? Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              category?.icon ?? Icons.category,
              color: category?.color ?? Colors.grey,
              size: 24,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category?.name ?? 'Unknown',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  transaction.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isExpense ? '-' : '+'} ${_formatCurrency(transaction.amount.abs())}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isExpense ? Colors.red : Colors.green,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '${transaction.transactionDate.hour.toString().padLeft(2, '0')}:${transaction.transactionDate.minute.toString().padLeft(2, '0')} ${transaction.transactionDate.hour < 12 ? 'AM' : 'PM'}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDialog() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showFilterDialog = false;
        });
      },
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            onTap: () {}, // Prevent dialog from closing when tapped
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filter Transaction',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedFilter = 'Expense';
                            _selectedSort = 'Lowest';
                            _selectedCategoryId = null;
                          });
                        },
                        child: Text(
                          'Reset',
                          style: TextStyle(color: Colors.purple),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Filter By',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      _buildFilterChip('Income', _selectedFilter == 'Income'),
                      SizedBox(width: 8),
                      _buildFilterChip('Expense', _selectedFilter == 'Expense'),
                      SizedBox(width: 8),
                      _buildFilterChip('Transfer', _selectedFilter == 'Transfer'),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Sort By',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildSortChip('Highest', _selectedSort == 'Highest'),
                      _buildSortChip('Lowest', _selectedSort == 'Lowest'),
                      _buildSortChip('Newest', _selectedSort == 'Newest'),
                      _buildSortChip('Oldest', _selectedSort == 'Oldest'),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Category',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedCategoryId != null
                                    ? _getCategoryById(_selectedCategoryId!)?.name ?? 'Choose Category'
                                    : 'Choose Category',
                                style: TextStyle(
                                  color: _selectedCategoryId != null ? Colors.black : Colors.grey,
                                ),
                              ),
                              Row(
                                children: [
                                  if (_selectedCategoryId != null)
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.purple[50],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '1 Selected',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.purple,
                                        ),
                                      ),
                                    ),
                                  SizedBox(width: 4),
                                  Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _showFilterDialog = false;
                        });
                      },
                      child: Text('Apply'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).padding.bottom),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.purple[50] : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.purple : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.purple : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildSortChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSort = label;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.purple[50] : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.purple : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.purple : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}