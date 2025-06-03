import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_mobile/components/history_transaction.dart';
import 'package:project_mobile/components/transaction_summary_card.dart';
import 'package:project_mobile/models/transaction.dart';
import 'package:project_mobile/services/api_service.dart';
import 'package:project_mobile/services/supabase_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Transaction> transactions = [];
  double income = 0;
  double expenses = 0;
  double balance = 0;
  bool isLoading = true;

  final numberFormat = NumberFormat.decimalPattern();

  @override
  void initState() {
    super.initState();
    fetchTransaction();
  }

  Future<void> fetchTransaction() async {
    try {
      final data = await ApiService.getTransactions();
      final fetched = data.map((json) => Transaction.fromJson(json)).toList();

      double totalIncome = 0;
      double totalExpenses = 0;

      for (var tx in fetched) {
        if (tx.categoryId > 6) {
          totalIncome += tx.amount;
        } else {
          totalExpenses += tx.amount;
        }
      }

      setState(() {
        transactions = fetched;
        income = totalIncome;
        expenses = totalExpenses;
        balance = totalIncome - totalExpenses;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('FETCH ERROR: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = SupabaseService.client.auth.currentUser;
    // debugPrint('TOKEN: ${SupabaseService.client.auth.currentSession?.accessToken}');

    return Scaffold(
      appBar: AppBar(
        title: Text('Hi, ${user!.email}!'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await SupabaseService.client.auth.signOut();
              if (context.mounted) {
                Navigator.of(context)
                  .pushNamedAndRemoveUntil('/login', (route) => false);
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView(
          padding: EdgeInsets.all(16),
          children: [
            SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'My Balance',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54
                    )
                  ),

                  Text(
                    'Rp ${numberFormat.format(balance)}',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: balance < 0 ? Colors.red : Colors.black
                    )
                  )
                ],
              ),
            ),

            SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 80,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TransactionSummaryCard(
                    label: 'Income',
                    amount: 'Rp ${numberFormat.format(income)}',
                    margin: EdgeInsets.only(right: 8)
                  ),
                  TransactionSummaryCard(
                    label: 'Expenses',
                    amount: 'Rp ${numberFormat.format(expenses)}',
                    margin: EdgeInsets.only(left: 8),
                  )
                ],
              )
            ),

            SizedBox(height: 16),

            HistoryTransaction(transactions: transactions),
          ],
        ),
      )
    );
  }
}
