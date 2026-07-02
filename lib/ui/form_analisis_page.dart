import 'package:app_kebudyaan_lobar/data/services/xgboost_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';  // Pastikan path ini benar

class FormAnalisisPage extends StatefulWidget {
  const FormAnalisisPage({super.key});

  @override
  State<FormAnalisisPage> createState() => _FormAnalisisPageState();
}

class _FormAnalisisPageState extends State<FormAnalisisPage> {
  final _formKey = GlobalKey<FormState>();
  final XGBoostService _xgBoostService = XGBoostService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  bool _isGettingLocation = false;

  String _hasilPrediksi = "";
  String _errorMessage = "";
  String _successMessage = "";

  // Controller
  final TextEditingController _namaController = TextEditingController(text: "Puspa Karma Baru");
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lngController = TextEditingController();
  final TextEditingController _usiaController = TextEditingController(text: "150");

  String _selectedKategori = "Bangunan";
  String _selectedEtnis = "Sasak";

  final List<String> _listKategori = ["Bangunan", "Struktur", "Benda", "Kesenian", "Manuskrip"];
  final List<String> _listEtnis = ["Sasak", "Bali", "Jawa", "Lainnya"];

  @override
  void initState() {
    super.initState();
    _ambilKoordinatAsliPerangkat();
  }

  Future<void> _ambilKoordinatAsliPerangkat() async {
    setState(() => _isGettingLocation = true);

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        setState(() {
          _latController.text = position.latitude.toStringAsFixed(6);
          _lngController.text = position.longitude.toStringAsFixed(6);
        });
      }
    } catch (e) {
      // Default koordinat Lombok Barat
      _latController.text = "-8.690401";
      _lngController.text = "116.203282";
    } finally {
      setState(() => _isGettingLocation = false);
    }
  }

  // =====================================================================
  // FUNGSI UTAMA PREDIKSI + SIMPAN
  // =====================================================================
  Future<void> _prosesAnalisisDanSimpan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _hasilPrediksi = "";
      _errorMessage = "";
      _successMessage = "";
    });

    try {
      // Prediksi menggunakan service yang sudah kita update
      final result = await _xgBoostService.predictSingle(
        usia: double.parse(_usiaController.text),
        jenisMediaEncoded: _listKategori.indexOf(_selectedKategori), // simple encoding
        frekuensiPerawatan: 5.0,        // default sementara
        jumlahKunjungan: 1200.0,        // default sementara
        tingkatKerentanan: 3.0,         // default sedang
      );

      if (result['status'] == 'success') {
        String kondisi = result['label'] ?? "Terawat";
        int statusInt = result['prediction'] ?? 2;

        // Simpan ke Firestore
        await _firestore.collection('cagar_budaya').add({
          "nama": _namaController.text.trim(),
          "kategori": _selectedKategori,
          "lokasi": "Lombok Barat - Etnis $_selectedEtnis",
          "latitude": double.parse(_latController.text),
          "longitude": double.parse(_lngController.text),
          "usia": double.parse(_usiaController.text),
          "status": statusInt,
          "statusLabel": kondisi,
          "gambar_url": "https://picsum.photos/id/1015/800/600",
          "createdAt": FieldValue.serverTimestamp(),
        });

        setState(() {
          _hasilPrediksi = kondisi;
          _successMessage = "Berhasil dianalisis dan disimpan!";
        });
      } else {
        setState(() => _errorMessage = result['message']);
      }
    } catch (e) {
      setState(() => _errorMessage = "Terjadi kesalahan: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _usiaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Analisis XGBoost', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Nama Objek
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(labelText: 'Nama Objek', border: OutlineInputBorder()),
                validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              // Kategori
              DropdownButtonFormField<String>(
                value: _selectedKategori,
                decoration: const InputDecoration(labelText: 'Kategori', border: OutlineInputBorder()),
                items: _listKategori.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (val) => setState(() => _selectedKategori = val!),
              ),
              const SizedBox(height: 16),

              // Usia
              TextFormField(
                controller: _usiaController,
                decoration: const InputDecoration(labelText: 'Usia Objek (Tahun)', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              // Lokasi GPS
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latController,
                      decoration: const InputDecoration(labelText: 'Latitude', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _lngController,
                      decoration: const InputDecoration(labelText: 'Longitude', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _isLoading ? null : _prosesAnalisisDanSimpan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Prediksi XGBoost & Simpan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),

              if (_successMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(_successMessage, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                ),

              if (_hasilPrediksi.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text("Hasil Prediksi: $_hasilPrediksi", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal), textAlign: TextAlign.center),
                ),

              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(_errorMessage, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
                ),
            ],
          ),
        ),
      ),
    );
  }
}