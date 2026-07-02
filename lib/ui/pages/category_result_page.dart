import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/cagar_provider.dart';
import '../../data/models/cagar_model.dart';
import '../styles/colors.dart';
import 'detail_cagar_page.dart';

class CategoryResultPage extends StatelessWidget {
  final String kategori;

  const CategoryResultPage({super.key, required this.kategori});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CagarProvider>();
    final allData = provider.listCagar;

    final filteredList = allData.where((item) {
      final dataKat = item.kategori.toLowerCase();
      final filterKey = kategori.toLowerCase();

      if (filterKey == 'bangunan') {
        return dataKat.contains('bangunan') ||
            dataKat.contains('struktur') ||
            dataKat.contains('situs');
      }
      return dataKat.contains(filterKey);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          _getDisplayTitle(kategori),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: filteredList.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off_rounded,
                      size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 20),
                  Text(
                    "Belum ada data untuk kategori ini",
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                final item = filteredList[index];
                return _buildItemCard(context, item);
              },
            ),
    );
  }

  String _getDisplayTitle(String key) {
    switch (key.toLowerCase()) {
      case 'bangunan':
        return 'Cagar Budaya';
      case 'benda':
        return 'Warisan Budaya Tak Benda';
      case 'kesenian':
        return 'Tarian & Kesenian';
      case 'kuliner':
        return 'Kuliner Khas';
      default:
        return key;
    }
  }

  Widget _buildItemCard(BuildContext context, CagarModel item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DetailCagarPage(cagar: item)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        height: 110,
        decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 15,
                  offset: const Offset(0, 5))
            ]),
        child: Row(
          children: [
            // --- BAGIAN GAMBAR ---
            Hero(
              tag: 'img-${item.id}',
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.horizontal(left: Radius.circular(16)),
                child: SizedBox(
                  width: 110,
                  height: 110,
                  // LOGIKA LANGSUNG (TANPA FUNGSI TAMBAHAN)
                  child: item.gambarUrl.startsWith('http')
                      ? Image.network(
                          item.gambarUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, error, stackTrace) {
                            return Container(
                              color: Colors.grey[200],
                              child: const Icon(Icons.broken_image,
                                  color: Colors.grey),
                            );
                          },
                        )
                      : Image.asset(
                          item.gambarUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, error, stackTrace) {
                            return Container(
                              color: Colors.grey[200],
                              child: const Icon(Icons.image_not_supported,
                                  color: Colors.grey),
                            );
                          },
                        ),
                ),
              ),
            ),

            // --- INFORMASI TEXT ---
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(6)),
                      child: Text(
                        item.kategori.toUpperCase(),
                        style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary),
                      ),
                    ),
                    Text(
                      item.nama,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.textPrimary,
                          height: 1.2),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded,
                            size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.lokasi,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Icon(Icons.arrow_forward_ios_rounded,
                  size: 16, color: Colors.grey),
            )
          ],
        ),
      ),
    );
  }
}
