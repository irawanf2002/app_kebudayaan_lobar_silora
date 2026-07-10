import 'package:flutter/material.dart';

class AppColors {
  // ===========================================================================
  // 1. TEMA BARU: SKY BLUE MUTED (Berdasarkan Gambar User, tapi tidak mencolok)
  // ===========================================================================
  // WARNA UTAMA: Deep Sky Blue (Tidak mencolok, Cerah, Profesional)
  static const Color primary = Color(0xFF00A2E8);
  static const Color primaryDark = Color(0xFF0077B6);

  // WARNA SEKUNDER: Abu-abu Kebiruan (Aksen Gradasi)
  static const Color secondary = Color(0xFF64B5F6);

  // WARNA AKSEN: Emas (Benang Songket/Rating)
  static const Color accent = Color(0xFFD4AF37);
  static const Color rating = Color(0xFFFFB300);

  // ===========================================================================
  // 2. BACKGROUNDS & SURFACES (Light/Bersih)
  // ===========================================================================
  static const Color background = Color(0xFFF8F9FA); // Off-White
  static const Color cardSurface = Color(0xFFFFFFFF); // Kartu Putih Bersih
  static const Color white = Color(0xFFFFFFFF);

  // ===========================================================================
  // 3. TEXT COLORS (Dark Text on Light Background)
  // ===========================================================================
  static const Color textPrimary = Color(0xFF424242);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textTertiary = Color(0xFFBDBDBD);
  static const Color textWhite = Color(0xFFFFFFFF);

  // ===========================================================================
  // 4. KATEGORI & FUNGSIONAL (Disesuaikan ke Warna Muted Blue)
  // ===========================================================================
  // Ikon Seragam (Warna Utama Baru)
  static const Color iconUniform = Color(0xFF00A2E8);

  // Warna Aksen untuk Ikon Agenda (Tetap Terang agar terlihat di Agenda Card)
  static const Color iconBlue = Color(0xFF42A5F5);
  static const Color iconPurple = Color(0xFFBA68C8);
  static const Color iconYellow = Color(0xFFFFCA28);
  static const Color iconRed = Color(0xFFE57373);

  // ===========================================================================
  // 5. LAIN-LAIN
  // ===========================================================================
  static const Color inputBg = Color(0xFFEEEEEE);
  static const Color error = Color(0xFFD32F2F);

  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFFFFFFF);

  // ===========================================================================
  // 6. 🆕 TAMBAHAN BARU: STATUS CAGAR BUDAYA & GRADASI
  // ===========================================================================
  
  // Warna Status untuk Peta / Kartu (Misal: Terawat / Rusak Ringan / Rusak Berat)
  static const Color success = Color(0xFF26A69A); // Hijau Teal (Untuk status 'Terawat')
  static const Color warning = Color(0xFFFF9800); // Oranye (Untuk status 'Rusak Ringan')

  // Warna Gradasi Dasar (Untuk Header, Banner Event, dan Shimmer Placeholder)
  static const Color gradientStart = Color(0xFF00A2E8); // Sama dengan AppColors.primary
  static const Color gradientEnd = Color(0xFF0077B6);   // Sama dengan AppColors.primaryDark

  // ===========================================================================
  // 7. 🆕 TAMBAHAN BARU: COMPONENT COLORS (UNTUK PROFILE PAGE & UI LAINNYA)
  // ===========================================================================
  static const Color divider = Color(0xFFEEEEEE); // Garis pemisah kartu yang lembut
  static const Color modalHandle = Color(0xFFBDBDBD); // Gagang (Handle) Bottom Sheet

  // Warna spesifik untuk Ikon Menu di Profile Page (Agar tidak perlu hardcode)
  static const Color teal = Color(0xFF008080); // Warna untuk ikon SOP/SP
  static const Color green = Color(0xFF4CAF50); // Warna untuk ikon Pusat Bantuan

  // ===========================================================================
  // 8. 🆕 TAMBAHAN BARU: MAP & NAVIGATION COLORS (UNTUK MAPS PAGE)
  // ===========================================================================
  static const Color mapBackground = Color(0xFF0F172A); // Latar belakang peta gelap agar kontras
  static const Color routeLine = Color(0xFF29B6F6);     // Garis rute navigasi berwarna biru cerah
  static const Color routeDestination = Color(0xFFE53935); // Bendera akhir rute / Titik tujuan

  // --- WARNA VIBRANT LAMA (Dinetralkan) ---
  static const Color brandTeal = Color(0xFF00897B);
  static const Color brandBlue = Color(0xFF29B6F6);
  static const Color brandPurple = Color(0xFFAB47BC);
  static const Color brandYellow = Color(0xFFFBC02D);
  static const Color brandOrange = Color(0xFFFF7043);
}