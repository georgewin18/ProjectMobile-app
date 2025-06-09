import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:project_mobile/components/floating_bottom_bar.dart';
import 'package:project_mobile/pages/add_expense_page.dart';
import 'package:project_mobile/pages/add_income_page.dart';
import 'package:project_mobile/pages/budget_page.dart';
import 'package:project_mobile/pages/chart_page.dart';
import 'home_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  bool _isFabExpanded = false;

  final List<Widget> _pages = [
    HomePage(key: UniqueKey()),
    AnalyticsPage(), 
    Center(child: Text('')),
    BudgetPage(),
    Center(child: Text('Profile Page')),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onFabPressed() {
    setState(() {
      _isFabExpanded = !_isFabExpanded;
    });
  }

  void _navigateToAddExpense() async {
    setState(() => _isFabExpanded = false);

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddExpensePage())
    );

    if (result == true && (_selectedIndex == 0 || _selectedIndex == 1)) {
      Fluttertoast.showToast(
        msg: "Transaction saved successfully",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      // Refresh both HomePage and AnalyticsPage
      setState(() {
        _pages[0] = HomePage(key: UniqueKey());
        _pages[1] = AnalyticsPage();
      });
    }
  }

  void _navigateToAddIncome() async {
    setState(() => _isFabExpanded = false);

    final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AddIncomePage())
    );

    if (result == true && (_selectedIndex == 0 || _selectedIndex == 1)) {
      Fluttertoast.showToast(
        msg: "Transaction saved successfully",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      // Refresh both HomePage and AnalyticsPage
      setState(() {
        _pages[0] = HomePage(key: UniqueKey());
        _pages[1] = AnalyticsPage();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _pages[_selectedIndex],
          if (_isFabExpanded) ...[
            Positioned.fill(
              child: GestureDetector(
                onTap: () => setState(() => _isFabExpanded = false),
                child: Container(
                  color: Colors.black.withAlpha(30),
                )
              ),
            ),

            Positioned(
              bottom: MediaQuery.of(context).size.height * 0.05,
              left: MediaQuery.of(context).size.width * 0.288,
              child: Row(
                children: [
                  _buildMiniFab(
                    icon: Icon(Icons.download_rounded, color: Colors.white, size: 30),
                    color: Colors.green,
                    onPressed: _navigateToAddIncome,
                  ),

                  SizedBox(width: MediaQuery.of(context).size.width * 0.15),

                  _buildMiniFab(
                    icon: Icon(Icons.upload_rounded, color: Colors.white, size: 30),
                    color: Colors.red,
                    onPressed: _navigateToAddExpense
                  ),
                ],
              ),
            )
          ]
        ],
      ),
      bottomNavigationBar: FloatingBottomBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onFabPressed,
        shape: CircleBorder(),
        backgroundColor: _isFabExpanded ? Colors.deepPurple : Colors.blue,
        child: Icon(_isFabExpanded ? Icons.close : Icons.add, size: 30, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildMiniFab({
    required Icon icon,
    required Color color,
    required VoidCallback onPressed
  }) {
    return FloatingActionButton(
      shape: CircleBorder(),
      backgroundColor: color,
      onPressed: onPressed,
      child: icon,
    );
  }
}