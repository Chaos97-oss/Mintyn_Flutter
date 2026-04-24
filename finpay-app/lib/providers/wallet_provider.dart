import 'package:flutter/foundation.dart';

import '../data/mock_data.dart';
import '../models/payment_card_model.dart';
import '../models/transaction_model.dart';

class WalletProvider extends ChangeNotifier {
  WalletProvider() {
    _transactions = mockHomeTransactions();
    _cards = mockCards();
  }

  double _balance = 1200;
  late List<TransactionModel> _transactions;
  late List<PaymentCardModel> _cards;
  CardKind _activeCardKind = CardKind.physical;

  double get balance => _balance;
  List<TransactionModel> get transactions => List.unmodifiable(_transactions);
  List<PaymentCardModel> get cards => List.unmodifiable(_cards);
  CardKind get activeCardKind => _activeCardKind;

  /// Newest first (full ledger).
  List<TransactionModel> get transactionsSorted {
    final list = List<TransactionModel>.from(_transactions);
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list;
  }

  /// Home filter tabs: Weekly | Monthly | Today
  List<TransactionModel> transactionsForHomeFilter(int tab) {
    final now = DateTime.now();
    final list = transactionsSorted;
    bool sameDay(DateTime a, DateTime b) =>
        a.year == b.year && a.month == b.month && a.day == b.day;
    switch (tab) {
      case 0:
        // From midnight at start of the calendar day 7 days ago (stable vs clock time).
        final todayStart = DateTime(now.year, now.month, now.day);
        final start = todayStart.subtract(const Duration(days: 7));
        return list.where((t) => !t.timestamp.isBefore(start)).toList();
      case 1:
        return list.where((t) => t.timestamp.year == now.year && t.timestamp.month == now.month).toList();
      case 2:
        return list.where((t) => sameDay(t.timestamp, now)).toList();
      default:
        return list;
    }
  }

  List<PaymentCardModel> cardsForKind(CardKind kind) =>
      _cards.where((c) => c.kind == kind).toList();

  PaymentCardModel? primaryCardForActiveKind() {
    final list = cardsForKind(_activeCardKind);
    return list.isEmpty ? null : list.first;
  }

  void setActiveCardKind(CardKind kind) {
    if (_activeCardKind == kind) return;
    _activeCardKind = kind;
    notifyListeners();
  }

  void addTransaction(TransactionModel t) {
    _transactions = [t, ..._transactions];
    notifyListeners();
  }

  void adjustBalance(double delta) {
    _balance += delta;
    notifyListeners();
  }

  String newReferenceId() => 'FP${DateTime.now().millisecondsSinceEpoch}';

  /// Debit wallet and append a ledger row (transfers, bills, donations, etc.).
  /// Returns the reference id, or empty string if amount is invalid.
  String recordSpend({
    required double amount,
    required String title,
    required TransactionCategory category,
    String merchant = '',
    String notes = '',
    String channel = 'FinPay Wallet',
  }) {
    if (amount <= 0) return '';
    final ref = newReferenceId();
    _balance -= amount;
    _transactions = [
      TransactionModel(
        id: ref,
        title: title,
        amount: -amount,
        timestamp: DateTime.now(),
        category: category,
        merchant: merchant,
        referenceId: ref,
        channel: channel,
        notes: notes,
      ),
      ..._transactions,
    ];
    notifyListeners();
    return ref;
  }

  /// Credit wallet and append a ledger row (top-ups, deposits, refunds).
  String recordReceive({
    required double amount,
    required String title,
    required TransactionCategory category,
    String merchant = '',
    String notes = '',
    String channel = 'FinPay Wallet',
  }) {
    if (amount <= 0) return '';
    final ref = newReferenceId();
    _balance += amount;
    _transactions = [
      TransactionModel(
        id: ref,
        title: title,
        amount: amount,
        timestamp: DateTime.now(),
        category: category,
        merchant: merchant,
        referenceId: ref,
        channel: channel,
        notes: notes,
      ),
      ..._transactions,
    ];
    notifyListeners();
    return ref;
  }
}
