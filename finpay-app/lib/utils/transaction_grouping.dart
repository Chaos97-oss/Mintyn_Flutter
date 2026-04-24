import 'package:intl/intl.dart';

import '../models/transaction_model.dart';

/// Groups transactions by calendar day (yyyy-MM-dd), newest day first.
Map<String, List<TransactionModel>> groupTransactionsByDay(List<TransactionModel> items) {
  final sorted = List<TransactionModel>.from(items)
    ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  final map = <String, List<TransactionModel>>{};
  for (final t in sorted) {
    final key = DateFormat('yyyy-MM-dd').format(t.timestamp);
    map.putIfAbsent(key, () => []).add(t);
  }
  final orderedKeys = map.keys.toList()..sort((a, b) => b.compareTo(a));
  return {for (final k in orderedKeys) k: map[k]!};
}

String formatDayHeader(String yyyyMmDd) {
  final d = DateFormat('yyyy-MM-dd').parse(yyyyMmDd);
  final now = DateTime.now();
  if (DateFormat('yyyy-MM-dd').format(now) == yyyyMmDd) {
    return 'Today · ${DateFormat('MMM d, yyyy').format(d)}';
  }
  final y = DateTime(now.year, now.month, now.day).difference(DateTime(d.year, d.month, d.day)).inDays;
  if (y == 1) {
    return 'Yesterday · ${DateFormat('MMM d, yyyy').format(d)}';
  }
  return DateFormat('EEEE · MMM d, yyyy').format(d);
}
