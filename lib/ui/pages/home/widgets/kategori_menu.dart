import 'package:app_kebudyaan_lobar/data/providers/cagar_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../category_result_page.dart';
import '../../../styles/colors.dart';

class CategorySection extends StatelessWidget {
  const CategorySection({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ DATA 10 KATEGORI UTAMA (TIDAK BERUBAH)
    final List<Map<String, dynamic>> categories = [
      {
        "icon": Icons.temple_hindu_rounded,
        "label": "Cagar Budaya",
        "key": "Bangunan",
        "bgColor": const Color(0xFFE3F2FD),
        "iconColor": const Color(0xFF1E88E5),
      },
      {
        "icon": Icons.museum_rounded,
        "label": "Warisan Budaya",
        "key": "Benda",
        "bgColor": const Color(0xFFE8F5E9),
        "iconColor": const Color(0xFF43A047),
      },
      {
        "icon": Icons.menu_book_rounded,
        "label": "Manuskrip Kuno",
        "key": "Manuskrip",
        "bgColor": const Color(0xFFF3E5F5),
        "iconColor": const Color(0xFF8E24AA),
      },
      {
        "icon": Icons.people_alt_rounded,
        "label": "Ritus & Adat",
        "key": "Ritus",
        "bgColor": const Color(0xFFE0F2F1),
        "iconColor": const Color(0xFF00897B),
      },
      {
        "icon": Icons.record_voice_over_rounded,
        "label": "Tradisi Lisan",
        "key": "Tradisi Lisan",
        "bgColor": const Color(0xFFFFF3E0),
        "iconColor": const Color(0xFFFB8C00),
      },
      {
        "icon": Icons.theater_comedy_rounded,
        "label": "Kesenian Lokal",
        "key": "Kesenian",
        "bgColor": const Color(0xFFFCE4EC),
        "iconColor": const Color(0xFFD81B60),
      },
      {
        "icon": Icons.restaurant_menu_rounded,
        "label": "Kuliner Khas",
        "key": "Kuliner",
        "bgColor": const Color(0xFFFFEBEE),
        "iconColor": const Color(0xFFE53935),
      },
      {
        "icon": Icons.handyman_rounded,
        "label": "Teknologi & Kerajinan",
        "key": "Teknologi",
        "bgColor": const Color(0xFFE8EAF6),
        "iconColor": const Color(0xFF3949AB),
      },
      {
        "icon": Icons.translate_rounded,
        "label": "Bahasa Daerah",
        "key": "Bahasa",
        "bgColor": const Color(0xFFFBE9E7),
        "iconColor": const Color(0xFFBF360C),
      },
      {
        "icon": Icons.sports_kabaddi_rounded,
        "label": "Permainan Rakyat",
        "key": "Permainan",
        "bgColor": const Color(0xFFF1F8E9),
        "iconColor": const Color(0xFFAFB42B),
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: categories.asMap().entries.map((entry) {
          int index = entry.key;
          var cat = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 14.0),
            child: _AnimatedCategoryItem(
              index: index,
              icon: cat["icon"],
              label: cat["label"],
              keyNav: cat["key"],
              bgColor: cat["bgColor"],
              iconColor: cat["iconColor"],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ============================================================
// ✅ WIDGET ANIMASI KHUSUS (Fade-In, Slide-Up, & Scale-Tap)
// ============================================================
class _AnimatedCategoryItem extends StatefulWidget {
  final int index;
  final IconData icon;
  final String label;
  final String keyNav;
  final Color bgColor;
  final Color iconColor;

  const _AnimatedCategoryItem({
    required this.index,
    required this.icon,
    required this.label,
    required this.keyNav,
    required this.bgColor,
    required this.iconColor,
  });

  @override
  State<_AnimatedCategoryItem> createState() => _AnimatedCategoryItemState();
}

class _AnimatedCategoryItemState extends State<_AnimatedCategoryItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Efek muncul dari bawah (Slide Up) + Fade In
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    // Menjalankan animasi secara bergantian (Staggered) berdasarkan index
    Future.delayed(Duration(milliseconds: 100 * widget.index), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ✅ FUNGSI FILTER UNTUK MENGHITUNG JUMLAH DATA
  int _getCategoryCount(CagarProvider provider) {
    final allData = provider.listCagar;
    final filterKey = widget.keyNav.toLowerCase().trim();

    return allData.where((item) {
      final dataKat = item.kategori.toLowerCase().trim();

      if (filterKey == 'bangunan') {
        return dataKat.contains('bangunan') ||
               dataKat.contains('struktur') ||
               dataKat.contains('situs') ||
               dataKat.contains('cagar budaya');
      } else if (filterKey == 'benda') {
        return dataKat.contains('benda') || 
               dataKat.contains('warisan budaya');
      } else if (filterKey == 'manuskrip') {
        return dataKat.contains('manuskrip') || 
               dataKat.contains('lontar');
      } else if (filterKey == 'ritus') {
        return dataKat.contains('ritus') || 
               dataKat.contains('upacara adat') || 
               dataKat.contains('adat istiadat');
      } else if (filterKey == 'tradisi lisan') {
        return dataKat.contains('tradisi lisan');
      } else if (filterKey == 'kesenian') {
        return dataKat.contains('seni') || 
               dataKat.contains('kesenian');
      } else if (filterKey == 'kuliner') {
        return dataKat.contains('kuliner') || 
               dataKat.contains('makanan') ||
               dataKat.contains('pengetahuan tradisional');
      } else if (filterKey == 'teknologi') {
        return dataKat.contains('teknologi tradisional') || 
               dataKat.contains('kerajinan');
      } else if (filterKey == 'bahasa') {
        return dataKat.contains('bahasa daerah');
      } else if (filterKey == 'permainan') {
        return dataKat.contains('permainan rakyat');
      }
      return dataKat.contains(filterKey);
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Ambil data provider
    final provider = context.watch<CagarProvider>();
    final int totalData = _getCategoryCount(provider);

    return FadeTransition(
      opacity: _opacityAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: _buildScaleTapItem(context, totalData),
      ),
    );
  }

  // Fungsi untuk membuat efek "ditekan" (Scale Down lalu kembali)
  Widget _buildScaleTapItem(BuildContext context, int totalData) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CategoryResultPage(kategori: widget.keyNav),
          ),
        );
      },
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CategoryResultPage(kategori: widget.keyNav),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: widget.iconColor.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: Colors.white.withOpacity(0.8),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                // Kotak Ikon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: widget.bgColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: widget.iconColor.withOpacity(0.10),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      widget.icon,
                      color: widget.iconColor,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Teks Kategori & Jumlah Data
                Expanded(
                  child: Row( // Ubah dari Column menjadi Row agar teks dan angka sejajar
                    children: [
                      Text(
                        widget.label,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      
                      // ✅ BAGIAN PENAMBAHAN JUMLAH DATA
                      if (totalData > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: widget.iconColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            "$totalData",
                            style: TextStyle(
                              fontSize: 11, 
                              fontWeight: FontWeight.w700, 
                              color: widget.iconColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Panah Estetik
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}