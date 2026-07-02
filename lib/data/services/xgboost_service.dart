import 'dart:convert';
import 'package:http/http.dart' as http;

class XGBoostService {
  // ================== CONFIGURATION ==================
  // Untuk Emulator Android gunakan: 'http://10.0.2.2:5000'
  // Untuk Physical Device gunakan IP laptop Anda (contoh: 'http://192.168.1.100:5000')
  static const String _baseUrl = 'http://10.0.2.2:5000';

  /// Fungsi utama untuk memanggil prediksi XGBoost
  Future<Map<String, dynamic>> predictAll() async {
    final url = Uri.parse('$_baseUrl/predict');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'predict_all': true,        // Flag untuk memprediksi semua data
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'status': 'error',
          'message': errorData['message'] ?? 'Gagal memproses di server.',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Tidak dapat terhubung ke server XGBoost: $e',
      };
    }
  }

  /// (Opsional) Prediksi satu data saja
  Future<Map<String, dynamic>> predictSingle({
    required double usia,
    required int jenisMediaEncoded,
    required double frekuensiPerawatan,
    required double jumlahKunjungan,
    required double tingkatKerentanan,
  }) async {
    final url = Uri.parse('$_baseUrl/predict');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'usia': usia,
          'jenis_media_encoded': jenisMediaEncoded,
          'frekuensi_perawatan': frekuensiPerawatan,
          'jumlah_kunjungan': jumlahKunjungan,
          'tingkat_kerentanan': tingkatKerentanan,
          'predict_all': false,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'status': 'error',
          'message': errorData['message'] ?? 'Gagal memproses data.',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Koneksi gagal: $e',
      };
    }
  }
}