import 'package:app_kebudyaan_lobar/ui/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // ✅ Tambahkan import ini // ✅ Path ini sudah benar

class AllCategoriesPage extends StatelessWidget {
  const AllCategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Semua Kategori", style: GoogleFonts.poppins(color: Colors.white)),
        // ✅ Sekarang AppColors sudah terdeteksi dengan benar
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: const Center(
        child: Text("Di sini nanti Anda bisa menampilkan Grid kategori lengkap"),
      ),
    );
  }
}