import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/cagar_model.dart';
import '../../../data/providers/cagar_provider.dart';

class CagarFormPage extends StatefulWidget {
  final CagarModel? cagar;

  const CagarFormPage({super.key, this.cagar});

  @override
  State<CagarFormPage> createState() => _CagarFormPageState();
}

class _CagarFormPageState extends State<CagarFormPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // 6 Controllers
  late TextEditingController _namaController;
  late TextEditingController _lokasiController;
  late TextEditingController _deskripsiController;
  late TextEditingController _jamController;
  late TextEditingController _tiketController;
  late TextEditingController _gambarUrlController;

  String _selectedKategori = "Benda Cagar Budaya";
  final List<String> _kategoriList = [
    "Benda Cagar Budaya",
    "Bangunan Cagar Budaya",
    "Struktur Cagar Budaya",
    "Situs Cagar Budaya",
    "Kawasan Cagar Budaya",
    "Warisan Budaya Tak Benda",
    "Kuliner",
  ];

  final Color _primaryNavy = const Color(0xFF1E3A8A);
  final Color _bgLightGray = const Color(0xFFF8FAFC);

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.cagar?.nama ?? "");
    _lokasiController = TextEditingController(text: widget.cagar?.lokasi ?? "");
    _deskripsiController =
        TextEditingController(text: widget.cagar?.deskripsi ?? "");
    _jamController = TextEditingController(
        text: widget.cagar?.jamBuka ?? "08:00 - 17:00 WITA");
    _tiketController =
        TextEditingController(text: widget.cagar?.hargaTiket ?? "Gratis");
    _gambarUrlController =
        TextEditingController(text: widget.cagar?.gambarUrl ?? "");

    if (widget.cagar != null &&
        _kategoriList.contains(widget.cagar!.kategori)) {
      _selectedKategori = widget.cagar!.kategori;
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _lokasiController.dispose();
    _deskripsiController.dispose();
    _jamController.dispose();
    _tiketController.dispose();
    _gambarUrlController.dispose();
    super.dispose();
  }

  // =========================================================================
  // FUNGSI PERBAIKAN: SEKARANG BENAR-BENAR MENYIMPAN KE FIREBASE via PROVIDER
  // =========================================================================
  Future<void> _saveData() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      // 1. Membuat objek model dengan parameter lengkap yang sinkron
      final cagar = CagarModel(
        id: widget.cagar?.id,
        nama: _namaController.text.trim(),
        lokasi: _lokasiController.text.trim(),
        deskripsi: _deskripsiController.text.trim(),
        gambarUrl: _gambarUrlController.text.trim(),
        kategori: _selectedKategori,
        jamBuka: _jamController.text.trim(),
        hargaTiket: _tiketController.text.trim(),
        latitude: widget.cagar?.latitude ?? -8.6828,
        longitude: widget.cagar?.longitude ?? 116.1173,
        
        // 🔥 PERBAIKAN 1: Tambahkan status (Default 2 = Terawat jika tambah baru, atau bawa status lama jika edit)
        status: widget.cagar?.status ?? 2, 
      );

      // 🔥 PERBAIKAN 2: Eksekusi penyimpanan ke cloud Firestore memanfaatkan fungsi addCagar di Provider
      // Karena input menggunakan Link URL teks, parameter File image kita beri nilai null.
      await Provider.of<CagarProvider>(context, listen: false).addCagar(cagar, null);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Data Cagar Budaya berhasil disimpan ke database."),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context); // Menutup form dan kembali ke dashboard/list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal menyimpan data: $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLightGray,
      appBar: AppBar(
        title: Text(
            widget.cagar == null ? "Tambah Cagar Budaya" : "Edit Cagar Budaya"),
        backgroundColor: _primaryNavy,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildTextField("Nama Objek", _namaController,
                              icon: Icons.museum),
                          const SizedBox(height: 20),
                          _buildDropdownKategori(),
                          const SizedBox(height: 20),
                          _buildTextField("Alamat/Lokasi", _lokasiController,
                              icon: Icons.location_on),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                  child: _buildTextField(
                                      "Jam Buka", _jamController,
                                      icon: Icons.timer)),
                              const SizedBox(width: 20),
                              Expanded(
                                  child: _buildTextField(
                                      "Harga Tiket", _tiketController,
                                      icon: Icons.payments)),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                              "Link Gambar (URL)", _gambarUrlController,
                              icon: Icons.image),
                          const SizedBox(height: 20),
                          _buildTextField("Deskripsi", _deskripsiController,
                              maxLines: 4),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _saveData,
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: _primaryNavy),
                              child: Text(
                                  _isLoading
                                      ? "Memproses..."
                                      : "SIMPAN DATA KE FIREBASE",
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_isLoading) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black45,
      child:
          const Center(child: CircularProgressIndicator(color: Colors.white)),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {int maxLines = 1, IconData? icon}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
    );
  }

  Widget _buildDropdownKategori() {
    return DropdownButtonFormField<String>(
      value: _selectedKategori,
      decoration: InputDecoration(
          labelText: "Kategori",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
      items: _kategoriList
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: (v) => setState(() => _selectedKategori = v!),
    );
  }
}