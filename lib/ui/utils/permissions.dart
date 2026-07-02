// 1. Import Dart IO untuk cek Platform (Android/iOS)
import 'dart:io';

// 2. Import device_info_plus (untuk cek versi Android)
import 'package:device_info_plus/device_info_plus.dart';

// 3. Import permission_handler (PENTING: Agar kata 'Permission' tidak error)
import 'package:permission_handler/permission_handler.dart';

class AppPermissions {
  // --- 1. LOKASI (Penting untuk Maps) ---
  static Future<bool> location() async {
    var status = await Permission.location.status;

    if (status.isGranted) return true;

    if (status.isDenied) {
      status = await Permission.location.request();
    }

    if (status.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }

    return status.isGranted;
  }

  // --- 2. NOTIFIKASI ---
  static Future<bool> notification() async {
    var status = await Permission.notification.status;

    if (status.isDenied) {
      status = await Permission.notification.request();
    }

    if (status.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }

    return status.isGranted;
  }

  // --- 3. KAMERA ---
  static Future<bool> camera() async {
    var status = await Permission.camera.status;

    if (status.isDenied) {
      status = await Permission.camera.request();
    }

    if (status.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }

    return status.isGranted;
  }

  // --- 4. GALERI / PENYIMPANAN ---
  static Future<bool> storage() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;

      // Jika Android 13 (SDK 33) ke atas, pakai Permission.photos
      if (androidInfo.version.sdkInt >= 33) {
        var status = await Permission.photos.request();
        if (status.isGranted) return true;

        if (status.isPermanentlyDenied) {
          await openAppSettings();
          return false;
        }
      } else {
        // Jika Android 12 ke bawah, pakai Permission.storage
        var status = await Permission.storage.request();
        if (status.isGranted) return true;

        if (status.isPermanentlyDenied) {
          await openAppSettings();
          return false;
        }
      }
    } else {
      // Untuk iOS
      var status = await Permission.photos.request();
      if (status.isGranted) return true;
    }
    return false;
  }
}
