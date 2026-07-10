import 'package:app_kebudyaan_lobar/ui/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart'; 
import 'dart:ui' as ui;

class DikbudInfoPage extends StatelessWidget {
  const DikbudInfoPage({super.key});

  // Widget Glassmorphism (Sesuai AppColors baru)
  Widget _buildGlassCard({required Widget child, Color? color, double opacity = 0.9}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          decoration: BoxDecoration(
            // ✅ Perbaikan: Tidak ada AppColors.fromARGB. Langsung gunakan AppColors.cardSurface
            color: (color ?? AppColors.cardSurface).withValues(alpha: opacity), 
            borderRadius: BorderRadius.circular(16),
            // ✅ Perbaikan: Gunakan .withValues
            border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
            boxShadow: [
              BoxShadow(
                // ✅ Perbaikan: Gunakan .withValues
                color: Colors.black.withValues(alpha: 0.05), 
                blurRadius: 10, 
                offset: const Offset(0, 4)
              )
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  // Widget untuk menampilkan item kontak (Telepon/Email/Map)
  Widget _buildContactItem(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ Menggunakan AppColors.primary (Warna Biru Langit)
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary)),
                Text(subtitle, style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          "Dikbud Lombok Barat",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textWhite),
        ),
        // ✅ Menggunakan AppColors.primary (Biru Langit Baru)
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textWhite),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. VISI & MISI
            _buildGlassCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Visi & Misi", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
                    const SizedBox(height: 12),
                    Text("Visi:", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text("Terwujudnya Sumber Daya Manusia Lombok Barat yang Cerdas, Berkarakter, dan Berbudaya.", style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
                    const SizedBox(height: 12),
                    Text("Misi:", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text("1. Meningkatkan kualitas pendidikan dan kebudayaan.\n2. Melestarikan dan mengembangkan seni budaya daerah.\n3. Mewujudkan tata kelola pendidikan yang transparan dan akuntabel.", style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),

            // 2. STRUKTUR ORGANISASI
            _buildGlassCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Struktur Organisasi", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
                    const SizedBox(height: 16),
                    _buildJabatanItem("Kepala Dinas", "Drs. H. Lalu Ahmad Mulyadi, M.M."),
                    Divider(height: 1, color: Colors.grey.shade200),
                    _buildJabatanItem("Sekretaris", "Drs. H. M. Zaenal Arifin, M.M."),
                    Divider(height: 1, color: Colors.grey.shade200),
                    _buildJabatanItem("Kabid. Pembinaan PAUD & PNF", "Hj. Baiq Raudatul Jannah, S.Pd., M.M."),
                    Divider(height: 1, color: Colors.grey.shade200),
                    _buildJabatanItem("Kabid. Pembinaan SD", "Saprudin, S.Pd., M.M."),
                    Divider(height: 1, color: Colors.grey.shade200),
                    _buildJabatanItem("Kabid. Pembinaan SMP", "Yanuarsyah, S.Pd., M.Pd."),
                    Divider(height: 1, color: Colors.grey.shade200),
                    _buildJabatanItem("Kabid. Kebudayaan", "Baiq Supriatin, S.Pd., M.M."),
                    Divider(height: 1, color: Colors.grey.shade200),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 3. KONTAK DAN ALAMAT
            _buildGlassCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Kontak & Alamat", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
                    const SizedBox(height: 16),
                    _buildContactItem(
                      Icons.location_on_outlined,
                      "Alamat Dinas",
                      "Jl. Gora No.1, Gerung, Kec. Gerung, Kabupaten Lombok Barat, Nusa Tenggara Barat 83351"
                    ),
                    Divider(height: 1, color: Colors.grey.shade200),
                    _buildContactItem(
                      Icons.phone_outlined,
                      "Telepon / WhatsApp",
                      "0370 - 681090"
                    ),
                    Divider(height: 1, color: Colors.grey.shade200),
                    _buildContactItem(
                      Icons.email_outlined,
                      "Email Resmi",
                      "dikbud@lombokbaratkab.go.id"
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () async {
                          final Uri url = Uri.parse('https://dikbud.lombokbaratkab.go.id/');
                          if (!await launchUrl(url)) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal membuka portal web")));
                          }
                        },
                        icon: const Icon(Icons.open_in_new, size: 16, color: AppColors.primary),
                        label: Text("Kunjungi Portal Resmi", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.primary)),
                      ),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildJabatanItem(String jabatan, String nama) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 30,
            // ✅ Menggunakan AppColors.primary (Biru Langit) untuk garis aksen
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.5), 
              borderRadius: BorderRadius.circular(4)
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(jabatan, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
                const SizedBox(height: 2),
                Text(nama, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              ],
            ),
          )
        ],
      ),
    );
  }
}