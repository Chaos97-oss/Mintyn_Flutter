enum TransactionCategory { wallet, shopping, banking, saving, other }

class TransactionModel {
  const TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.timestamp,
    required this.category,
    this.merchant = '',
    this.referenceId = '',
    this.status = 'Completed',
    this.channel = 'FinPay Wallet',
    this.notes = '',
    this.fee = 0,
  });

  final String id;
  final String title;
  final double amount;
  final DateTime timestamp;
  final TransactionCategory category;

  /// Display merchant / counterparty.
  final String merchant;

  /// Bank-style reference.
  final String referenceId;

  final String status;
  final String channel;
  final String notes;
  final double fee;

  bool get isCredit => amount >= 0;
}
