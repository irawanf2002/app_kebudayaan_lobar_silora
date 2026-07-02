class ApiConfig {
  // Pastikan URL ini benar. Jika pakai Emulator Android gunakan 10.0.2.2
  // Jika pakai HP fisik, gunakan IP Address laptop (misal 192.168.x.x)
  static const String baseUrl = "https://your-api-url.com/api";

  // --- BAGIAN INI YANG KURANG ---
  // Header wajib agar data terkirim sebagai JSON
  static const Map<String, String> headers = {
    "Content-Type": "application/json",
    "Accept": "application/json",
  };
  // ------------------------------

  // Endpoint URLs
  static String cagar = "$baseUrl/cagar";
  static String agenda = "$baseUrl/agenda";
  static String rating = "$baseUrl/rating";
  static String komentar = "$baseUrl/komentar";
  static String auth = "$baseUrl/auth";
}
