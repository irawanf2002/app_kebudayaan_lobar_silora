import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/providers/auth_provider.dart';
import '../styles/colors.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  // ✅ Tambahkan variabel State untuk mengaktifkan animasi
  bool _startAnimation = false;

  @override
  void initState() {
    super.initState();

    // ✅ Jalankan animasi tepat setelah layar selesai di-render
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _startAnimation = true;
      });
    });

    // Tunggu 3 detik, lalu cek login (sama seperti sebelumnya)
    Future.delayed(const Duration(seconds: 3), () {
      _checkLogin();
    });
  }

  void _checkLogin() {
    final auth = context.read<AuthProvider>();
    if (auth.isLoggedIn) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 1. LOGO (Animasi Fade In & Scale)
            AnimatedOpacity(
              opacity: _startAnimation ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOut,
              child: AnimatedScale(
                scale: _startAnimation ? 1.0 : 0.8,
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutBack, // Efek "bounce" sedikit saat muncul
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
                  ),
                  child: const Icon(Icons.temple_buddhist, size: 60, color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // 2. TEKS UTAMA (Animasi Slide Up / Naik ke atas)
            AnimatedSlide(
              offset: _startAnimation ? Offset.zero : const Offset(0, 0.5),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              child: AnimatedOpacity(
                opacity: _startAnimation ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 800),
                child: Column(
                  children: [
                    Text(
                      "BUDAYA LOBAR",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Jelajahi Warisan Nusantara",
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 60),

            // 3. LOADING INDICATOR (Tetap berputar)
            AnimatedOpacity(
              opacity: _startAnimation ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 800),
              child: const SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}