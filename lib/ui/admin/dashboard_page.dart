import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

// Import halaman-halaman lain
import 'admin_login_page.dart';
import 'cagar_admin_list_page.dart';
import 'agenda_admin_list_page.dart';
import 'cfn_admin_list_page.dart';

import '../../data/providers/cagar_provider.dart';

class DashboardAdminPage extends StatefulWidget {
  const DashboardAdminPage({super.key});

  @override
  State<DashboardAdminPage> createState() => _DashboardAdminPageState();
}

class _DashboardAdminPageState extends State<DashboardAdminPage> {
  int _selectedIndex = 0;
  bool _isSidebarOpen = true;

  // Variabel untuk data dari Firestore
  int _totalCagar = 0;
  int _totalUlasan = 0;
  int _totalAgenda = 0;
  int _totalPengunjung = 0;

  // Tema Warna Premium
  final Color _primaryNavy = const Color(0xFF1E3A8A);
  final Color _secondaryIndigo = const Color(0xFF312E81);
  final Color _sidebarDark = const Color(0xFF0F172A);
  final Color _bgLightGray = const Color(0xFFF8FAFC);

  @override
  void initState() {
    super.initState();
    _ambilDataDariFirestore(); // Ambil data saat halaman dibuka
  }

  // Fungsi untuk membaca data dari Firestore
  Future<void> _ambilDataDariFirestore() async {
    try {
      // Baca jumlah dokumen dari setiap koleksi
      final cagarSnapshot = await FirebaseFirestore.instance.collection('cagar_budaya').get();
      final ulasanSnapshot = await FirebaseFirestore.instance.collection('comments').get();
      final agendaSnapshot = await FirebaseFirestore.instance.collection('agenda_events').get();
      final pengunjungSnapshot = await FirebaseFirestore.instance.collection('pengunjung').get();

      if (mounted) {
        setState(() {
          _totalCagar = cagarSnapshot.docs.length;
          _totalUlasan = ulasanSnapshot.docs.length;
          _totalAgenda = agendaSnapshot.docs.length;
          _totalPengunjung = pengunjungSnapshot.docs.length;
        });
      }
    } catch (e) {
      debugPrint("Gagal mengambil data dari Firestore: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Gagal memuat data: $e"), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      backgroundColor: _bgLightGray,
      drawer: isMobile ? _buildSidebar() : null,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMobile && _isSidebarOpen) _buildSidebar(),
          Expanded(
            child: _getSelectedPage(isMobile: isMobile),
          ),
        ],
      ),
    );
  }

  Widget _getSelectedPage({required bool isMobile}) {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardContent(isMobile: isMobile);
      case 1:
        return const CagarAdminListPage();
      case 2:
        return const AgendaAdminListPage();
      case 3:
        return const CfnAdminListPage();
      default:
        return _buildDashboardContent(isMobile: isMobile);
    }
  }

  Widget _buildDashboardContent({required bool isMobile}) {
    return Column(
      children: [
        _buildTopBar(isMobile: isMobile),
        Expanded(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderSection(isMobile: isMobile),
                _buildSummaryCards(isMobile: isMobile),
                _buildDataSection(isMobile: isMobile),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ================== FUNGSI XGBOOST ==================
  Future<void> _jalankanPrediksiXGBoost() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("🚀 Menjalankan Prediksi XGBoost..."),
          duration: Duration(seconds: 2),
        ),
      );

      final response = await http.post(
        Uri.parse('https://alamat-server-anda.com/predict'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        await Provider.of<CagarProvider>(context, listen: false).refreshData();
        await _ambilDataDariFirestore(); // Refresh data setelah proses selesai

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("✅ Prediksi XGBoost Berhasil! Data diperbarui."),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception("Server merespons kode: ${response.statusCode}");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Gagal: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ================== SIDEBAR ==================
  Widget _buildSidebar() {
    return Container(
      width: 280,
      constraints: const BoxConstraints(maxWidth: 280),
      decoration: BoxDecoration(
        color: _sidebarDark,
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 15, offset: Offset(5, 0))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildLogoBox('assets/images/tutwuri.png', Icons.school),
                      _buildLogoBox('assets/images/kebudayaanlobar.png', Icons.museum),
                      _buildLogoBox('assets/images/lombokbarat.jpeg', Icons.map),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    const Text("SILORA", style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                    Text(" ADMIN", style: TextStyle(color: Colors.blueAccent, fontSize: 26, fontWeight: FontWeight.w300, letterSpacing: 1.5)),
                  ],
                ),
                const SizedBox(height: 6),
                const Text("Portal Manajemen Data", style: TextStyle(color: Colors.white54, fontSize: 13, letterSpacing: 0.5)),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 28, bottom: 16, top: 10),
            child: Text("MENU UTAMA", style: TextStyle(color: Colors.white38, fontSize: 11, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
          ),
          _sidebarItem(Icons.dashboard_rounded, "Dasbor Utama", 0),
          _sidebarItem(Icons.museum_rounded, "Kelola Cagar Budaya", 1),
          _sidebarItem(Icons.event_note_rounded, "Agenda Event", 2),
          _sidebarItem(Icons.nightlife_rounded, "Jadwal CFN", 3),
          const Spacer(),
          const Divider(color: Colors.white12, height: 1, indent: 24, endIndent: 24),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: _sidebarItem(Icons.logout_rounded, "Keluar Sesi", 99, isLogout: true),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoBox(String path, IconData fallbackIcon) {
    return Container(
      height: 48,
      width: 48,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))],
      ),
      child: Image.asset(path, fit: BoxFit.contain, errorBuilder: (_, __, ___) => Icon(fallbackIcon, color: _primaryNavy, size: 24)),
    );
  }

  Widget _sidebarItem(IconData icon, String title, int index, {bool isLogout = false}) {
    bool isActive = _selectedIndex == index;
    Color baseColor = isLogout ? Colors.redAccent : Colors.blueAccent;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? baseColor.withOpacity(0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isActive ? baseColor.withOpacity(0.3) : Colors.transparent, width: 1),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        leading: Icon(icon, color: isActive || isLogout ? baseColor : Colors.white54, size: 22),
        title: Text(
          title,
          style: TextStyle(
            color: isActive || isLogout ? (isLogout ? Colors.redAccent : Colors.white) : Colors.white60,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            fontSize: 14,
          ),
        ),
        onTap: () {
          if (Navigator.canPop(context)) Navigator.pop(context);
          if (isLogout) {
            _handleLogout();
          } else {
            setState(() => _selectedIndex = index);
          }
        },
      ),
    );
  }

  Future<void> _handleLogout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminLoginPage()));
    }
  }

  // ================== TOP BAR ==================
  Widget _buildTopBar({required bool isMobile}) {
    return Container(
      height: isMobile ? 65 : 75,
      decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 2))]),
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 32),
      child: Row(
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40),
            icon: Icon(Icons.menu_open_rounded, color: _primaryNavy, size: isMobile ? 24 : 28),
            onPressed: () {
              if (isMobile) {
                Scaffold.of(context).openDrawer();
              } else {
                setState(() => _isSidebarOpen = !_isSidebarOpen);
              }
            },
          ),
          const SizedBox(width: 16),
          Expanded(
            child: SizedBox(
              height: 45,
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Cari data cagar atau agenda...",
                  hintStyle: TextStyle(fontSize: isMobile ? 13 : 14, color: Colors.black45),
                  prefixIcon: const Icon(Icons.search, size: 20, color: Colors.black45),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
                  filled: true,
                  fillColor: const Color(0xFFF1F5F9),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                ),
              ),
            ),
          ),
          if (!isMobile) ...[
            const SizedBox(width: 32),
            const Stack(
              children: [
                Icon(Icons.notifications_none_rounded, color: Colors.black54, size: 28),
                Positioned(right: 2, top: 2, child: SizedBox(width: 10, height: 10, child: DecoratedBox(decoration: BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle)))),
              ],
            ),
            const SizedBox(width: 24),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [_primaryNavy, Colors.blueAccent])),
                  child: const CircleAvatar(backgroundColor: Colors.white, radius: 18, child: Icon(Icons.person, color: Color(0xFF1E3A8A), size: 22)),
                ),
                const SizedBox(width: 12),
                const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Admin Staf", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
                    Text("Dinas Dikbud", style: TextStyle(color: Colors.black54, fontSize: 12)),
                  ],
                )
              ],
            )
          ] else ...[
            const SizedBox(width: 12),
            const CircleAvatar(backgroundColor: Color(0xFF1E3A8A), radius: 16, child: Icon(Icons.person, color: Colors.white, size: 20)),
          ]
        ],
      ),
    );
  }

  // ================== HEADER ==================
  Widget _buildHeaderSection({required bool isMobile}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(isMobile ? 20 : 40, isMobile ? 30 : 48, isMobile ? 20 : 40, isMobile ? 50 : 80),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [_primaryNavy, _secondaryIndigo], begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
      child: isMobile 
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                child: const Text("V.1.0 - Production", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
              const SizedBox(height: 16),
              const Text("Ringkasan Sistem Informasi", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
              const SizedBox(height: 8),
              Text("Bidang Kebudayaan - Dinas Pendidikan dan Kebudayaan Lombok Barat", style: TextStyle(color: Colors.blue[100], fontSize: 13, height: 1.4)),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => setState(() => _selectedIndex = 1),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: _primaryNavy, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  icon: const Icon(Icons.add_box_rounded),
                  label: const Text("Kelola Data", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              )
            ],
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                    child: const Text("V.1.0 - Production", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  ),
                  const SizedBox(height: 16),
                  const Text("Ringkasan Sistem Informasi", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                  const SizedBox(height: 8),
                  Text("Bidang Kebudayaan - Dinas Pendidikan dan Kebudayaan Lombok Barat", style: TextStyle(color: Colors.blue[100], fontSize: 15, letterSpacing: 0.2)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => setState(() => _selectedIndex = 1),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: _primaryNavy, padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                icon: const Icon(Icons.add_box_rounded),
                label: const Text("Kelola Data", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              )
            ],
          ),
    );
  }

  // ================== SUMMARY CARDS (DATA DARI FIREBASE) ==================
  Widget _buildSummaryCards({required bool isMobile}) {
    return Transform.translate(
      offset: const Offset(0, -50),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 40),
        child: isMobile
          ? GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
              children: [
                _statCard("Total Cagar", "$_totalCagar", Icons.account_balance, Colors.blueAccent),
                _statCard("Total Ulasan", "$_totalUlasan", Icons.rate_review_rounded, Colors.orangeAccent),
                _statCard("Agenda Event", "$_totalAgenda", Icons.event_available_rounded, Colors.teal),
                _buildXGBoostCard(),
                _statCard("Pengunjung", "$_totalPengunjung", Icons.people_alt_rounded, Colors.deepPurpleAccent),
              ],
            )
          : Row(
              children: [
                Expanded(child: _statCard("Total Cagar", "$_totalCagar", Icons.account_balance, Colors.blueAccent)),
                const SizedBox(width: 16),
                Expanded(child: _statCard("Total Ulasan", "$_totalUlasan", Icons.rate_review_rounded, Colors.orangeAccent)),
                const SizedBox(width: 16),
                Expanded(child: _statCard("Agenda Event", "$_totalAgenda", Icons.event_available_rounded, Colors.teal)),
                const SizedBox(width: 16),
                Expanded(child: _buildXGBoostCard()),
                const SizedBox(width: 16),
                Expanded(child: _statCard("Pengunjung", "$_totalPengunjung", Icons.people_alt_rounded, Colors.deepPurpleAccent)),
              ],
            ),
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: color.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(color: Colors.black54, fontSize: 15, fontWeight: FontWeight.w600)),
                Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: color, size: 24)),
              ],
            ),
            const SizedBox(height: 20),
            Text(value, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.black87, letterSpacing: -1)),
          ],
        ),
      ),
    );
  }

  Widget _buildXGBoostCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.deepOrange.shade300, width: 2),
        boxShadow: [BoxShadow(color: Colors.deepOrange.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: InkWell(
        onTap: _jalankanPrediksiXGBoost,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.deepOrange.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.psychology_rounded, color: Colors.deepOrange, size: 28),
                  ),
                  const Icon(Icons.play_arrow_rounded, color: Colors.deepOrange, size: 32),
                ],
              ),
              const SizedBox(height: 20),
              const Text("Analisis XGBoost", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 6),
              const Text("Jalankan Prediksi Kondisi", style: TextStyle(fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.deepOrange.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: const Text("Terbaru", style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================== BAGIAN INFORMASI ==================
  Widget _buildDataSection({required bool isMobile}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(isMobile ? 16 : 40, 0, isMobile ? 16 : 40, 40),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 24, offset: Offset(0, 8))],
        ),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 24 : 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: _primaryNavy.withOpacity(0.1), shape: BoxShape.circle), child: Icon(Icons.info_rounded, color: _primaryNavy)),
                  const SizedBox(width: 16),
                  const Text("Pemberitahuan Sistem", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                ],
              ),
              const Padding(padding: EdgeInsets.symmetric(vertical: 24.0), child: Divider(height: 1, color: Color(0xFFF1F5F9))),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.blue.shade50, Colors.white]), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.blue.shade100)),
                child: Row(
                  children: [
                    Container(padding: const EdgeInsets.all(8), decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: const Icon(Icons.verified_user_rounded, color: Colors.green, size: 28)),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Sistem Berjalan Normal", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                          const SizedBox(height: 4),
                          Text("Sistem Informasi Kebudayaan (SILORA) terhubung dengan Firebase Firestore. Data diperbarui secara otomatis.", style: TextStyle(color: Colors.blueGrey.shade700, height: 1.5, fontSize: 14)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}