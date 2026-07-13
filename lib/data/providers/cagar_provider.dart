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
  List<CagarModel> _backupListCagar = []; // Backup untuk fitur pencarian
  bool _isLoading = false;
  bool _isFirstLoad = true; // Optimasi agar tidak fetch ulang jika sudah ada

  List<CagarModel> get listCagar => _listCagarUI;
  bool get isLoading => _isLoading;

  // =========================================================================
  // 1. FUNGSI FETCH DATA (GABUNGAN ADMIN + ODCB 2025)
  // =========================================================================
  Future<void> fetchCagar({bool forceRefresh = false}) async {
    // Optimasi: Jika data sudah ada dan bukan panggilan paksa, jangan fetch ulang
    if (!forceRefresh && _listCagarUI.isNotEmpty) {
      return;
    }

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
      _backupListCagar = List.from(_listCagarUI); // Simpan salinan untuk pencarian

      debugPrint("✅ Data Berhasil Dimuat! Total: ${_listCagarUI.length} (Admin: ${adminData.length}, ODCB: ${odcbData.length})");
    } catch (e) {
      debugPrint("❌ Error Fetch Data Cagar: $e");
    }

    _isLoading = false;
    _isFirstLoad = false;
    notifyListeners();
  }

  // =========================================================================
  // 2. FUNGSI UNTUK MENGHITUNG JUMLAH DATA PER KATEGORI (UNTUK UI)
  // =========================================================================
  int getCountByCategory(String filterKey) {
    if (_listCagarUI.isEmpty) return 0;

    return _listCagarUI.where((item) {
      final dataKat = item.kategori.toLowerCase().trim();
      final key = filterKey.toLowerCase().trim();

      // Logika filter yang sama persis dengan CategoryResultPage
      if (key == 'bangunan') {
        return dataKat.contains('bangunan') ||
               dataKat.contains('struktur') ||
               dataKat.contains('situs') ||
               dataKat.contains('cagar budaya');
      } else if (key == 'benda') {
        return dataKat.contains('benda') || 
               dataKat.contains('warisan budaya');
      } else if (key == 'manuskrip') {
        return dataKat.contains('manuskrip') || 
               dataKat.contains('lontar');
      } else if (key == 'ritus') {
        return dataKat.contains('ritus') || 
               dataKat.contains('upacara adat') || 
               dataKat.contains('adat istiadat');
      } else if (key == 'tradisi lisan') {
        return dataKat.contains('tradisi lisan');
      } else if (key == 'kesenian') {
        return dataKat.contains('seni') || 
               dataKat.contains('kesenian');
      } else if (key == 'kuliner') {
        return dataKat.contains('kuliner') || 
               dataKat.contains('makanan') ||
               dataKat.contains('pengetahuan tradisional');
      } else if (key == 'teknologi') {
        return dataKat.contains('teknologi tradisional') || 
               dataKat.contains('kerajinan');
      } else if (key == 'bahasa') {
        return dataKat.contains('bahasa daerah');
      } else if (key == 'permainan') {
        return dataKat.contains('permainan rakyat');
      }
      return dataKat.contains(key);
    }).length;
  }

  // =========================================================================
  // 3. FUNGSI PENCARIAN (UNTUK SEARCH BAR)
  // =========================================================================
  void searchCagar(String query) {
    if (query.trim().isEmpty) {
      // Kembalikan ke data awal
      _listCagarUI = List.from(_backupListCagar);
      notifyListeners();
      return;
    }

    final lowerQuery = query.toLowerCase().trim();
    _listCagarUI = _backupListCagar.where((item) {
      return item.nama.toLowerCase().contains(lowerQuery) ||
             item.kategori.toLowerCase().contains(lowerQuery) ||
             item.lokasi.toLowerCase().contains(lowerQuery);
    }).toList();
    
    notifyListeners();
  }

  // =========================================================================
  // 4. REFRESH DATA (SETELAH PREDIKSI XGBOOST / TAMBAH DATA)
  // =========================================================================
  Future<void> refreshData() async {
    await fetchCagar(forceRefresh: true);
  }

  // =========================================================================
  // 5. STREAM DATA (REALTIME UPDATE - GABUNGAN)
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
  // 6. HELPER: MAPPING DATA ODCB KE CAGAR MODEL
  // =========================================================================
  CagarModel _mapOdcbToCagarModel(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final String nama = data['nama_objek'] ?? 'Tanpa Nama';
    final String kategori = data['kategori_odcb'] ?? 'Cagar Budaya';
    final String kondisi = data['kondisi_aktual'] ?? 'Terawat';
    final double lat = (data['latitude'] ?? 0.0).toDouble();
    final double lng = (data['longitude'] ?? 0.0).toDouble();

    // Tentukan status kode (0, 1, 2) berdasarkan teks kondisi
    // 0: Rusak/Tidak Terawat, 1: Kurang Terawat, 2: Terawat/Berkembang
    int statusCode;
    final kondisiLower = kondisi.toLowerCase();
    if (kondisiLower.contains("terawat") || kondisiLower.contains("berkembang")) {
      statusCode = 2;
    } else if (kondisiLower.contains("kurang")) {
      statusCode = 1;
    } else {
      statusCode = 0;
    }

    return CagarModel(
      id: doc.id,
      nama: nama,
      kategori: kategori, // Dipastikan tersimpan agar filter UI berfungsi
      lokasi: "Lombok Barat",
      status: statusCode,
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
  // 7. FUNGSI ADD / UPDATE DATA (KHUSUS UNTUK ADMIN)
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

      if (cagar.id == null || cagar.id!.isEmpty) {
        data["createdAt"] = FieldValue.serverTimestamp();
        await _firestore.collection(_collectionAdmin).add(data);
      } else {
        data["updatedAt"] = FieldValue.serverTimestamp();
        await _firestore.collection(_collectionAdmin).doc(cagar.id).update(data);
      }

      await refreshData(); // Refresh data setelah add/update
    } catch (e) {
      debugPrint("❌ Error saat menyimpan data cagar: $e");
    }

    _isLoading = false;
    notifyListeners();
  }
}