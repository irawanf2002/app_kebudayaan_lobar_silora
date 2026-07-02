import 'package:flutter/material.dart';
import '../../../styles/colors.dart';

class BeritaSection extends StatelessWidget {
  const BeritaSection({super.key});

  @override
  Widget build(BuildContext context) {
    // Data Dummy Berita
    final List<Map<String, String>> newsList = [
      {
        "title": "Festival Pesona Senggigi 2026 Siap Digelar",
        "date": "07 Feb 2026",
        "image":
            "https://via.placeholder.com/600x300/00AADE/ffffff?text=Festival+Senggigi"
      },
      {
        "title": "Dinas Dikbud Lobar Lestarikan Gendang Beleq",
        "date": "05 Feb 2026",
        "image":
            "https://via.placeholder.com/600x300/D4AF37/ffffff?text=Gendang+Beleq"
      },
      {
        "title": "Peresean: Ajang Adu Ketangkasan Pemuda Sasak",
        "date": "02 Feb 2026",
        "image":
            "https://via.placeholder.com/600x300/8D5B4C/ffffff?text=Peresean"
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Text(
            "Kabar Kebudayaan",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        SizedBox(
          height: 180,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: newsList.length,
            itemBuilder: (context, index) {
              final news = newsList[index];
              return Container(
                width: 300,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: NetworkImage(news['image']!),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.8),
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          news['date']!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        news['title']!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
