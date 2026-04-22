enum TransactionType { credit, debit }

class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final TransactionType type;
  final String iconName; // Maps to asset or icon identifier

  const TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
    required this.iconName,
  });
}
