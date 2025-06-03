class Transaction {
  final String description;
  final double amount;
  final int categoryId;
  final DateTime transactionDate;

  Transaction({
    required this.description,
    required this.amount,
    required this.categoryId,
    required this.transactionDate,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      description: json['description'],
      amount: double.parse(json['amount']),
      categoryId: int.parse(json['category_id']) ,
      transactionDate: DateTime.parse(json['created_at']),
    );
  }
}