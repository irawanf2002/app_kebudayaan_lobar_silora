import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/auth_provider.dart';
import '../styles/colors.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _namaController = TextEditingController();
  final _nipController = TextEditingController(); // Ganti email jadi NIP
  final _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isObscure = true;

  @override
  void dispose() {
    _namaController.dispose();
    _nipController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();

      final authProvider = context.read<AuthProvider>();

      // Kirim NIP sebagai username
      final success = await authProvider.register(
        _nipController.text.trim(),
        _passwordController.text.trim(),
        _namaController.text.trim(),
      );

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Registrasi Berhasil! Silakan Login."),
                backgroundColor: Colors.green),
          );
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Registrasi Gagal. NIP mungkin sudah terdaftar."),
                backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Image.asset('assets/images/logo_budaya.png',
                      height: 80, fit: BoxFit.contain),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Daftar Staf Baru",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Gunakan NIP/ID Pegawai untuk mendaftar",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 30),

                // INPUT NAMA
                TextFormField(
                  controller: _namaController,
                  decoration:
                      _inputDecoration("Nama Lengkap", Icons.person_outline),
                  validator: (val) => val!.isEmpty ? "Nama wajib diisi" : null,
                ),
                const SizedBox(height: 16),

                // INPUT NIP (ANGKA SAJA)
                TextFormField(
                  controller: _nipController,
                  keyboardType: TextInputType.number, // Keyboard Angka
                  decoration: _inputDecoration(
                      "NIP / ID Pegawai", Icons.badge_outlined),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "NIP wajib diisi";
                    }
                    // Validasi minimal panjang NIP (opsional)
                    if (value.length < 5) return "NIP terlalu pendek";
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // INPUT PASSWORD
                TextFormField(
                  controller: _passwordController,
                  obscureText: _isObscure,
                  decoration:
                      _inputDecoration("Password", Icons.lock_outline).copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                          _isObscure ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey),
                      onPressed: () => setState(() => _isObscure = !_isObscure),
                    ),
                  ),
                  validator: (val) =>
                      val!.length < 6 ? "Password minimal 6 karakter" : null,
                ),
                const SizedBox(height: 30),

                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("DAFTAR",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Sudah punya akun? "),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text("Login",
                          style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.grey),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.grey.shade50,
    );
  }
}
