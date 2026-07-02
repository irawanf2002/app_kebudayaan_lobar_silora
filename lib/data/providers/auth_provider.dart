import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Domain rahasia untuk mengubah NIP jadi Email (User tidak perlu tahu)
  final String _adminDomain = "@admin.lobar";

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn => _auth.currentUser != null;

  // Constructor: Mendengarkan perubahan status user (Login/Logout)
  AuthProvider() {
    _auth.userChanges().listen((user) {
      notifyListeners();
    });
  }

  // ---------------------------------------------------------------------------
  // 1. LOGIN (PAKAI USERNAME/NIP)
  // ---------------------------------------------------------------------------
  Future<bool> login(String username, String password) async {
    try {
      _setLoading(true);

      // Ubah "12345" menjadi "12345@admin.lobar"
      String emailFormat = "$username$_adminDomain";

      await _auth.signInWithEmailAndPassword(
        email: emailFormat,
        password: password,
      );

      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      debugPrint("Login Error: ${e.code}");
      return false;
    } catch (e) {
      _setLoading(false);
      debugPrint("Error Login: $e");
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // 2. REGISTER (PAKAI USERNAME/NIP + FIRESTORE)
  // ---------------------------------------------------------------------------
  Future<bool> register(String username, String password, String nama) async {
    try {
      _setLoading(true);

      // Ubah "12345" menjadi "12345@admin.lobar"
      String emailFormat = "$username$_adminDomain";

      // A. Buat Akun di Firebase Auth
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
          email: emailFormat, password: password);

      // B. Update Nama & Reload (Menggunakan objek credential langsung agar aman)
      if (credential.user != null) {
        // Update nama tampilan di Auth
        await credential.user!.updateDisplayName(nama);

        // Reload user agar nama langsung terbaca oleh aplikasi saat itu juga
        await credential.user!.reload();
      }

      // C. Simpan Data Lengkap ke Firestore
      await _firestore.collection('users').doc(credential.user!.uid).set({
        'uid': credential.user!.uid,
        'nama': nama,
        'username': username, // NIP Asli (Angka)
        'email': emailFormat, // Email Sistem
        'role': 'staf', // Role default
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true,
      });

      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      debugPrint("Register Error: ${e.code}");
      return false;
    } catch (e) {
      _setLoading(false);
      debugPrint("Error Register: $e");
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // 3. LOGOUT
  // ---------------------------------------------------------------------------
  Future<void> logout() async {
    await _auth.signOut();
    notifyListeners();
  }

  // Helper untuk mengubah status loading
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
