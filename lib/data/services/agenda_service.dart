import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/agenda_model.dart';

class AgendaService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'agenda';

  // 1. GET ALL (Mengambil data secara Real-time dari Firebase)
  Future<List<AgendaModel>> getAll() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => AgendaModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print("Error AgendaService getAll: $e");
      return [];
    }
  }

  // 2. CREATE (Menambahkan agenda ke Firebase)
  Future<bool> create(AgendaModel data) async {
    try {
      await _firestore.collection(_collection).add({
        ...data
            .toFirestore(), // Menggunakan toFirestore() sesuai standar Firebase
        'createdAt': FieldValue.serverTimestamp(), // Untuk pengurutan otomatis
      });
      return true;
    } catch (e) {
      print("Error AgendaService create: $e");
      return false;
    }
  }

  // 3. UPDATE (Memperbarui data berdasarkan ID unik Firebase)
  Future<bool> update(AgendaModel data) async {
    try {
      if (data.id == null) return false;

      await _firestore.collection(_collection).doc(data.id).update(
            data.toFirestore(),
          );
      return true;
    } catch (e) {
      print("Error AgendaService update: $e");
      return false;
    }
  }

  // 4. DELETE (Menghapus agenda)
  // Perhatian: ID diubah dari 'int' ke 'String' karena Firebase menggunakan ID teks
  Future<bool> delete(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
      return true;
    } catch (e) {
      print("Error AgendaService delete: $e");
      return false;
    }
  }
}
