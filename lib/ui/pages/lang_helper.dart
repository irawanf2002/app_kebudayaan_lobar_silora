// File: lib/utils/lang_helper.dart

class LangHelper {
  /// Fungsi [t] (singkatan dari translate/terjemahkan)
  /// Digunakan untuk merubah teks secara dinamis berdasarkan bahasa yang dipilih.
  ///
  /// Parameter:
  /// - [currentLang]: Kode bahasa saat ini ('id', 'sasak', atau 'en')
  /// - [idText]: Teks dalam Bahasa Indonesia (Default)
  /// - [sasakText]: Teks dalam Basa Sasak
  /// - [enText]: Teks dalam Bahasa Inggris
  static String t(
      String currentLang, String idText, String sasakText, String enText) {
    if (currentLang == 'sasak') {
      return sasakText;
    } else if (currentLang == 'en') {
      return enText;
    } else {
      // Default selalu kembali ke Bahasa Indonesia
      return idText;
    }
  }
}
