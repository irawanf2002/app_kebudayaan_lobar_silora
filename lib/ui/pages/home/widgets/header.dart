import 'package:flutter/material.dart';

class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 30),
      decoration: const BoxDecoration(
        color: Color(0xFFE3F2FD), // Biru Muda
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            "Jelajahi Warisan Budaya",
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 5),
          const Text(
            "LOMBOK BARAT",
            style: TextStyle(
              color: Color(0xFF0D47A1), // Biru Tua
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 20),

          // LOGO (Placeholder)
          Container(
            height: 60,
            width: 180,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                image: const DecorationImage(
                  image: NetworkImage(
                      "https://via.placeholder.com/300x100?text=LOGO+BUDAYA"),
                  fit: BoxFit.cover,
                )),
          ),

          const SizedBox(height: 30),

          // SEARCH BAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: "Cari situs...",
                  hintStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Icon(Icons.search, color: Colors.blue),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
