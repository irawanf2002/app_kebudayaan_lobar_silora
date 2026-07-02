import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoadingList extends StatelessWidget {
  const ShimmerLoadingList({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3, // Tampilkan 3 bayangan kartu
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kotak Gambar
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              const SizedBox(width: 16),
              // Garis-garis Teks
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        width: 80, height: 14, color: Colors.white), // Kategori
                    const SizedBox(height: 10),
                    Container(
                        width: double.infinity,
                        height: 18,
                        color: Colors.white), // Judul
                    const SizedBox(height: 10),
                    Container(
                        width: 150, height: 14, color: Colors.white), // Lokasi
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
