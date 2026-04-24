import 'package:flutter/foundation.dart';

import '../data/mock_notifications.dart';
import '../models/fin_pay_notification.dart';

class NotificationsProvider extends ChangeNotifier {
  NotificationsProvider() {
    _items = mockFinPayNotifications();
  }

  late List<FinPayNotification> _items;

  /// Newest first.
  List<FinPayNotification> get notifications {
    final list = [..._items];
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list;
  }

  int get unreadCount => _items.where((n) => !n.read).length;

  FinPayNotification? byId(String id) {
    try {
      return _items.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  void markRead(String id) {
    final i = _items.indexWhere((e) => e.id == id);
    if (i == -1 || _items[i].read) return;
    _items[i] = _items[i].copyWith(read: true);
    notifyListeners();
  }

  void markAllRead() {
    _items = [for (final n in _items) n.copyWith(read: true)];
    notifyListeners();
  }
}
