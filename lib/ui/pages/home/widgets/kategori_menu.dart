import 'package:flutter/material.dart';
import '../../category_result_page.dart';
import '../../../styles/colors.dart';

class CategorySection extends StatelessWidget {
  const CategorySection({super.key});

  @override
  Widget build(BuildContext context) {
    // Data 4 Kategori Utama asli SILORA
    final List<Map<String, dynamic>> categories = [
      {
        "icon": Icons.temple_hindu_rounded,
        "label": "Cagar\nBudaya",
        "key": "Bangunan",
        "bgColor": const Color(0xFFE3F2FD),
        "iconColor": const Color(0xFF1E88E5),
      },
      {
        "icon": Icons.museum_rounded,
        "label": "Warisan\nBudaya",
        "key": "Benda",
        "bgColor": const Color(0xFFE8F5E9),
        "iconColor": const Color(0xFF43A047),
      },
      {
        "icon": Icons.theater_comedy_rounded,
        "label": "Kesenian\nLokal",
        "key": "Kesenian",
        "bgColor": const Color(0xFFFFF3E0),
        "iconColor": const Color(0xFFFB8C00),
      },
      {
        "icon": Icons.restaurant_menu_rounded,
        "label": "Kuliner\nKhas",
        "key": "Kuliner",
        "bgColor": const Color(0xFFFFEBEE),
        "iconColor": const Color(0xFFE53935),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Judul
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Text(
            "Kategori Utama",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),

        // Menggunakan Padding Utama untuk Row yang Full Lebar Layar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: categories.map((cat) {
              // Buka SingleChildScrollView dihapus, diganti Expanded agar membagi ukuran sama rata dari ujung ke ujung
              return Expanded(
                child: Padding(
                  // Memberi jarak antar item secara proporsional
                  padding: EdgeInsets.only(
                    right: cat == categories.last ? 0 : 10,
                  ),
                  child: _buildItem(
                    context,
                    icon: cat["icon"],
                    label: cat["label"],
                    key: cat["key"],
                    bgColor: cat["bgColor"],
                    iconColor: cat["iconColor"],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // Komponen Reusable Item dengan ukuran yang disesuaikan
  Widget _buildItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String key,
    required Color bgColor,
    required Color iconColor,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CategoryResultPage(kategori: key),
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon Container (Width dibuat double.infinity agar mengikuti lebar Expanded)
          AspectRatio(
            aspectRatio: 1, // Memastikan bentuk kotak sempurna (1:1) walau ukurannya membesar
            child: Container(
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(24), // Squircle style tetap dipertahankan
                boxShadow: [
                  BoxShadow(
                    color: iconColor.withOpacity(0.15),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 34, // Ukuran icon sedikit diperbesar dari 32 ke 34 agar seimbang
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          // Text Label
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}