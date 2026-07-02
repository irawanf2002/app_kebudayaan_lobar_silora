import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/cagar_model.dart';

class CagarProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final String _collection = "cagar_budaya";

  List<CagarModel> _listCagarUI = [];
  bool _isLoading = false;

  List<CagarModel> get listCagar => _listCagarUI;
  bool get isLoading => _isLoading;

  // =========================================================================
  // 1. FUNGSI FETCH DATA (ONCE GET)
  // =========================================================================
  Future<void> fetchCagar() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore.collection(_collection).get();

      _listCagarUI = snapshot.docs
          .map((doc) => CagarModel.fromFirestore(doc))
          .toList();

      debugPrint("Jumlah Data Berhasil Dimuat: ${_listCagarUI.length}");
    } catch (e) {
      debugPrint("Error Fetch Data Cagar: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  // =========================================================================
  // 2. REFRESH DATA (DIGUNAKAN SETELAH PREDIKSI XGBOOST)
  // =========================================================================
  Future<void> refreshData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore.collection(_collection).get();

      _listCagarUI = snapshot.docs
          .map((doc) => CagarModel.fromFirestore(doc))
          .toList();

      debugPrint("✅ Data berhasil di-refresh (${_listCagarUI.length} data)");
    } catch (e) {
      debugPrint("❌ Error saat refresh data: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  // =========================================================================
  // 3. STREAM DATA (REALTIME UPDATE)
  // =========================================================================
  Stream<List<CagarModel>> get cagarStream {
    return _firestore.collection(_collection).snapshots().map((snapshot) {
      _listCagarUI = snapshot.docs
          .map((e) => CagarModel.fromFirestore(e))
          .toList();

      Future.microtask(() => notifyListeners());
      return _listCagarUI;
    });
  }

  // =========================================================================
  // 4. FUNGSI ADD / UPDATE DATA
  // =========================================================================
  Future<void> addCagar(CagarModel cagar, File? imageFile) async {
    _isLoading = true;
    notifyListeners();

    try {
      String finalImageUrl = cagar.gambarUrl;

      if (imageFile != null) {
        String fileName = "cagar_${DateTime.now().millisecondsSinceEpoch}.jpg";
        Reference ref = _storage.ref().child("uploads").child(fileName);
        Uint8List bytes = await imageFile.readAsBytes();

        UploadTask task = ref.putData(bytes, SettableMetadata(contentType: "image/jpeg"));
        TaskSnapshot snapshot = await task;
        finalImageUrl = await snapshot.ref.getDownloadURL();
      }

      Map<String, dynamic> data = cagar.toFirestore();
      data["gambar_url"] = finalImageUrl;

      if (cagar.id == null) {
        data["createdAt"] = FieldValue.serverTimestamp();
        await _firestore.collection(_collection).add(data);
      } else {
        data["updatedAt"] = FieldValue.serverTimestamp();
        await _firestore.collection(_collection).doc(cagar.id).update(data);
      }

      await fetchCagar();
    } catch (e) {
      debugPrint("Error saat menyimpan data cagar: $e");
    }

    _isLoading = false;
    notifyListeners();
  }
}