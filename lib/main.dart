import 'package:app_kebudyaan_lobar/ui/pages/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// File konfigurasi Firebase (Hasil generate FlutterFire CLI)
import 'firebase_options.dart';

// --- STYLES ---
import 'ui/styles/colors.dart';
import 'ui/styles/text_styles.dart';

// --- PROVIDERS (PASTIKAN SEMUA ADA) ---
import 'data/providers/auth_provider.dart';
import 'data/providers/cagar_provider.dart'; 
import 'data/providers/agenda_provider.dart'; 
import 'data/providers/rating_provider.dart';
import 'data/providers/comment_provider.dart'; // Sesuaikan jika ada typo nama file di proyekmu
import 'data/providers/settings_provider.dart';

// --- PAGES ---
import 'ui/pages/splash_page.dart';
import 'ui/pages/login_page.dart';
import 'ui/pages/register_page.dart';
import 'ui/pages/profile_page.dart';
import 'ui/pages/maps_page.dart';
import 'ui/pages/ceo_page.dart';
import 'ui/pages/cfn_page.dart'; 
import 'ui/form_analisis_page.dart'; // PENTING: Import halaman form analisis XGBoost kamu

// --- ADMIN ---
import 'ui/admin/admin_login_page.dart';
import 'ui/admin/dashboard_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inisialisasi Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase gagal diinisialisasi: $e");
  }

  // 2. Format Tanggal Indonesia
  await initializeDateFormatting('id_ID', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 3. MultiProvider: "Pusat Energi" Aplikasi
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CagarProvider()),
        ChangeNotifierProvider(create: (_) => AgendaProvider()),
        ChangeNotifierProvider(create: (_) => RatingProvider()),
        ChangeNotifierProvider(create: (_) => CommentProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return MaterialApp(
            title: 'JELAJAH KEBUDAYAAN',
            debugShowCheckedModeBanner: false,

            // --- LOKALISASI (BAHASA) ---
            locale: settings.currentLocale,
            supportedLocales: const [
              Locale('id', 'ID'), // Bahasa Indonesia
              Locale('en', 'US'), // English
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],

            // --- TEMA ---
            themeMode: settings.themeMode,

            // TEMA TERANG (LIGHT)
            theme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.light,
              colorScheme: const ColorScheme(
                brightness: Brightness.light,
                primary: AppColors.primary,
                onPrimary: Colors.white,
                secondary: AppColors.secondary,
                onSecondary: AppColors.textPrimary,
                error: Color.fromARGB(255, 170, 59, 7),
                onError: Colors.white,
                surface: AppColors.cardSurface,
                onSurface: AppColors.textPrimary,
              ),
              scaffoldBackgroundColor: AppColors.background,
              textTheme: AppTextStyles.mainTextTheme,
              appBarTheme: const AppBarTheme(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                centerTitle: true,
                elevation: 0,
                iconTheme: IconThemeData(color: Colors.white),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: AppColors.inputBg,
                hintStyle: const TextStyle(color: Colors.grey),
                labelStyle: const TextStyle(color: Colors.grey),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.redAccent, width: 1.0),
                ),
              ),
            ),

            // TEMA GELAP (DARK)
            darkTheme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,
              scaffoldBackgroundColor: const Color(0xFF121212),
              primaryColor: AppColors.primary,
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF1F1F1F),
                foregroundColor: Colors.white,
                elevation: 0,
                centerTitle: true,
              ),
              colorScheme: const ColorScheme.dark(
                primary: AppColors.primary,
                secondary: AppColors.secondary,
                surface: Color(0xFF1E1E1E),
                onSurface: Colors.white,
                error: Color(0xFFCF6679),
              ),
              textTheme: AppTextStyles.mainTextTheme.apply(
                bodyColor: Colors.white,
                displayColor: Colors.white,
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: const Color(0xFF2C2C2C),
                hintStyle: TextStyle(color: Colors.grey.shade400),
                labelStyle: TextStyle(color: Colors.grey.shade400),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),

            // --- ROUTES ---
            home: const SplashPage(), // Dikembalikan ke SplashPage bawaan sistem
            routes: {
              '/login': (context) => const LoginPage(),
              '/register': (context) => const RegisterPage(),
              '/home': (context) => const HomePage(),
              '/profile': (context) => const ProfilePage(),
              '/maps': (context) => const MapsPage(),
              '/agenda': (context) => const CoePage(),
              '/cfn': (context) => const CfnPage(),
              '/analisis': (context) => const FormAnalisisPage(), // Ditambahkan route akses form XGBoost kamu
              
              // Admin
              '/admin-login': (context) => const AdminLoginPage(),
              '/admin-dashboard': (context) => const DashboardAdminPage(),
            },
          );
        },
      ),
    );
  }
}