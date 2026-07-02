import 'package:app_kebudyaan_lobar/ui/styles/colors.dart';
import 'package:flutter/material.dart';


class GaleriDinasSection extends StatelessWidget {
  const GaleriDinasSection({super.key});

  @override
  Widget build(BuildContext context) {
    // Menggunakan Asset Gambar Lokal agar tidak error / blank saat offline
    final List<String> images = [
      'assets/images/merumata_even.jpg', // Contoh: Rapat
      'assets/images/pesona_ramadan.jpg', // Contoh: Kunjungan
      'assets/images/lebaran_topat.jpg', // Contoh: Pameran
      'assets/images/taman_narmada.jpg', // Contoh: Edukasi
    ];

    final List<String> captions = [
      "Rapat Koordinasi",
      "Kunjungan Kerja",
      "Festival Budaya",
      "Edukasi Seni"
    ];

    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 20),
      padding: const EdgeInsets.symmetric(vertical: 20),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Dokumentasi Dinas",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      "Dikbud Lombok Barat",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    // Navigasi ke halaman galeri lengkap
                  },
                  child: const Text("Lihat Semua", style: TextStyle(color: AppColors.primary)),
                )
              ],
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 140, // Tinggi disesuaikan untuk gambar + caption
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        images[index],
                        width: 160,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 160,
                            height: 100,
                            color: Colors.grey[200],
                            child: const Icon(Icons.image_not_supported, color: Colors.grey),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text(
                        captions[index],
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}