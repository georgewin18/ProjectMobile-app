class Budget {
  final String id;
  final int categoryId;
  final double amount;
  final double usedAmount;
  final DateTime startDate;
  final DateTime endDate;
  final int? alertValue;

  Budget({
    required this.id,
    required this.categoryId,
    required this.amount,
    required this.usedAmount,
    required this.startDate,
    required this.endDate,
    this.alertValue,
  });

  double get totalBudget => amount;
  double get remainingAmount => amount - usedAmount;

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'],
      categoryId: int.tryParse(json['category_id'] ?? '') ?? 0,
      amount: double.tryParse(json['amount'] ?? '0') ?? 0.0,
      usedAmount: double.tryParse(json['used_amount'] ?? '0') ?? 0.0,
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      alertValue: int.tryParse(json['alert_value']?.toString() ?? ''),
    );
  }
}