import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart'; // Perlu untuk debugPrint

class NotificationService {
  // Singleton pattern
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // 1. Setup Android
    // Pastikan icon 'ic_launcher' ada di folder: android/app/src/main/res/mipmap-*
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // 2. Setup iOS
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // 3. Gabungkan Settings
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // 4. Inisialisasi Plugin
    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        debugPrint('Notifikasi diklik: ${details.payload}');
      },
    );

    // 5. MINTA IZIN ANDROID 13+ (PENTING!)
    // Kode ini meminta izin notifikasi pada saat aplikasi pertama dibuka
    final androidImplementation = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }
  }

  Future<void> showNotification(String title, String body, {int id = 0}) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'budaya_channel_id', // ID Channel (harus unik)
      'Info Budaya', // Nama Channel (tampil di setting HP)
      channelDescription: 'Notifikasi seputar kebudayaan',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(id, title, body, platformDetails);
  }
}
