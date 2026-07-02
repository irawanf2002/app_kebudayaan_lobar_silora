import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  Locale? _locale;

  Locale? get locale => _locale;

  void setLocale(Locale locale) async {
    _locale = locale;
    notifyListeners();

    // Simpan pilihan ke memori HP
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);
  }

  void clearLocale() {
    _locale = null;
    notifyListeners();
  }
}
