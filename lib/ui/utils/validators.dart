class Validators {
  static String? required(String? value, {String? message}) {
    if (value == null || value.trim().isEmpty) {
      return message ?? "Field ini wajib diisi";
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.isEmpty) return "Email wajib diisi";

    final regex = RegExp(r"^[^@]+@[^@]+\.[^@]+");
    if (!regex.hasMatch(value)) return "Format email tidak valid";

    return null;
  }

  static String? minLength(String? value, int min) {
    if (value == null || value.length < min) {
      return "Minimal $min karakter";
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.length < 6) {
      return "Password minimal 6 karakter";
    }
    return null;
  }
}
