import 'package:app_kebudyaan_lobar/ui/pages/kelola_agenda_page.dart';
import 'package:app_kebudyaan_lobar/ui/pages/kelola_cagar_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/settings_provider.dart';
import '../admin/admin_login_page.dart';

class CulturalColors {
  static const Color primary = Color.fromARGB(255, 94, 155, 235);
  static const Color secondary = Color(0xFFFDFBF7);
  static const Color accent = Color(0xFFD4AF37);
  static const Color textDark = Color(0xFF3E2723);
  static const Color textGrey = Color(0xFF6D4C41);
  static const Color background = Color(0xFFFAF9F6);
  static const Color surface = Colors.white;
}

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

  // 🔥 FUNGSI PENERJEMAH MINI OTOMATIS
  // id = Indonesia, sasak = Basa Sasak, en = English
  String _t(String currentLang, String id, String sasak, String en) {
    if (currentLang == 'sasak') return sasak;
    if (currentLang == 'en') return en;
    return id; // Default ke Indonesia
  }

  // --- DIALOG BAHASA (DENGAN ENGLISH) ---
  void _showLanguageDialog(BuildContext context, String currentLang) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final settings = context.read<SettingsProvider>();
        return Container(
          decoration: const BoxDecoration(
            color: CulturalColors.surface,
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
                      height: 40,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2)))),
              Text(
                  _t(currentLang, "Pilih Bahasa", "Pilih Basa",
                      "Select Language"),
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: CulturalColors.textDark,
                      fontFamily: 'Serif')),
              const SizedBox(height: 20),

              // Opsi Indonesia
              _buildLanguageItem(context,
                  flag: "🇮🇩",
                  title: "Bahasa Indonesia",
                  code: 'id',
                  currentCode: settings.currentLocale.languageCode),

              // Opsi Sasak
              _buildLanguageItem(context,
                  flag: "lombok_flag",
                  icon: Icons.temple_buddhist,
                  title: "Basa Sasak (Lombok)",
                  code: 'sasak',
                  currentCode: settings.currentLocale.languageCode),

              // 🔥 OPSI INGGRIS
              _buildLanguageItem(context,
                  flag: "🇬🇧",
                  title: "English (International)",
                  code: 'en',
                  currentCode: settings.currentLocale.languageCode),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageItem(BuildContext context,
      {required String title,
      required String code,
      required String currentCode,
      String? flag,
      IconData? icon}) {
    final bool isSelected = currentCode == code;
    final settings = context.read<SettingsProvider>();

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
            color: isSelected
                ? CulturalColors.primary.withOpacity(0.1)
                : CulturalColors.background,
            borderRadius: BorderRadius.circular(12)),
        child: Center(
            child: icon != null
                ? Icon(icon,
                    color: isSelected
                        ? CulturalColors.primary
                        : CulturalColors.textGrey)
                : Text(flag ?? "", style: const TextStyle(fontSize: 24))),
      ),
      title: Text(title,
          style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: CulturalColors.textDark)),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: CulturalColors.primary)
          : null,
      onTap: () {
        settings.changeLanguage(code);
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider?>(context);
    final settings = Provider.of<SettingsProvider>(context);

    final bool isLoggedIn = auth?.isLoggedIn ?? false;
    final String lang = settings.currentLocale.languageCode; // id / sasak / en

    final String userName = (auth?.currentUser?.displayName ??
        (isLoggedIn
            ? "Staf Dinas"
            : _t(lang, "Pengunjung (Tamu)", "Semeton (Tamu)",
                "Visitor (Guest)")));

    final String userEmail = (auth?.currentUser?.email ??
        (isLoggedIn
            ? "staf@kebudayaan.lobar.go.id"
            : _t(
                lang,
                "Jelajahi kebudayaan tanpa batas",
                "Jelajahin kebudayaan endek araq batas",
                "Explore culture without limits")));

    return Scaffold(
      backgroundColor: CulturalColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ==========================================
            // 1. HEADER GRADASI & AVATAR MENGAMBANG
            // ==========================================
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  height: 220,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        CulturalColors.primary,
                        CulturalColors.primary.withOpacity(0.7)
                      ],
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
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
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Text(
                              _t(lang, "Profil Saya", "Profil Tiang",
                                  "My Profile"),
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontFamily: 'Serif'),
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -50,
                  child: AnimatedBuilder(
                      animation: _enterController,
                      builder: (context, child) {
                        final t = Curves.easeOutBack
                            .transform(_enterController.value);
                        return Transform.scale(
                          scale: t,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: CulturalColors.surface,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                    color:
                                        CulturalColors.primary.withOpacity(0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10))
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: CulturalColors.secondary,
                              child: Icon(
                                  isLoggedIn
                                      ? Icons.admin_panel_settings_rounded
                                      : Icons.person_rounded,
                                  size: 50,
                                  color: CulturalColors.primary),
                            ),
                          ),
                        );
                      }),
                ),
              ],
            ),

            const SizedBox(height: 60),

            // ==========================================
            // 2. INFO PENGGUNA & TOMBOL LOGIN/EDIT
            // ==========================================
            Text(userName,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: CulturalColors.textDark,
                    fontFamily: 'Serif')),
            const SizedBox(height: 4),
            Text(userEmail,
                style: const TextStyle(
                    fontSize: 14, color: CulturalColors.textGrey)),
            const SizedBox(height: 20),

            SizedBox(
              width: 180,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (isLoggedIn) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(_t(lang, "Fitur Edit Profil",
                            "Fitur Edit Profil", "Edit Profile Feature"))));
                  } else {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AdminLoginPage()));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: CulturalColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shadowColor: CulturalColors.primary.withOpacity(0.4),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                icon: Icon(
                    isLoggedIn ? Icons.edit_rounded : Icons.login_rounded,
                    size: 18),
                label: Text(
                    isLoggedIn
                        ? _t(lang, "Edit Profil", "Edit Profil", "Edit Profile")
                        : _t(lang, "Masuk (Staf)", "Masuk (Staf)",
                            "Staff Login"),
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),

            const SizedBox(height: 32),

            // ==========================================
            // 3. MENU PENGATURAN & BANTUAN
            // ==========================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  _buildSectionHeader(_t(lang, "Pengaturan Aplikasi",
                      "Pengaturan Aplikasi", "App Settings")),
                  _buildSectionCard(
                    children: [
                      _profileItem(
                        icon: Icons.language_rounded,
                        iconColor: Colors.blue,
                        title: _t(lang, "Bahasa Aplikasi", "Basa Aplikasi",
                            "App Language"),
                        subtitle: _t(lang, "Bahasa Indonesia", "Sasak (Lombok)",
                            "English"),
                        onTap: () => _showLanguageDialog(context, lang),
                      ),
                      _divider(),
                      _profileItem(
                        icon: Icons.notifications_active_rounded,
                        iconColor: Colors.amber.shade700,
                        title: _t(lang, "Notifikasi", "Pemberitauan",
                            "Notifications"),
                        subtitle: _isNotifActive
                            ? _t(lang, "Aktif", "Aktif", "Enabled")
                            : _t(lang, "Nonaktif", "Mati", "Disabled"),
                        onTap: () {},
                        trailing: Switch(
                          value: _isNotifActive,
                          activeColor: CulturalColors.primary,
                          onChanged: (val) {
                            setState(() => _isNotifActive = val);
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  _buildSectionHeader(_t(lang, "Bantuan & Informasi",
                      "Bantuan & Informasi", "Help & Information")),
                  _buildSectionCard(
                    children: [
                      // 🔥 MENU BARU: STANDAR PELAYANAN & SOP
                      _profileItem(
                        icon: Icons.assignment_rounded,
                        iconColor: const Color(0xFF008080), // Teal/Tosca kedinasan
                        title: _t(lang, "SP & SOP", "SP & SOP", "Service Standard & SOP"),
                        subtitle: _t(
                            lang, 
                            "Standar Pelayanan & Operasional", 
                            "Standar Pelayanan & Operasional", 
                            "Service & Operational Standards"),
                        onTap: () {
                          // TODO: Arahkan ke halaman daftar PDF/detail SP & SOP Anda
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(_t(lang, "Membuka SP & SOP", "Membuka SP & SOP", "Opening SP & SOP")))
                          );
                        },
                      ),
                      _divider(),
                      _profileItem(
                        icon: Icons.help_outline_rounded,
                        iconColor: Colors.green,
                        title: _t(lang, "Pusat Bantuan", "Pusat Bantuan",
                            "Help Center"),
                        subtitle: _t(lang, "FAQ & Kontak", "FAQ & Kontak",
                            "FAQ & Contacts"),
                        onTap: () {},
                      ),
                      _divider(),
                      _profileItem(
                        icon: Icons.info_outline_rounded,
                        iconColor: Colors.purple,
                        title: _t(lang, "Tentang Aplikasi", "Tentang Aplikasi",
                            "About App"),
                        subtitle: _t(
                            lang,
                            "Versi 1.0.0 (Dinas Pendidikan & Kebudayaan)",
                            "Versi 1.0.0 (Dinas Pendidikan & Kebudayaan)",
                            "Version 1.0.0 (Dept. of Education & Culture)"),
                        onTap: () {},
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ==========================================
                  // 4. MENU ADMIN (Jika Login)
                  // ==========================================
                  if (isLoggedIn) ...[
                    _buildSectionHeader("Admin Menu"),
                    _buildSectionCard(
                      children: [
                        _profileItem(
                          icon: Icons.landscape_rounded,
                          iconColor: CulturalColors.primary,
                          title: _t(lang, "Kelola Cagar Budaya",
                              "Kelola Cagar Budaya", "Manage Heritage Sites"),
                          subtitle: _t(lang, "Tambah / Edit Data",
                              "Tambah / Edit Data", "Add / Edit Data"),
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const KelolaCagarPage())),
                        ),
                        _divider(),
                        _profileItem(
                          icon: Icons.event_note_rounded,
                          iconColor: Colors.orange,
                          title: _t(lang, "Kelola Agenda", "Kelola Agenda",
                              "Manage Agenda"),
                          subtitle: _t(lang, "Jadwal Event Budaya",
                              "Jadwal Event Budaya", "Cultural Event Schedule"),
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const KelolaAgendaPage())),
                        ),
                        _divider(),
                        _profileItem(
                          icon: Icons.logout_rounded,
                          iconColor: Colors.red,
                          title: _t(lang, "Keluar", "Keluar", "Log Out"),
                          subtitle: _t(lang, "Akhiri Sesi", "Akhiri Sesi",
                              "End Session"),
                          isDanger: true,
                          onTap: () => auth?.logout(),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 40),

                  // ==========================================
                  // 5. FOOTER
                  // ==========================================
                  const Icon(Icons.spa_rounded,
                      size: 24, color: CulturalColors.textGrey),
                  const SizedBox(height: 8),
                  Text(
                    "@2025 produced by Bidang Pembinaan Kebudayaan\nDinas Pendidikan dan Kebudayaan Lombok Barat",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 11,
                        color: CulturalColors.textGrey.withOpacity(0.7),
                        height: 1.5),
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

  // --- WIDGET HELPERS ---

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: CulturalColors.textGrey,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: CulturalColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: CulturalColors.textDark.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.only(left: 64, right: 20),
      child: Divider(height: 1, color: Colors.grey.shade200),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDanger
                    ? Colors.red.withOpacity(0.1)
                    : iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon,
                  size: 22, color: isDanger ? Colors.red : iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: isDanger ? Colors.red : CulturalColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                        fontSize: 12, color: CulturalColors.textGrey),
                  ),
                ],
              ),
            ),
            if (trailing != null)
              trailing
            else
              const Icon(Icons.chevron_right_rounded,
                  size: 20, color: Colors.grey)
          ],
        ),
      ),
    );
  }
}