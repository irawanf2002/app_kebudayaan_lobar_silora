import 'package:flutter/material.dart';
import 'config/theme.dart';
import 'config/routes.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Cagar Budaya Lombok Barat",
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      initialRoute: Routes.splash,
      routes: Routes.getRoutes(),
    );
  }
}
