import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/agenda_model.dart';

class AgendaProvider with ChangeNotifier {
  // --- INISIALISASI FIRESTORE ---
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'agenda'; // Nama koleksi di Firebase

  List<AgendaModel> _agendas = [];
  List<AgendaModel> get agendas => _agendas;

  bool _loading = false;
  bool get loading => _loading;

  // 🔥 1. STREAM REAL-TIME (Kunci agar data dari Admin langsung muncul di User)
  // Fungsi ini yang dipanggil oleh StreamBuilder di DetailCagarPage
  Stream<List<AgendaModel>> get agendaStream {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        // Map data dari Firebase ke Model
        return AgendaModel.fromFirestore(doc);
      }).toList();
    });
  }

  // 2. AMBIL DATA MANUAL (Jika diperlukan)
  Future<void> getAgenda() async {
    _loading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('createdAt', descending: true)
          .get();

      _agendas =
          snapshot.docs.map((doc) => AgendaModel.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint("Error mengambil agenda: $e");
      _agendas = [];
    }

    _loading = false;
    notifyListeners();
  }

  // 3. TAMBAH AGENDA (Digunakan Admin)
  Future<bool> addAgenda(AgendaModel agenda) async {
    try {
      await _firestore.collection(_collection).add({
        'bulan': agenda.bulan,
        'waktu': agenda.waktu,
        'createdAt': FieldValue.serverTimestamp(), // Untuk pengurutan terbaru
      });
      return true;
    } catch (e) {
      debugPrint("Gagal tambah agenda ke Firebase: $e");
      return false;
    }
  }

  // 4. UPDATE AGENDA
  Future<bool> updateAgenda(AgendaModel agenda) async {
    try {
      if (agenda.id == null) return false;
      await _firestore.collection(_collection).doc(agenda.id).update({
        'bulan': agenda.bulan,
        'waktu': agenda.waktu,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  // 5. DELETE AGENDA
  Future<bool> deleteAgenda(String id) async {
    // ID diubah jadi String sesuai Firebase
    try {
      await _firestore.collection(_collection).doc(id).delete();
      return true;
    } catch (e) {
      return false;
    }
  }
}
