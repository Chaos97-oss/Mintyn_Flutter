import 'package:flutter/foundation.dart';

class UiProvider extends ChangeNotifier {
  bool _sidebarOpen = false;

  bool get sidebarOpen => _sidebarOpen;

  void toggleSidebar() {
    _sidebarOpen = !_sidebarOpen;
    notifyListeners();
  }

  void closeSidebar() {
    if (!_sidebarOpen) return;
    _sidebarOpen = false;
    notifyListeners();
  }
}
