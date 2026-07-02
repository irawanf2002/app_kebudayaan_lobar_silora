import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  SettingsProvider() {
    _loadSettings();
  }

  // --- LOGIC DARK MODE ---
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  void toggleTheme(bool isDark) async {
    _isDarkMode = isDark;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
  }

  // --- LOGIC BAHASA ---
  Locale _currentLocale = const Locale('id', 'ID');
  Locale get currentLocale => _currentLocale;

  // Variabel pembantu untuk memanggil field di Firestore secara dinamis
  // Jika bahasa Inggris, ambil field 'english_description', jika tidak ambil 'deskripsi'
  String get contentField => _currentLocale.languageCode == 'en' ? 'english_description' : 'deskripsi';

  String get languageName {
    switch (_currentLocale.languageCode) {
      case 'sasak':
        return "Basa Sasak";
      case 'en':
        return "English";
      default:
        return "Bahasa Indonesia";
    }
  }

  // Memuat pengaturan saat aplikasi pertama kali dibuka
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    String? langCode = prefs.getString('languageCode');
    if (langCode != null) {
      _currentLocale = Locale(langCode);
    }
    notifyListeners();
  }

  void changeLanguage(String languageCode) async {
    if (languageCode == 'sasak') {
      _currentLocale = const Locale('sasak', 'ID');
    } else if (languageCode == 'en') {
      _currentLocale = const Locale('en', 'US');
    } else {
      _currentLocale = const Locale('id', 'ID');
    }
    
    notifyListeners(); // Memicu REBUILD di seluruh halaman aplikasi

    // Simpan secara permanen di memori HP
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', languageCode);
  }
}