import 'package:flutter/material.dart';

import '../services/storage_service.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeProvider(this._storage);

  final StorageService _storage;
  ThemeMode _mode = ThemeMode.system;
  Future<void> _pending = Future.value();

  ThemeMode get mode => _mode;

  Future<void> load() async {
    _mode = await _storage.getThemeMode();
    notifyListeners();
  }

  Future<void> toggle() {
    final result = _pending.then((_) async {
      final isDark =
          _mode == ThemeMode.dark ||
          (_mode == ThemeMode.system &&
              WidgetsBinding.instance.platformDispatcher.platformBrightness ==
                  Brightness.dark);
      final next = isDark ? ThemeMode.light : ThemeMode.dark;
      await _storage.setThemeMode(next);
      _mode = next;
      notifyListeners();
    });
    _pending = result.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return result;
  }
}
