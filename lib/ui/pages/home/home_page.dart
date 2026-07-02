import 'package:app_kebudyaan_lobar/ui/pages/lang_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Untuk SystemNavigator
import 'package:provider/provider.dart';
// Import untuk cek platform (Web/Android)
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:permission_handler/permission_handler.dart';
import 'dart:async'; // Untuk Timer Shimmer

// PROVIDER
import '../../../data/providers/cagar_provider.dart';
// 🔥 SISIPAN: Import Provider Bahasa
import '../../../data/providers/settings_provider.dart';

// 🔥 SISIPAN: Import Kamus Bahasa

// WIDGET PECAHAN
import 'widgets/kategori_menu.dart';
// import 'widgets/agenda_carousel.dart'; // DIHAPUS: Karena section agenda dihilangkan
import 'widgets/situs_terbaru_list.dart';

// HALAMAN LAIN
import '../ceo_page.dart'; // Halaman Agenda (Tetap ada di Menu Bawah)
import '../cfn_page.dart'; // Halaman CFN
import '../maps_page.dart';
import '../profile_page.dart';

// STYLES
import '../../styles/colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  late final List<Widget> _pages;

  // Variabel untuk logika Double Back to Exit
  DateTime? currentBackPressTime;

  @override
@override
void initState() {
  super.initState();

  Future.microtask(() {
    context.read<CagarProvider>().fetchCagar();
  });

  _mintaIzinPenyimpanan();

  _pages = [
    const HomeContentPage(),
    const MapsPage(),
    CoePage(onNavTapped: _onTabSelected),
    const CfnPage(),
    const ProfilePage(),
  ];
}

  Future<void> _mintaIzinPenyimpanan() async {
    if (kIsWeb) return;

    var statusStorage = await Permission.storage.status;
    var statusPhotos = await Permission.photos.status;

    if (!statusStorage.isGranted && !statusPhotos.isGranted) {
      await [
        Permission.storage,
        Permission.photos,
      ].request();
    }
  }

  void _onTabSelected(int index) {
    setState(() => _selectedIndex = index);
  }

  // --- DRAWER MENU SAMPING ---
  Widget _buildDrawer() {
    // 🔥 SISIPAN: Baca bahasa yang sedang aktif untuk menu Drawer
    final String lang =
        context.watch<SettingsProvider>().currentLocale.languageCode;

    return Drawer(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: AppColors.primary),
            // 🔥 SISIPAN: Translasi
            accountName: Text(
                LangHelper.t(
                    lang, "Pengguna Tamu", "Semeton (Tamu)", "Guest User"),
                style: const TextStyle(fontWeight: FontWeight.bold)),
            // 🔥 SISIPAN: Translasi
            accountEmail: Text(LangHelper.t(
                lang,
                "Selamat datang di Budaya Lobar",
                "Tunas napi leq Budaya Lobar",
                "Welcome to Lobar Culture")),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Image.asset('assets/images/logo_budaya.png',
                  errorBuilder: (c, e, s) =>
                      const Icon(Icons.person, color: AppColors.primary)),
            ),
          ),
          ListTile(
            minLeadingWidth: 20, // Merapatkan jarak ikon ke teks
            horizontalTitleGap: 12,
            leading:
                const Icon(Icons.dashboard_rounded, color: AppColors.primary),
            // 🔥 SISIPAN: Translasi
            title: Text(LangHelper.t(lang, 'Beranda', 'Beranda', 'Home')),
            onTap: () {
              Navigator.pop(context);
              _onTabSelected(0);
            },
          ),
          ListTile(
            minLeadingWidth: 20, // Merapatkan jarak ikon ke teks
            horizontalTitleGap: 12,
            leading: const Icon(Icons.map_rounded, color: AppColors.primary),
            // 🔥 SISIPAN: Translasi
            title: Text(LangHelper.t(
                lang, 'Peta Wisata', 'Peta Wisata', 'Tourist Map')),
            onTap: () {
              Navigator.pop(context);
              _onTabSelected(1);
            },
          ),
          ListTile(
            minLeadingWidth: 20, // Merapatkan jarak ikon ke teks
            horizontalTitleGap: 12,
            leading: const Icon(Icons.info_outline_rounded,
                color: AppColors.primary),
            // 🔥 SISIPAN: Translasi
            title: Text(LangHelper.t(
                lang, 'Tentang Aplikasi', 'Tentang Aplikasi', 'About App')),
            onTap: () {
              Navigator.pop(context);
              showAboutDialog(
                context: context,
                applicationName: "Budaya Lobar",
                applicationVersion: "1.0.0",
                applicationIcon: Image.asset('assets/images/logo_budaya.png',
                    width: 50, height: 50),
                children: [
                  // 🔥 SISIPAN: Translasi
                  Text(LangHelper.t(
                      lang,
                      "Aplikasi Jelajah Kebudayaan Lombok Barat membantu Anda menemukan destinasi wisata budaya, kuliner, dan kesenian terbaik.",
                      "Aplikasi Jelajah Kebudayaan Lombok Barat yakne mbandu pelinggih mete destinasi wisata budaya, kuliner, dait kesenian sak solah.",
                      "West Lombok Cultural Exploration App helps you discover the best cultural, culinary, and art tourist destinations.")),
                ],
              );
            },
          ),
          const Divider(),
          ListTile(
            minLeadingWidth: 20, // Merapatkan jarak ikon ke teks
            horizontalTitleGap: 12,
            leading: const Icon(Icons.logout_rounded, color: Colors.red),
            // 🔥 SISIPAN: Translasi
            title: Text(LangHelper.t(lang, 'Keluar', 'Sugul', 'Exit'),
                style: const TextStyle(color: Colors.red)),
            onTap: () {
              SystemNavigator.pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 SISIPAN: Baca bahasa yang sedang aktif untuk struktur Scaffold
    final String lang =
        context.watch<SettingsProvider>().currentLocale.languageCode;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;

        if (_selectedIndex != 0) {
          setState(() => _selectedIndex = 0);
          return;
        }

        final now = DateTime.now();
        if (currentBackPressTime == null ||
            now.difference(currentBackPressTime!) >
                const Duration(seconds: 2)) {
          currentBackPressTime = now;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              // 🔥 SISIPAN: Translasi
              content: Text(LangHelper.t(lang, 'Tekan sekali lagi untuk keluar',
                  'Tekan sekale malik jari sugul', 'Press once again to exit')),
              duration: const Duration(seconds: 2),
            ),
          );
          return;
        }
        SystemNavigator.pop();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        drawer: _buildDrawer(),
        extendBody: true, // Agar lengkungan transparan tembus ke body
        body: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),

        // --- BOTTOM APP BAR ---
        bottomNavigationBar: BottomAppBar(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          height: 80,
          color: Colors.white,
          elevation: 10,
          shadowColor: Colors.black,
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween, // Distribusi rata
            children: [
              // 🔥 SISIPAN: Translasi
              _buildNavItem(0, Icons.dashboard_outlined, Icons.dashboard,
                  LangHelper.t(lang, 'Jelajah', 'Jelajahin', 'Explore')),
              _buildNavItem(1, Icons.map_outlined, Icons.map,
                  LangHelper.t(lang, 'Peta', 'Peta', 'Map')),
              // UPDATE: Agenda masuk ke sini sejajar
              _buildNavItem(
                  2,
                  Icons.calendar_today_outlined,
                  Icons.calendar_month,
                  LangHelper.t(lang, 'Agenda', 'Jadwal', 'Agenda')),
              _buildNavItem(3, Icons.grid_view_outlined, Icons.grid_view,
                  'CoE CFN'), // Biarkan aslinya
              _buildNavItem(4, Icons.person_outline, Icons.person,
                  LangHelper.t(lang, 'Profil', 'Profil', 'Profile')),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET ITEM NAVIGASI (MODEL PILL / KAPSUL) ---
  Widget _buildNavItem(
      int index, IconData iconInactive, IconData iconActive, String label) {
    bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onTabSelected(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 65, // Lebar area sentuh
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // KONTAINER IKON (BENTUK PILL/KAPSUL)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              height: 38, // Tinggi kapsul
              width: isSelected ? 58 : 38, // Lebar kapsul (melebar saat aktif)
              decoration: BoxDecoration(
                // Warna background hanya muncul saat aktif (gaya Material 3)
                color: isSelected
                    ? AppColors.primary.withOpacity(0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20), // Sudut sangat bulat
              ),
              child: Center(
                // ANIMASI GANTI IKON
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, anim) =>
                      ScaleTransition(scale: anim, child: child),
                  child: Icon(
                    isSelected ? iconActive : iconInactive,
                    key: ValueKey(isSelected),
                    size: 28, // Ukuran ikon
                    color:
                        isSelected ? AppColors.primary : Colors.grey.shade600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            // LABEL TEXT
            Text(
              label,
              maxLines: 1,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primary : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= CONTENT PAGE =================
class HomeContentPage extends StatefulWidget {
  const HomeContentPage({super.key});

  @override
  State<HomeContentPage> createState() => _HomeContentPageState();
}

class _HomeContentPageState extends State<HomeContentPage> {
  final TextEditingController _searchController =
      TextEditingController(); // Tambahkan Controller
  final ScrollController _scrollController = ScrollController();
  bool _showBackToTopButton = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset >= 400 && !_showBackToTopButton) {
        setState(() => _showBackToTopButton = true);
      } else if (_scrollController.offset < 400 && _showBackToTopButton) {
        setState(() => _showBackToTopButton = false);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose(); // Dispose Controller
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    _scrollController.animateTo(0,
        duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    // Ambil data provider untuk cek loading
    final provider = context.watch<CagarProvider>();
    // 🔥 SISIPAN: Baca bahasa yang sedang aktif untuk Konten
    final String lang =
        context.watch<SettingsProvider>().currentLocale.languageCode;

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () async {
          },
          color: AppColors.primary,
          backgroundColor: Colors.white,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ---------------- HEADER MODEREN (LOGO FULL) ----------------
              SliverAppBar(
                // Diperbesar lagi agar muat untuk teks dan logo
                expandedHeight: 220,
                pinned: true,
                backgroundColor: Colors.white,
                elevation: 0,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(50),
                  ),
                ),
                leading: Padding(
                  padding: const EdgeInsets.all(4.0), // Padding agar ukuran pas
                  child: Image.asset(
                    'assets/images/logo_kabupaten.png', // Ganti dengan logo kabupaten/instansi jika ada
                    fit: BoxFit.contain,
                    errorBuilder: (ctx, err, _) =>
                        const SizedBox(), // Fallback kosong jika tidak ada
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Image.asset(
                      'assets/images/logo_pesona_indonesia.png', // Contoh logo lain
                      fit: BoxFit.contain,
                      errorBuilder: (ctx, err, _) => const SizedBox(),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  // Mengurangi bottom padding agar logo lebih ke bawah
                  titlePadding:
                      const EdgeInsets.only(left: 24, right: 24, bottom: 10),
                  // Background untuk menampung Teks Judul Sistem
                  background: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(30),
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding:
                            const EdgeInsets.only(top: 30, left: 24, right: 24),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.center, // UPDATE: Rata tengah
                          children: [
                            // TEKS SISTEM INFORMASI (DI ATAS LOGO)
                            // 🔥 SISIPAN: Translasi
                            Text(
                              LangHelper.t(
                                  lang,
                                  "SISTEM INFORMASI KEBUDAYAAN LOMBOK BARAT\n(SILORA)",
                                  "SISTEM INFORMASI KEBUDAYAAN LOMBOK BARAT\n(SILORA)",
                                  "WEST LOMBOK CULTURAL INFORMATION SYSTEM\n(SILORA)"),
                              textAlign:
                                  TextAlign.center, // UPDATE: Rata tengah
                              style: TextStyle(
                                fontSize: 16, // UPDATE: Font lebih besar
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                                letterSpacing: 0.5,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Title berisi Logo SIKEBUD
                  title: SafeArea(
                    child: SizedBox(
                      height: 60,
                      child: Align(
                        alignment: Alignment.centerLeft, // Logo rata kiri
                        child: Image.asset(
                          'assets/images/logo_budaya.png',
                          fit: BoxFit.contain, // Agar logo proporsional
                          errorBuilder: (context, error, stackTrace) {
                            return const Text(
                              "Budaya Lobar",
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ---------------- BODY CONTENT ----------------
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.only(bottom: 100),
                  child: Column(
                    children: [
                      // --- SEARCH BAR ---
                      FadeInUp(
                        delay: 0,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 15),
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (value) {
                            },
                            textAlignVertical: TextAlignVertical.center,
                            decoration: InputDecoration(
                              // 🔥 SISIPAN: Translasi
                              hintText: LangHelper.t(
                                  lang,
                                  "Cari situs budaya...",
                                  "Beroq situs budaya...",
                                  "Search cultural sites..."),
                              hintStyle: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              prefixIcon: const Padding(
                                padding: EdgeInsets.only(left: 15, right: 10),
                                child: Icon(Icons.search_rounded,
                                    color: AppColors.primary, size: 24),
                              ),
                              suffixIcon: Container(
                                margin: const EdgeInsets.all(8),
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.tune_rounded,
                                    color: AppColors.primary, size: 18),
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 5),

                      // A. KATEGORI
                      const FadeInUp(delay: 50, child: CategorySection()),

                      const SizedBox(height: 20),

                      // D. LIST SITUS DENGAN SHIMMER LOADING
                      FadeInUp(
                        delay: 150,
                        child: provider.isLoading
                            ? _buildShimmerList()
                            : const SitusSection(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // FITUR: TOMBOL KEMBALI KE ATAS
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          bottom:
              _showBackToTopButton ? 20 : -100, // Sembunyikan di bawah layar
          right: 20,
          child: FloatingActionButton.small(
            onPressed: _scrollToTop,
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.arrow_upward_rounded, color: Colors.white),
          ),
        ),
      ],
    );
  }

  // --- EFEK SHIMMER (LOADING KEREN) ---
  Widget _buildShimmerList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: List.generate(3, (index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            height: 110,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                // Kotak Gambar Abu-abu
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(16)),
                  ),
                ),
                const SizedBox(width: 16),
                // Garis-garis Teks Abu-abu
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          width: 60, height: 10, color: Colors.grey.shade200),
                      const SizedBox(height: 10),
                      Container(
                          width: 150, height: 16, color: Colors.grey.shade200),
                      const SizedBox(height: 10),
                      Container(
                          width: 100, height: 12, color: Colors.grey.shade200),
                    ],
                  ),
                )
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ANIMASI FADE IN UP
class FadeInUp extends StatefulWidget {
  final Widget child;
  final int delay;

  const FadeInUp({super.key, required this.child, required this.delay});

  @override
  State<FadeInUp> createState() => _FadeInUpState();
}

class _FadeInUpState extends State<FadeInUp>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _translate;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutQuad),
    );

    _translate =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutQuad),
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _translate,
        child: widget.child,
      ),
    );
  }
}
