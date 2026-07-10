import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/cagar_model.dart';
import '../../ui/styles/colors.dart';

class CagarProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Koleksi untuk data admin dan data ODCB
  final String _collectionAdmin = "cagar_budaya";
  final String _collectionOdcb = "odcb_data_2025";

  List<CagarModel> _listCagarUI = [];
  bool _isLoading = false;

  List<CagarModel> get listCagar => _listCagarUI;
  bool get isLoading => _isLoading;

  // =========================================================================
  // 1. FUNGSI FETCH DATA (GABUNGAN ADMIN + ODCB 2025)
  // =========================================================================
  Future<void> fetchCagar() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1a. Ambil data dari koleksi Admin (cagar_budaya)
      final snapshotAdmin = await _firestore.collection(_collectionAdmin).get();
      List<CagarModel> adminData = snapshotAdmin.docs
          .map((doc) => CagarModel.fromFirestore(doc))
          .toList();

      // 1b. Ambil data dari koleksi ODCB 2025 (odcb_data_2025)
      final snapshotOdcb = await _firestore.collection(_collectionOdcb).get();
      List<CagarModel> odcbData = snapshotOdcb.docs
          .map((doc) => _mapOdcbToCagarModel(doc))
          .toList();

      // 1c. Gabungkan kedua list menjadi satu
      _listCagarUI = [...adminData, ...odcbData];

      debugPrint("✅ Data Berhasil Dimuat! Total: ${_listCagarUI.length} (Admin: ${adminData.length}, ODCB: ${odcbData.length})");
    } catch (e) {
      debugPrint("❌ Error Fetch Data Cagar: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  // =========================================================================
  // 2. REFRESH DATA (SETELAH PREDIKSI XGBOOST)
  // =========================================================================
  Future<void> refreshData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshotAdmin = await _firestore.collection(_collectionAdmin).get();
      List<CagarModel> adminData = snapshotAdmin.docs
          .map((doc) => CagarModel.fromFirestore(doc))
          .toList();

      final snapshotOdcb = await _firestore.collection(_collectionOdcb).get();
      List<CagarModel> odcbData = snapshotOdcb.docs
          .map((doc) => _mapOdcbToCagarModel(doc))
          .toList();

      _listCagarUI = [...adminData, ...odcbData];
    } catch (e) {
      debugPrint("❌ Error saat refresh data: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  // =========================================================================
  // 3. STREAM DATA (REALTIME UPDATE - GABUNGAN)
  // =========================================================================
  Stream<List<CagarModel>> get cagarStream {
    return _firestore.collection(_collectionAdmin).snapshots().asyncMap((_) async {
      return await _fetchCombinedData();
    });
  }

  Future<List<CagarModel>> _fetchCombinedData() async {
    final snapshotAdmin = await _firestore.collection(_collectionAdmin).get();
    List<CagarModel> adminData = snapshotAdmin.docs
        .map((doc) => CagarModel.fromFirestore(doc))
        .toList();

    final snapshotOdcb = await _firestore.collection(_collectionOdcb).get();
    List<CagarModel> odcbData = snapshotOdcb.docs
        .map((doc) => _mapOdcbToCagarModel(doc))
        .toList();

    return [...adminData, ...odcbData];
  }

  // =========================================================================
  // 4. HELPER: MAPPING DATA ODCB KE CAGAR MODEL
  // =========================================================================
  CagarModel _mapOdcbToCagarModel(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final String nama = data['nama_objek'] ?? 'Tanpa Nama';
    final String kategori = data['kategori_odcb'] ?? 'Cagar Budaya';
    final String kondisi = data['kondisi_aktual'] ?? 'Terawat';
    final double lat = (data['latitude'] ?? 0.0).toDouble();
    final double lng = (data['longitude'] ?? 0.0).toDouble();

    // Tentukan status kode (0, 1, 2) berdasarkan teks kondisi
    int statusCode;
    if (kondisi.contains("Terawat") || kondisi.contains("Berkembang")) {
      statusCode = 2;
    } else if (kondisi.contains("Kurang")) {
      statusCode = 1;
    } else {
      statusCode = 0;
    }

    return CagarModel(
      id: doc.id,
      nama: nama,
      kategori: kategori,
      lokasi: "Lombok Barat",
      status: statusCode, // Hanya kirim angka status.
      latitude: lat,
      longitude: lng,
      gambarUrl: "https://images.unsplash.com/photo-1590075865003-e48277afd558?w=500",
      images: [],
      deskripsi: "$nama merupakan objek warisan budaya yang tercatat dalam data Pemajuan Kebudayaan Lombok Barat Tahun 2025.",
      hargaTiket: "Gratis",
      jamBuka: "Tersedia 24 Jam",
    );
  }

  // =========================================================================
  // 5. FUNGSI ADD / UPDATE DATA (KHUSUS UNTUK ADMIN)
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
        await _firestore.collection(_collectionAdmin).add(data);
      } else {
        data["updatedAt"] = FieldValue.serverTimestamp();
        await _firestore.collection(_collectionAdmin).doc(cagar.id).update(data);
      }

      await fetchCagar();
    } catch (e) {
      debugPrint("❌ Error saat menyimpan data cagar: $e");
    }

    _isLoading = false;
    notifyListeners();
  }
}