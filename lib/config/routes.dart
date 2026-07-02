import 'package:flutter/material.dart';
import '../ui/pages/splash_page.dart';
import '../ui/pages/home/home_page.dart';
import '../ui/pages/login_page.dart';
import '../ui/pages/profile_page.dart';
import '../ui/pages/maps_page.dart';

class Routes {
  static const String splash = "/";
  static const String home = "/home";
  static const String login = "/login";
  static const String profile = "/profile";
  static const String maps = "/maps";

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      splash: (_) => const SplashPage(),
      home: (_) => const HomePage(),
      login: (_) => const LoginPage(),
      profile: (_) => const ProfilePage(),
      maps: (_) => const MapsPage(),
    };
  }
}
