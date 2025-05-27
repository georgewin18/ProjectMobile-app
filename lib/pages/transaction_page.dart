import 'package:flutter/material.dart';
import '../services/api_service.dart';

class TransactionPage extends StatefulWidget {
  @override
  _TransactionPageState createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  late Future<List<dynamic>> _transactions;

  final TextEditingController _descController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  final List<Map<String, String>> categories = [
    {'id': '1', 'name': 'Transportation'},
    {'id': '2', 'name': 'Shopping'},
    {'id': '3', 'name': 'Subscription'},
  ];

  String? selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _transactions = ApiService.getTransactions();
    selectedCategoryId = categories.first['id'];
  }

  void _refresh() {
    setState(() {
      _transactions = ApiService.getTransactions();
    });
  }

  Future<void> _addTransaction() async {
    final desc = _descController.text.trim();
    final amount = double.tryParse(_amountController.text.trim());

    if (desc.isEmpty || amount == null || selectedCategoryId == null) return;

    try {
      await ApiService.createTransaction(
        description: desc,
        amount: amount,
        categoryId: selectedCategoryId!,
        date: DateTime.now(),
      );
      _descController.clear();
      _amountController.clear();
      _refresh();
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void dispose() {
    _descController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Transactions')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  controller: _descController,
                  decoration: InputDecoration(labelText: 'Description'),
                ),
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Amount'),
                ),
                SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedCategoryId,
                  items: categories
                      .map((cat) => DropdownMenuItem<String>(
                    value: cat['id'],
                    child: Text(cat['name']!),
                  ))
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      selectedCategoryId = val;
                    });
                  },
                  decoration: InputDecoration(labelText: 'Category'),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _addTransaction,
                  child: Text('Add Transaction'),
                ),
              ],
            ),
          ),
          Divider(),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _transactions,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final transactions = snapshot.data!;
                if (transactions.isEmpty) {
                  return Center(child: Text('No transactions yet.'));
                }

                return ListView.builder(
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final tx = transactions[index];
                    return ListTile(
                      title: Text(tx['description']),
                      subtitle: Text('${tx['amount']} - ${tx['transaction_date']}'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
