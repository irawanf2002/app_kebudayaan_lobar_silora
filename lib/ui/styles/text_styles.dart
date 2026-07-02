import 'package:flutter/material.dart';
import 'colors.dart'; // Pastikan file colors.dart ada di folder yang sama

class AppTextStyles {
  // =============================================================
  // 1. HEADLINES (Untuk Judul Besar)
  // =============================================================
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary, // Putih (di Dark Mode)
    letterSpacing: -0.5,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  // =============================================================
  // 2. TITLES (Untuk Judul Card, Sub-bab)
  // =============================================================
  static const TextStyle titleLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600, // Semi Bold
    color: AppColors.textPrimary,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // =============================================================
  // 3. BODY (Untuk Deskripsi & Konten)
  // =============================================================
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5, // Jarak antar baris agar nyaman dibaca
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary, // Abu-abu terang (di Dark Mode)
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: Colors.grey, // Abu-abu gelap untuk info tambahan
  );

  // =============================================================
  // 4. FUNCTIONAL (Tombol, Input, Label)
  // =============================================================

  // Teks Tombol
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.white, // Selalu putih di atas tombol biru
  );

  // Label Input Form
  static const TextStyle inputLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  // Hint Text (Placeholder)
  static const TextStyle inputHint = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: Colors.grey,
  );

  // Error Text
  static const TextStyle error = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: Colors.redAccent, // Merah terang agar terlihat di hitam
  );

  // Link / TextButton
  static const TextStyle link = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AppColors.primary, // Biru Elegan
    decoration: TextDecoration.underline,
  );

  // =============================================================
  // 5. THEME DATA CONFIGURATION
  // =============================================================
  // Masukkan ini ke main.dart -> theme: ThemeData(textTheme: ...)

  static const TextTheme mainTextTheme = TextTheme(
    headlineLarge: headlineLarge,
    headlineMedium: headlineMedium,
    titleLarge: titleLarge,
    titleMedium: titleMedium,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
    labelLarge: button,
  );
}
