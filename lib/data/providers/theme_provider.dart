import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadTheme();
  }

  /// Muat tema dari SharedPreferences
  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
      notifyListeners();
    } catch (e) {
      debugPrint("Gagal memuat tema: $e");
    }
  }

  /// Toggle tema dan simpan ke SharedPreferences
  Future<void> toggleTheme() async {
    try {
      _isDarkMode = !_isDarkMode;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDarkMode', _isDarkMode);
    } catch (e) {
      debugPrint("Gagal menyimpan tema: $e");
    }
  }
}
