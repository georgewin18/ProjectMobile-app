class Transaction {
  final String id;
  final String description;
  final double amount;
  final int categoryId;
  final DateTime transactionDate;

  Transaction({
    required this.id,
    required this.description,
    required this.amount,
    required this.categoryId,
    required this.transactionDate,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      description: json['description'],
      amount: double.parse(json['amount']),
      categoryId: int.parse(json['category_id']) ,
      transactionDate: DateTime.parse(json['created_at']),
    );
  }
}