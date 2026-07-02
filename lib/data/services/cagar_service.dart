import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cagar_model.dart';

class CagarService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'cagar_budaya';

  // GET ALL (AMAN UNTUK WEB)
  Future<List<CagarModel>> getAll() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();

      return snapshot.docs.map((doc) => CagarModel.fromFirestore(doc)).toList();
    } catch (e) {
      print("❌ Error CagarService getAll: $e");
      return [];
    }
  }

  // CREATE
  Future<bool> create(CagarModel data) async {
    try {
      await _firestore.collection(_collection).add({
        ...data.toFirestore(),
        'createdAt': Timestamp.now(), // ⬅️ JANGAN serverTimestamp di WEB
      });
      return true;
    } catch (e) {
      print("❌ Error CagarService create: $e");
      return false;
    }
  }

  // UPDATE
  Future<bool> update(CagarModel data) async {
    try {
      if (data.id == null) return false;

      await _firestore
          .collection(_collection)
          .doc(data.id)
          .update(data.toFirestore());

      return true;
    } catch (e) {
      print("❌ Error CagarService update: $e");
      return false;
    }
  }

  // DELETE
  Future<bool> delete(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
      return true;
    } catch (e) {
      print("❌ Error CagarService delete: $e");
      return false;
    }
  }
}
