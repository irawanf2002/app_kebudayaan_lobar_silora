import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // Pastikan sudah install package ini
import '../../config/api_config.dart';
// Sesuaikan jika ada model admin khusus

class AuthService {
  // ----------------------------------------------------
  // ADMIN LOGIN
  // ----------------------------------------------------
  Future<bool> adminLogin(String email, String password) async {
    try {
      // 1. Tentukan URL Endpoint Login Admin (Sesuaikan dengan API Backend Anda)
      // Contoh: /auth/admin-login atau /auth/login (jika endpoint sama dengan user biasa)
      final url = Uri.parse("${ApiConfig.baseUrl}/auth/login");

      final response = await http.post(
        url,
        headers: ApiConfig.headers,
        body: jsonEncode({
          "email": email,
          "password": password,
          // "role": "admin" // Opsional: kirim jika backend butuh pembeda role
        }),
      );

      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // 2. Cek Role (PENTING)
        // Pastikan yang login benar-benar admin, bukan user biasa
        // Sesuaikan key 'role' dengan respons JSON backend Anda
        String role = data['data']['role'] ?? 'user';

        if (role == 'admin') {
          // 3. Simpan Token/Session agar tetap login
          await _saveAdminSession(data['data']);
          return true;
        } else {
          print("Login berhasil tapi bukan Admin");
          return false;
        }
      } else {
        return false;
      }
    } catch (e) {
      print("Error adminLogin: $e");
      return false;
    }
  }

  // ----------------------------------------------------
  // SIMPAN SESSION (SharedPreferences)
  // ----------------------------------------------------
  Future<void> _saveAdminSession(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();

    // Simpan Token
    if (data['token'] != null) {
      await prefs.setString('token', data['token']);
    }

    // Simpan data Admin
    await prefs.setString('user_role', 'admin');
    await prefs.setString('user_name', data['name'] ?? 'Admin');
  }

  // ----------------------------------------------------
  // LOGOUT
  // ----------------------------------------------------
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Hapus semua data session
  }
}
