import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../data/providers/cagar_provider.dart';
import '../../../../data/models/cagar_model.dart';
import '../../detail_cagar_page.dart';
import '../../../styles/colors.dart';

class SitusSection extends StatefulWidget {
  const SitusSection({super.key});

  @override
  State<SitusSection> createState() => _SitusSectionState();
}

class _SitusSectionState extends State<SitusSection> {
  // Variabel pengontrol: false = sembunyikan (tampil 5), true = tampilkan semua
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CagarProvider>();
    final listCagar = provider.listCagar;

    // Logika pembatasan jumlah item yang dirender
    int itemCount = listCagar.length;
    if (!_isExpanded && listCagar.length > 5) {
      itemCount = 5; // Batasi hanya 5 data pertama
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          if (provider.isLoading) ...[
            const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          ] else if (listCagar.isEmpty) ...[
            const Center(
              child: Text(
                "Belum ada data",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ] else ...[
            // Daftar Situs
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: itemCount,
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) {
                return _buildModernCard(context, listCagar[index]);
              },
            ),

            // --- BAGIAN TOMBOL LIHAT SEMUA YANG TELAH DIPERBARUI ---
            if (listCagar.length > 5) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  // Menggunakan ElevatedButton agar lebih terlihat menonjol
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        AppColors.primary, // Warna utama SILORA Anda
                    foregroundColor: Colors.white, // Warna teks putih
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12), // Sudut yang lebih modern
                    ),
                  ),
                  child: Text(
                    _isExpanded
                        ? "Sembunyikan"
                        : "Lihat Semua Situs", // Teks disederhanakan sesuai permintaan
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),
            ]
          ],
        ],
      ),
    );
  }

  // Desain Card (Tetap mempertahankan tampilan asli Anda)
  Widget _buildModernCard(BuildContext context, CagarModel item) {
    Color categoryColor = AppColors.primary;
    if (item.kategori.contains("Kuliner")) categoryColor = Colors.orangeAccent;
    if (item.kategori.contains("Kesenian"))
      categoryColor = Colors.yellowAccent.shade700;
    if (item.kategori.contains("Warisan")) categoryColor = Colors.purpleAccent;
    if (item.kategori.contains("Situs")) categoryColor = Colors.lightBlueAccent;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DetailCagarPage(cagar: item)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'img-${item.id}-list',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  width: 110,
                  height: 110,
                  child: _buildSmartImage(item.gambarUrl),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item.kategori.toUpperCase(),
                      style: TextStyle(
                          color: categoryColor,
                          fontSize: 9,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8),
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
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item.lokasi,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 40, right: 8),
              child: Icon(Icons.arrow_forward_ios_rounded,
                  size: 16, color: Colors.grey),
            )
          ],
        ),
      ),
    );
  }

  // Logika Gambar (Asset atau URL)
  Widget _buildSmartImage(String url) {
    if (url.isEmpty) return _buildPlaceholder();
    if (url.startsWith('http')) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildAssetImage(url),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              strokeWidth: 2,
            ),
          );
        },
      );
    }
    return _buildAssetImage(url);
  }

  Widget _buildAssetImage(String path) {
    return Image.asset(path,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder());
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 110,
      height: 110,
      color: Colors.grey[200],
      child: const Icon(Icons.image_not_supported_rounded,
          color: Colors.grey, size: 30),
    );
  }
}
