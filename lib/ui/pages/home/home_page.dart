import 'package:app_kebudyaan_lobar/data/models/kategori_model.dart';
import 'package:app_kebudyaan_lobar/ui/pages/all_categories_page.dart'; // ✅ Import halaman baru
import 'package:app_kebudyaan_lobar/ui/pages/dikbud_info_page.dart';
import 'package:app_kebudyaan_lobar/ui/pages/lang_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui' as ui;

// PROVIDER
import '../../../data/providers/cagar_provider.dart';
import '../../../data/providers/settings_provider.dart';

// WIDGET PECAHAN
import 'widgets/kategori_menu.dart';
import 'widgets/situs_terbaru_list.dart'; // Jika file ini masih dibutuhkan di tempat lain, biarkan. Tapi tidak dipanggil di kode ini.

// HALAMAN LAIN
import '../ceo_page.dart';
import '../cfn_page.dart';
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
  DateTime? currentBackPressTime;

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
      await [Permission.storage, Permission.photos].request();
    }
  }

  void _onTabSelected(int index) => setState(() => _selectedIndex = index);

  Widget _buildDrawer() {
    final String lang = context.watch<SettingsProvider>().currentLocale.languageCode;
    return Drawer(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            accountName: Text(LangHelper.t(lang, "Pengguna Tamu", "Semeton (Tamu)", "Guest User"), style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            accountEmail: Text(LangHelper.t(lang, "Selamat datang di Budaya Lobar", "Tunas napi leq Budaya Lobar", "Welcome to Lobar Culture"), style: GoogleFonts.poppins()),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Image.asset('assets/images/logo_budaya.png', errorBuilder: (c, e, s) => const Icon(Icons.person, color: AppColors.primary)),
            ),
          ),
          ListTile(
            minLeadingWidth: 20, horizontalTitleGap: 12,
            leading: const Icon(Icons.dashboard_rounded, color: AppColors.primary),
            title: Text(LangHelper.t(lang, 'Beranda', 'Beranda', 'Home'), style: GoogleFonts.poppins()),
            onTap: () { Navigator.pop(context); _onTabSelected(0); },
          ),
          ListTile(
            minLeadingWidth: 20, horizontalTitleGap: 12,
            leading: const Icon(Icons.map_rounded, color: AppColors.primary),
            title: Text(LangHelper.t(lang, 'Peta Wisata', 'Peta Wisata', 'Tourist Map'), style: GoogleFonts.poppins()),
            onTap: () { Navigator.pop(context); _onTabSelected(1); },
          ),
          ListTile(
            minLeadingWidth: 20, horizontalTitleGap: 12,
            leading: const Icon(Icons.info_outline_rounded, color: AppColors.primary),
            title: Text(LangHelper.t(lang, 'Tentang Aplikasi', 'Tentang Aplikasi', 'About App'), style: GoogleFonts.poppins()),
            onTap: () {
              Navigator.pop(context);
              showAboutDialog(
                context: context,
                applicationName: "Budaya Lobar",
                applicationVersion: "1.0.0",
                applicationIcon: Image.asset('assets/images/logo_budaya.png', width: 50, height: 50),
                children: [Text(LangHelper.t(lang, "Aplikasi Jelajah Kebudayaan Lombok Barat...", "Aplikasi Jelajah Kebudayaan Lombok Barat...", "West Lombok Cultural Exploration App..."), style: GoogleFonts.poppins())],
              );
            },
          ),
          
          ListTile(
            minLeadingWidth: 20, horizontalTitleGap: 12,
            leading: const Icon(Icons.account_tree_rounded, color: AppColors.primary),
            title: Text(LangHelper.t(lang, 'Struktur & Info Dinas', 'Struktur & Info Dinas', 'Org Structure & Info'), style: GoogleFonts.poppins()),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const DikbudInfoPage()));
            },
          ),

          const Divider(),
          ListTile(
            minLeadingWidth: 20, horizontalTitleGap: 12,
            leading: const Icon(Icons.logout_rounded, color: Colors.red),
            title: Text(LangHelper.t(lang, 'Keluar', 'Sugul', 'Exit'), style: GoogleFonts.poppins(color: Colors.red)),
            onTap: () => SystemNavigator.pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String lang = context.watch<SettingsProvider>().currentLocale.languageCode;
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        if (_selectedIndex != 0) { setState(() => _selectedIndex = 0); return; }
        final now = DateTime.now();
        if (currentBackPressTime == null || now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
          currentBackPressTime = now;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(LangHelper.t(lang, 'Tekan sekali lagi untuk keluar', 'Tekan sekale malik jari sugul', 'Press once again to exit'), style: GoogleFonts.poppins()), duration: const Duration(seconds: 2)),
          );
          return;
        }
        SystemNavigator.pop();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        drawer: _buildDrawer(),
        extendBody: true,
        body: IndexedStack(index: _selectedIndex, children: _pages),
        bottomNavigationBar: BottomAppBar(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          height: 80, color: Colors.white, elevation: 10,
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            _buildNavItem(0, Icons.dashboard_outlined, Icons.dashboard, LangHelper.t(lang, 'Jelajah', 'Jelajahin', 'Explore')),
            _buildNavItem(1, Icons.map_outlined, Icons.map, LangHelper.t(lang, 'Peta', 'Peta', 'Map')),
            _buildNavItem(2, Icons.calendar_today_outlined, Icons.calendar_month, LangHelper.t(lang, 'Agenda', 'Jadwal', 'Agenda')),
            _buildNavItem(3, Icons.grid_view_outlined, Icons.grid_view, 'CoE CFN'),
            _buildNavItem(4, Icons.person_outline, Icons.person, LangHelper.t(lang, 'Profil', 'Profil', 'Profile')),
          ]),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData iconInactive, IconData iconActive, String label) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onTabSelected(index),
      child: SizedBox(
        width: 65,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              height: 38, width: isSelected ? 58 : 38,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary.withOpacity(0.12) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                  child: Icon(isSelected ? iconActive : iconInactive, key: ValueKey(isSelected), size: 28, color: isSelected ? AppColors.primary : Colors.grey.shade600),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(label, maxLines: 1, style: GoogleFonts.poppins(fontSize: 11, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500, color: isSelected ? AppColors.primary : Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }
}

// ================= PREMIUM CONTENT PAGE =================
Widget _buildGlassCard({required Widget child, Color? color, double opacity = 0.85}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(24),
    child: BackdropFilter(
      filter: ui.ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
      child: Container(
        decoration: BoxDecoration(
          color: (color ?? Colors.white).withValues(alpha: opacity),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: child,
      ),
    ),
  );
}

class HomeContentPage extends StatefulWidget {
  const HomeContentPage({super.key});
  @override
  State<HomeContentPage> createState() => _HomeContentPageState();
}

class _HomeContentPageState extends State<HomeContentPage> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showBackToTopButton = false;

  // ✅ FITUR BARU: Variabel Banner Auto-Scroll & Pulse
  final PageController _bannerController = PageController();
  Timer? _bannerTimer;
  int _currentBannerIndex = 0;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // ✅ Data Banner
  final List<Map<String, String>> _bannerItems = [
    {'title': 'Festival Pesona Senggigi', 'sub': 'November 2026'},
    {'title': 'Perang Topat Lingsar', 'sub': 'November 2026'},
    {'title': 'Jelajah Budaya Lobar', 'sub': 'Temukan Keindahan Nusantara'},
  ];

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

    // Auto-Scroll Banner
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_bannerController.hasClients) {
        int nextPage = _currentBannerIndex + 1;
        if (nextPage >= _bannerItems.length) nextPage = 0;
        _bannerController.animateToPage(nextPage,
            duration: const Duration(milliseconds: 800), curve: Curves.easeInOut);
        setState(() => _currentBannerIndex = nextPage);
      }
    });

    // Pulse Animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _bannerTimer?.cancel();
    _pulseController.dispose();
    _bannerController.dispose();
    super.dispose();
  }

  void _scrollToTop() => _scrollController.animateTo(0, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);

  // ✅ WIDGET CAROUSEL OTOMATIS
  Widget _buildAutoScrollCarousel() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      height: 150,
      child: PageView.builder(
        controller: _bannerController,
        onPageChanged: (index) => setState(() => _currentBannerIndex = index),
        itemCount: _bannerItems.length,
        itemBuilder: (context, index) {
          final item = _bannerItems[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary.withOpacity(0.8), AppColors.primaryDark.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -20, bottom: -20,
                  child: Icon(Icons.museum_outlined, size: 120, color: Colors.white.withOpacity(0.1)),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(item['title']!, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 4),
                      Text(item['sub']!, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                ),
                Positioned(
                  right: 16, bottom: 16,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(_bannerItems.length, (idx) {
                      return Container(
                        margin: const EdgeInsets.only(left: 4),
                        width: _currentBannerIndex == idx ? 16 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: _currentBannerIndex == idx ? Colors.white : Colors.white.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ✅ KATEGORI DENGAN TOMBOL "LIHAT SEMUA" BERFUNGSI
  Widget _buildStaggeredCategorySection() {
    return Column(
      children: [
        // Header Kategori dengan Pulse Animation dan Fungsi Navigasi
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Kategori Utama", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textPrimary)),
              InkWell(
                // ✅ Tombol 'Lihat Semua' sekarang bisa ditekan dan pindah halaman
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AllCategoriesPage()),
                  );
                },
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Text("Lihat Semua", style: GoogleFonts.poppins(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600)),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        // Tampilkan widget Kategori asli Anda
        const CategorySection(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final String lang = context.watch<SettingsProvider>().currentLocale.languageCode;

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () async {},
          color: AppColors.primary,
          backgroundColor: Colors.white,
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // --- HEADER ---
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
                  ),
                  padding: const EdgeInsets.only(top: kIsWeb ? 20 : 0, left: 24, right: 24, bottom: 20),
                  child: SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Jelajah Budaya Lobar",
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.2,
                            shadows: [Shadow(color: Colors.black.withOpacity(0.2), blurRadius: 6, offset: const Offset(0, 4))],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Tunas napi leq jero tamiu",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w300,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Logo di Header
                        Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))],
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Image.asset('assets/images/logo_budaya.png', height: 35, errorBuilder: (c, e, s) => const Icon(Icons.language, color: AppColors.primary)),
                              const SizedBox(width: 10),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "SILORA",
                                    style: GoogleFonts.poppins(
                                      color: AppColors.primary,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1,
                                      height: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "Lombok Barat",
                                    style: GoogleFonts.poppins(
                                      color: Colors.grey.shade500,
                                      fontSize: 10, 
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                      height: 1, 
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // --- BODY CONTENT ---
                Padding(
                  padding: const EdgeInsets.only(bottom: 100), // Memberi ruang untuk BottomNav
                  child: Column(
                    children: [
                      // 1. SEARCH BAR GLASSMORPHISM
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
                        child: _buildGlassCard(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                const Icon(Icons.search_rounded, color: Colors.grey),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    controller: _searchController,
                                    onChanged: (value) {},
                                    style: GoogleFonts.poppins(fontSize: 15),
                                    decoration: InputDecoration(
                                      hintText: LangHelper.t(lang, "Cari situs budaya...", "Beroq situs budaya...", "Search cultural sites..."),
                                      hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 15),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 36, height: 36,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.tune_rounded, color: AppColors.primary, size: 20),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 5),

                      // ✅ 2. BANNER CAROUSEL OTOMATIS
                      _buildAutoScrollCarousel(),

                      // ✅ 3. KATEGORI UTAMA DENGAN STAGGERED & PULSE (Berfungsi)
                      _buildStaggeredCategorySection(),

                      // ❌ BAGIAN INI DIHAPUS (List Situs & Shimmer Loading) 
                      // Sesuai permintaan: "hanya tampilan kategorinya saja ke bawah"
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Back To Top Button
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          bottom: _showBackToTopButton ? 20 : -100,
          right: 20,
          child: FloatingActionButton(
            heroTag: 'back_to_top_home',
            onPressed: _scrollToTop,
            backgroundColor: AppColors.primary,
            shape: const CircleBorder(),
            elevation: 6,
            child: const Icon(Icons.arrow_upward_rounded, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class FadeInUp extends StatefulWidget {
  final Widget child;
  final int delay;
  const FadeInUp({super.key, required this.child, required this.delay});
  @override
  State<FadeInUp> createState() => _FadeInUpState();
}
class _FadeInUpState extends State<FadeInUp> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _translate;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _opacity = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutQuad));
    _translate = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutQuad));
    Future.delayed(Duration(milliseconds: widget.delay), () { if (mounted) _controller.forward(); });
  }
  @override
  void dispose() { _controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _opacity, child: SlideTransition(position: _translate, child: widget.child));
  }
}