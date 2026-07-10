import 'package:app_kebudyaan_lobar/ui/pages/kelola_agenda_page.dart';
import 'package:app_kebudyaan_lobar/ui/pages/kelola_cagar_page.dart';
import 'package:app_kebudyaan_lobar/ui/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/settings_provider.dart';
import '../admin/admin_login_page.dart';

// ✅ Impor AppColors yang sudah kita standarisasi


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enterController;
  bool _isNotifActive = true;

  @override
  void initState() {
    super.initState();
    _enterController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _enterController.forward();
  }

  @override
  void dispose() {
    _enterController.dispose();
    super.dispose();
  }

  // Fungsi terjemahan multi-bahasa
  String _t(String currentLang, String id, String sasak, String en) {
    if (currentLang == 'sasak') return sasak;
    if (currentLang == 'en') return en;
    return id;
  }

  // Dialog Pilihan Bahasa
  void _showLanguageDialog(BuildContext context, String currentLang) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final settings = context.read<SettingsProvider>();
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: AppColors.modalHandle, // ✅ Menggunakan AppColors.modalHandle
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Text(
                _t(currentLang, "Pilih Bahasa", "Pilih Basa", "Select Language"),
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 24),

              // Opsi Bahasa Indonesia
              _buildLanguageItem(
                context,
                flag: "🇮🇩",
                title: "Bahasa Indonesia",
                code: 'id',
                currentCode: settings.currentLocale.languageCode,
              ),
              const SizedBox(height: 8),

              // Opsi Bahasa Sasak
              _buildLanguageItem(
                context,
                icon: Icons.temple_buddhist,
                title: "Basa Sasak (Lombok)",
                code: 'sasak',
                currentCode: settings.currentLocale.languageCode,
              ),
              const SizedBox(height: 8),

              // Opsi Bahasa Inggris
              _buildLanguageItem(
                context,
                flag: "🇬🇧",
                title: "English (International)",
                code: 'en',
                currentCode: settings.currentLocale.languageCode,
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageItem(BuildContext context, {
    required String title,
    required String code,
    required String currentCode,
    String? flag,
    IconData? icon,
  }) {
    final bool isSelected = currentCode == code;
    final settings = context.read<SettingsProvider>();

    return InkWell(
      onTap: () {
        settings.changeLanguage(code);
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              child: icon != null
                  ? Icon(icon, size: 24, color: isSelected ? AppColors.primary : AppColors.textSecondary)
                  : Text(flag ?? "", style: const TextStyle(fontSize: 24)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.primary, size: 22),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider?>(context);
    final settings = Provider.of<SettingsProvider>(context);

    final bool isLoggedIn = auth?.isLoggedIn ?? false;
    final String lang = settings.currentLocale.languageCode;

    final String userName = auth?.currentUser?.displayName ??
        (isLoggedIn
            ? "Staf Dinas Kebudayaan"
            : _t(lang, "Pengunjung", "Semeton", "Visitor"));

    final String userEmail = auth?.currentUser?.email ??
        (isLoggedIn
            ? "staf@kebudayaan.lobar.go.id"
            : _t(lang, "Jelajahi warisan budaya", "Jelajahi warisan budaya", "Explore cultural heritage"));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // Header Gradien Premium
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  height: 220,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                                color: Colors.white, size: 20),
                            onPressed: () => Navigator.maybePop(context),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              _t(lang, "Profil Saya", "Profil Tiang", "My Profile"),
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                    ),
                  ),
                ),
                // Avatar dengan efek mewah
                Positioned(
                  bottom: -50,
                  child: AnimatedBuilder(
                    animation: _enterController,
                    builder: (context, child) {
                      final t = Curves.easeOutBack.transform(_enterController.value);
                      return Transform.scale(
                        scale: t,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.cardSurface,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            child: Icon(
                              isLoggedIn
                                  ? Icons.admin_panel_settings_rounded
                                  : Icons.person_rounded,
                              size: 50,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 60),

            // Info Pengguna
            Text(
              userName,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              userEmail,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),

            // Tombol Aksi Premium
            SizedBox(
              width: 180,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (isLoggedIn) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(_t(lang, "Fitur akan segera hadir", "Fitur bakalan ada", "Feature coming soon"), style: GoogleFonts.poppins()),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AdminLoginPage()),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shadowColor: AppColors.primary.withValues(alpha: 0.4),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                icon: Icon(
                  isLoggedIn ? Icons.edit_rounded : Icons.login_rounded,
                  size: 18,
                ),
                label: Text(
                  isLoggedIn
                      ? _t(lang, "Edit Profil", "Edit Profil", "Edit Profile")
                      : _t(lang, "Masuk Staf", "Masuk Staf", "Staff Login"),
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Bagian Pengaturan Aplikasi
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildSectionHeader(_t(lang, "Pengaturan Aplikasi", "Pengaturan Aplikasi", "App Settings")),
                  _buildSectionCard(
                    children: [
                      _profileItem(
                        icon: Icons.language_rounded,
                        iconColor: Colors.blue,
                        title: _t(lang, "Bahasa Aplikasi", "Basa Aplikasi", "App Language"),
                        subtitle: _t(lang, "Bahasa Indonesia", "Basa Sasak", "English"),
                        onTap: () => _showLanguageDialog(context, lang),
                      ),
                      _divider(),
                      _profileItem(
                        icon: Icons.notifications_active_rounded,
                        iconColor: AppColors.warning,
                        title: _t(lang, "Notifikasi", "Pemberitahuan", "Notifications"),
                        subtitle: _isNotifActive
                            ? _t(lang, "Aktif", "Aktif", "Enabled")
                            : _t(lang, "Nonaktif", "Mati", "Disabled"),
                        onTap: () {},
                        trailing: Switch(
                          value: _isNotifActive,
                          activeColor: AppColors.primary,
                          onChanged: (val) => setState(() => _isNotifActive = val),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // 🔥 BAGIAN BANTUAN & INFORMASI (Data Resmi Dikbud Lobar)
                  _buildSectionHeader(_t(lang, "Bantuan & Informasi", "Bantuan & Informasi", "Help & Information")),
                  _buildSectionCard(
                    children: [
                      _profileItem(
                        icon: Icons.assignment_rounded,
                        iconColor: AppColors.teal,
                        title: _t(lang, "SP & SOP", "SP & SOP", "Service Standard & SOP"),
                        subtitle: _t(lang, "Standar Pelayanan & Operasional", "Standar Pelayanan", "Service & Operational Standards"),
                        onTap: () => _showSOPDialog(context, lang), // ✅ Data diambil dari web resmi
                      ),
                      _divider(),
                      _profileItem(
                        icon: Icons.help_outline_rounded,
                        iconColor: AppColors.green,
                        title: _t(lang, "Pusat Bantuan", "Pusat Bantuan", "Help Center"),
                        subtitle: _t(lang, "FAQ & Kontak Resmi", "FAQ & Kontak Resmi", "FAQ & Official Contacts"),
                        onTap: () => _showHelpCenterDialog(context, lang), // ✅ Data diambil dari web resmi
                      ),
                      _divider(),
                      _profileItem(
                        icon: Icons.info_outline_rounded,
                        iconColor: AppColors.iconPurple,
                        title: _t(lang, "Tentang Aplikasi", "Tentang Aplikasi", "About App"),
                        subtitle: _t(lang, "Versi 1.0.0 | Dinas Pendidikan & Kebudayaan", "Versi 1.0.0", "Version 1.0.0 | Dept. of Education & Culture"),
                        onTap: () => _showAboutDialog(context, lang),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Menu Khusus Admin
                  if (isLoggedIn) ...[
                    _buildSectionHeader(_t(lang, "Menu Admin", "Menu Admin", "Admin Menu")),
                    _buildSectionCard(
                      children: [
                        _profileItem(
                          icon: Icons.landscape_rounded,
                          iconColor: AppColors.primary,
                          title: _t(lang, "Kelola Cagar Budaya", "Kelola Cagar Budaya", "Manage Heritage Sites"),
                          subtitle: _t(lang, "Tambah / Ubah / Hapus Data", "Kelola data cagar", "Add / Edit / Delete Data"),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const KelolaCagarPage()),
                          ),
                        ),
                        _divider(),
                        _profileItem(
                          icon: Icons.event_note_rounded,
                          iconColor: AppColors.warning,
                          title: _t(lang, "Kelola Agenda", "Kelola Agenda", "Manage Agenda"),
                          subtitle: _t(lang, "Jadwal Kegiatan Budaya", "Jadwal acara", "Cultural Event Schedule"),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const KelolaAgendaPage()),
                          ),
                        ),
                        _divider(),
                        _profileItem(
                          icon: Icons.logout_rounded,
                          iconColor: AppColors.error,
                          title: _t(lang, "Keluar", "Keluar", "Log Out"),
                          subtitle: _t(lang, "Akhiri sesi akun", "Tutup sesi", "End current session"),
                          isDanger: true,
                          onTap: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: Text(_t(lang, "Konfirmasi", "Konfirmasi", "Confirmation"), style: GoogleFonts.poppins()),
                                content: Text(_t(lang, "Yakin ingin keluar?", "Yakin mau keluar?", "Are you sure you want to log out?"), style: GoogleFonts.poppins()),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: Text(_t(lang, "Batal", "Batal", "Cancel"), style: GoogleFonts.poppins()),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: Text(_t(lang, "Ya, Keluar", "Ya, Keluar", "Yes, Log Out"), style: GoogleFonts.poppins(color: AppColors.error)),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true && mounted) {
                              await auth?.logout();
                            }
                          },
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 40),

                  // Footer
                  const Icon(Icons.spa_rounded, size: 24, color: AppColors.textSecondary),
                  const SizedBox(height: 8),
                  Text(
                    "© 2025 Bidang Pembinaan Kebudayaan\nDinas Pendidikan dan Kebudayaan Lombok Barat",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.textSecondary.withOpacity(0.7),
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- FUNGSI DIALOG SP & SOP (Data Resmi) ---
  void _showSOPDialog(BuildContext context, String lang) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("SP & SOP Layanan", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Standar Pelayanan Dinas Pendidikan dan Kebudayaan Kabupaten Lombok Barat", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.primary)),
            const SizedBox(height: 12),
            _buildInfoRow("🕒 Jam Layanan", "Senin - Kamis: 07:30 - 16:00 WITA\nJumat: 07:30 - 11:00 WITA"),
            const SizedBox(height: 8),
            _buildInfoRow("📍 Alamat Kantor", "Jl. Gora No.1, Gerung, Kec. Gerung, Lombok Barat, NTB 83351"),
            const SizedBox(height: 8),
            _buildInfoRow("📞 Kontak", "0370 - 681090 (Pusat Informasi)"),
            const SizedBox(height: 8),
            _buildInfoRow("📧 Email Resmi", "dikbud@lombokbaratkab.go.id"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Tutup", style: GoogleFonts.poppins(color: AppColors.primary)),
          )
        ],
      ),
    );
  }

  // --- FUNGSI DIALOG PUSAT BANTUAN & FAQ (Data Resmi) ---
  void _showHelpCenterDialog(BuildContext context, String lang) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Pusat Bantuan", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("FAQ (Pertanyaan Umum)", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary)),
              const SizedBox(height: 8),
              _buildInfoRow("💡 Cara mencari Cagar Budaya?", "Gunakan fitur pencarian di Beranda, atau buka menu 'Peta' untuk melihat lokasi."),
              const SizedBox(height: 8),
              _buildInfoRow("💡 Bagaimana cara Login Staf?", "Klik tombol 'Masuk Staf' di halaman Profil. Gunakan akun yang telah didaftarkan oleh admin."),
              const SizedBox(height: 8),
              _buildInfoRow("💡 Aplikasi error/tidak bisa masuk?", "Pastikan koneksi internet stabil. Jika masih error, hubungi admin Dinas melalui kontak resmi."),
              const Divider(height: 30),
              Text("Visi & Misi Dinas", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary)),
              const SizedBox(height: 8),
              Text("Visi: Terwujudnya Sumber Daya Manusia Lombok Barat yang Cerdas, Berkarakter, dan Berbudaya.", style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              Text("Misi: 1. Meningkatkan kualitas pendidikan dan kebudayaan. 2. Melestarikan dan mengembangkan seni budaya daerah.", style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary)),
              const Divider(height: 30),
              Text("Kontak Resmi Dinas", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary)),
              const SizedBox(height: 8),
              _buildInfoRow("📞 Telepon", "0370 - 681090"),
              _buildInfoRow("📧 Email", "dikbud@lombokbaratkab.go.id"),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Tutup", style: GoogleFonts.poppins(color: AppColors.primary)),
          )
        ],
      ),
    );
  }

  // --- FUNGSI DIALOG TENTANG APLIKASI ---
  void _showAboutDialog(BuildContext context, String lang) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Tentang SILORA", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Icon(Icons.museum, size: 48, color: AppColors.primary)),
            const SizedBox(height: 12),
            Text("SILORA (Sistem Informasi Kebudayaan Lombok Barat)", textAlign: TextAlign.center, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primary)),
            const SizedBox(height: 12),
            Text("Aplikasi resmi Dinas Pendidikan dan Kebudayaan Kabupaten Lombok Barat untuk mempromosikan, melestarikan, dan memetakan cagar budaya, kesenian, serta event pariwisata di Lombok Barat.", textAlign: TextAlign.justify, style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            Text("Versi: 1.0.0 (Stable)", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.textPrimary)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Tutup", style: GoogleFonts.poppins(color: AppColors.primary)),
          )
        ],
      ),
    );
  }

  // --- FUNGSI HELPER UNTUK MENAMPILKAN ROW INFORMASI ---
  Widget _buildInfoRow(String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textSecondary)),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: Text(desc, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textPrimary)),
        ),
      ],
    );
  }

  // Widget Pembantu Layout
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title.toUpperCase(),
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.only(left: 64, right: 20),
      child: Divider(height: 1, thickness: 1, color: AppColors.divider), // ✅ Menggunakan AppColors.divider
    );
  }

  Widget _profileItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
    bool isDanger = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDanger ? AppColors.error.withOpacity(0.1) : iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 22, color: isDanger ? AppColors.error : iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: isDanger ? AppColors.error : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null)
              trailing
            else
              const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.textTertiary)
          ],
        ),
      ),
    );
  }
}