import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/auth_provider.dart';
import '../styles/colors.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    // Tunggu 3 detik, lalu cek login
    Future.delayed(const Duration(seconds: 3), () {
      _checkLogin();
    });
  }

  void _checkLogin() {
    // Ambil status login dari Provider (tanpa listen)
    final auth = context.read<AuthProvider>();

    if (auth.isLoggedIn) {
      // Jika sudah login, ke Home
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // Jika belum, ke Login (atau Home sebagai tamu, sesuai keinginan Anda)
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          // Gradient Mewah Hijau ke Emas
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // LOGO (Ganti Icon ini dengan Image.asset jika punya logo png)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: 5)
                  ]),
              child: const Icon(Icons.temple_buddhist,
                  size: 60, color: AppColors.primary),
            ),

            const SizedBox(height: 20),

            const Text(
              "BUDAYA LOBAR",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
              ),
            ),
            const Text(
              "Jelajahi Warisan Nusantara",
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),

            const SizedBox(height: 50),

            // Loading Indicator Putih
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
