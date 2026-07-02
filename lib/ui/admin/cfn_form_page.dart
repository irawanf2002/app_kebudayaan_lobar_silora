import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CfnFormPage extends StatefulWidget {
  final String? docId;
  final Map<String, dynamic>? existingData;

  const CfnFormPage({super.key, this.docId, this.existingData});

  @override
  State<CfnFormPage> createState() => _CfnFormPageState();
}

class _CfnFormPageState extends State<CfnFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaArtisCtrl = TextEditingController();
  final _jamCtrl = TextEditingController();
  final _deskripsiCtrl = TextEditingController();

  String _selectedPanggung = "Panggung Utama";
  String _selectedGenre = "Musik Tradisional";
  bool _isLoading = false;

  final List<String> _listPanggung = [
    "Panggung Utama",
    "Panggung Budaya",
    "Area Kuliner",
    "Area Street Art"
  ];

  final List<String> _listGenre = [
    "Musik Tradisional",
    "Musik Modern",
    "Tari",
    "Teater",
    "Atraksi",
    "Lainnya"
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existingData != null) {
      final data = widget.existingData!;
      _namaArtisCtrl.text = data['nama_artis'] ?? '';
      _jamCtrl.text = data['jam_tampil'] ?? '';
      _deskripsiCtrl.text = data['deskripsi'] ?? '';

      if (_listPanggung.contains(data['panggung'])) {
        _selectedPanggung = data['panggung'];
      }
      if (_listGenre.contains(data['genre'])) {
        _selectedGenre = data['genre'];
      }
    }
  }

  Future<void> _saveData() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final payload = {
        'nama_artis': _namaArtisCtrl.text.trim(),
        'panggung': _selectedPanggung,
        'genre': _selectedGenre,
        'jam_tampil': _jamCtrl.text.trim(),
        'deskripsi': _deskripsiCtrl.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      try {
        if (widget.docId == null) {
          payload['createdAt'] = FieldValue.serverTimestamp();
          await FirebaseFirestore.instance
              .collection('cfn_schedules')
              .add(payload);
        } else {
          await FirebaseFirestore.instance
              .collection('cfn_schedules')
              .doc(widget.docId)
              .update(payload);
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Jadwal berhasil disimpan!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.docId != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7), // 🔥 Background abu-abu Web
      appBar: AppBar(
        title: Text(isEdit ? "Edit Jadwal CFN" : "Tambah Jadwal CFN"),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                // 🔥 Batasi lebar agar rapi di monitor PC
                constraints: const BoxConstraints(maxWidth: 700),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "Detail Penampilan CFN",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 24),

                          // NAMA ARTIS
                          _buildTextField(
                              "Nama Grup / Artis", _namaArtisCtrl, Icons.group),
                          const SizedBox(height: 16),

                          // 🔥 BARIS 1: GENRE & PANGGUNG BERSEBELAHAN
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _selectedGenre,
                                  decoration: const InputDecoration(
                                    labelText: "Jenis Penampilan",
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.category,
                                        color: Colors.grey),
                                  ),
                                  items: _listGenre
                                      .map((e) => DropdownMenuItem(
                                          value: e, child: Text(e)))
                                      .toList(),
                                  onChanged: (val) =>
                                      setState(() => _selectedGenre = val!),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _selectedPanggung,
                                  decoration: const InputDecoration(
                                    labelText: "Lokasi Panggung",
                                    border: OutlineInputBorder(),
                                    prefixIcon:
                                        Icon(Icons.place, color: Colors.grey),
                                  ),
                                  items: _listPanggung
                                      .map((e) => DropdownMenuItem(
                                          value: e, child: Text(e)))
                                      .toList(),
                                  onChanged: (val) =>
                                      setState(() => _selectedPanggung = val!),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // JAM TAMPIL
                          _buildTextField("Jam Tampil (Cth: 19:30 - 20:30)",
                              _jamCtrl, Icons.access_time),
                          const SizedBox(height: 16),

                          // DESKRIPSI
                          _buildTextField(
                            "Deskripsi Singkat",
                            _deskripsiCtrl,
                            Icons.description,
                            maxLines: 3,
                            isRequired: false,
                          ),
                          const SizedBox(height: 32),

                          // TOMBOL SIMPAN
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton.icon(
                              onPressed: _isLoading ? null : _saveData,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              icon: const Icon(Icons.save, color: Colors.white),
                              label: Text(
                                isEdit ? "UPDATE JADWAL" : "SIMPAN JADWAL",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
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

          // 🔥 LOADING OVERLAY
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.purple),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController ctrl, IconData icon,
      {int maxLines = 1, bool isRequired = true}) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        alignLabelWithHint: true, // Merapikan label jika maxLines > 1
        prefixIcon: Icon(icon, color: Colors.grey),
      ),
      validator: (val) {
        if (isRequired && (val == null || val.trim().isEmpty)) {
          return "$label tidak boleh kosong";
        }
        return null;
      },
    );
  }
}
