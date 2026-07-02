import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';

class TambahCagarPage extends StatefulWidget {
  const TambahCagarPage({super.key});

  @override
  State<TambahCagarPage> createState() => _TambahCagarPageState();
}

class _TambahCagarPageState extends State<TambahCagarPage> {
  final _namaController = TextEditingController();
  final _alamatController = TextEditingController(); // Untuk lokasi detail
  final _jamController = TextEditingController(text: '08:00 - 17:00');
  final _hargaController = TextEditingController(text: 'Gratis');
  final _imageUrlController = TextEditingController();
  final _deskripsiController = TextEditingController();

  String selectedKategori = 'Benda Cagar Budaya';
  bool _isLoading = false;

  // 1. Integrasi AI XGBoost (Server Flask)
  Future<int> _dapatkanPrediksiAI(String kategori, String alamat) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.12:5000/predict'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'kategori': kategori, 'alamat': alamat}),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['status'] ?? 0;
      }
    } catch (e) {
      debugPrint("Error AI: $e");
    }
    return 0; // Default status aman jika AI gagal
  }

  // 2. Fungsi Utama Simpan dengan Geocoding
  Future<void> _simpanData() async {
    if (_namaController.text.isEmpty || _alamatController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nama & Alamat wajib diisi!')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Mengubah teks alamat menjadi koordinat unik
      String alamatLengkap = "${_alamatController.text.trim()}, Lombok Barat, NTB";
      List<Location> locations = await locationFromAddress(alamatLengkap);
      
      if (locations.isNotEmpty) {
        double lat = locations.first.latitude;
        double lng = locations.first.longitude;

        // Simpan ke Firestore
        await FirebaseFirestore.instance.collection('cagar_budaya').add({
          'nama': _namaController.text.trim(),
          'alamat': _alamatController.text.trim(),
          'latitude': lat,
          'longitude': lng,
          'kategori': selectedKategori,
          'jamBuka': _jamController.text,
          'hargaTiket': _hargaController.text,
          'gambar_url': _imageUrlController.text.trim(),
          'deskripsi': _deskripsiController.text.trim(),
          'status_risiko': await _dapatkanPrediksiAI(selectedKategori, _alamatController.text),
          'createdAt': FieldValue.serverTimestamp(),
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data & Koordinat berhasil disimpan!')));
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menemukan alamat: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _alamatController.dispose();
    _jamController.dispose();
    _hargaController.dispose();
    _imageUrlController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Cagar Budaya')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _namaController, decoration: const InputDecoration(labelText: 'Nama Situs')),
            TextField(controller: _alamatController, maxLines: 2, decoration: const InputDecoration(labelText: 'Alamat Lengkap (Dusun, RT/RW, Kec, Kab)')),
            DropdownButtonFormField<String>(
              value: selectedKategori,
              items: const [
                DropdownMenuItem(value: 'Benda Cagar Budaya', child: Text('Benda Cagar Budaya')),
                DropdownMenuItem(value: 'Bangunan Cagar Budaya', child: Text('Bangunan Cagar Budaya')),
              ],
              onChanged: (val) => setState(() => selectedKategori = val!),
              decoration: const InputDecoration(labelText: 'Kategori'),
            ),
            TextField(controller: _imageUrlController, decoration: const InputDecoration(labelText: 'Link Gambar')),
            TextField(controller: _deskripsiController, maxLines: 3, decoration: const InputDecoration(labelText: 'Deskripsi')),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _simpanData,
                child: _isLoading ? const CircularProgressIndicator() : const Text('SIMPAN DATA & TENTUKAN LOKASI'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}