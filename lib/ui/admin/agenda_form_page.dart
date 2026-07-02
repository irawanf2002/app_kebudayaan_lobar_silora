import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AgendaFormPage extends StatefulWidget {
  final String? docId;
  final Map<String, dynamic>? existingData;

  const AgendaFormPage({
    super.key,
    this.docId,
    this.existingData,
  });

  @override
  State<AgendaFormPage> createState() => _AgendaFormPageState();
}

class _AgendaFormPageState extends State<AgendaFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Controller sesuai kebutuhan data SILORA
  final _namaEventCtrl = TextEditingController();
  final _lokasiCtrl = TextEditingController();
  final _penyelenggaraCtrl = TextEditingController();
  final _tanggalCtrl = TextEditingController();

  String _selectedKlasifikasi = "LOKAL";
  bool _isLoading = false;
  DateTime? _selectedDate;

  // 🔥 Warna Premium sesuai Brand SILORA (image_a661dc.png)
  final Color _primaryNavy = const Color(0xFF1E3A8A);
  final Color _accentOrange = const Color(0xFFFF9800);

  @override
  void initState() {
    super.initState();
    if (widget.existingData != null) {
      final data = widget.existingData!;
      _namaEventCtrl.text = data['nama'] ?? '';
      _tanggalCtrl.text = data['tanggal'] ?? ''; // Jika disimpan sebagai String
      _lokasiCtrl.text = data['lokasi'] ?? '';
      _penyelenggaraCtrl.text = data['penyelenggara'] ?? '';
      _selectedKlasifikasi = data['klasifikasi'] ?? "LOKAL";
    }
  }

  @override
  void dispose() {
    _namaEventCtrl.dispose();
    _lokasiCtrl.dispose();
    _penyelenggaraCtrl.dispose();
    _tanggalCtrl.dispose();
    super.dispose();
  }

  String _getIndonesianMonth(int month) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    return months[month - 1];
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: _primaryNavy),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _tanggalCtrl.text =
            "${picked.day} ${_getIndonesianMonth(picked.month)} ${picked.year}";
      });
    }
  }

  Future<void> _saveEvent() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final payload = {
        'nama': _namaEventCtrl.text.trim(),
        'tanggal': _tanggalCtrl.text.trim(),
        'lokasi': _lokasiCtrl.text.trim(),
        'penyelenggara': _penyelenggaraCtrl.text.trim(),
        'klasifikasi': _selectedKlasifikasi,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      try {
        if (widget.docId == null) {
          payload['createdAt'] = FieldValue.serverTimestamp();
          await FirebaseFirestore.instance
              .collection('agenda_events')
              .add(payload);
        } else {
          await FirebaseFirestore.instance
              .collection('agenda_events')
              .doc(widget.docId)
              .update(payload);
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Event Berhasil Disimpan"),
              backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal: $e"), backgroundColor: Colors.red),
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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(isEdit ? "Edit Agenda" : "Tambah Agenda Baru"),
        backgroundColor: _primaryNavy,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 32),
                      _buildTextField(
                          "Nama Event / Agenda", _namaEventCtrl, Icons.event),
                      const SizedBox(height: 16),
                      _buildDatePickerField(),
                      const SizedBox(height: 16),
                      _buildTextField(
                          "Lokasi Pelaksanaan", _lokasiCtrl, Icons.location_on),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                              flex: 3,
                              child: _buildTextField("Penyelenggara",
                                  _penyelenggaraCtrl, Icons.business)),
                          const SizedBox(width: 16),
                          Expanded(flex: 2, child: _buildDropdown()),
                        ],
                      ),
                      const SizedBox(height: 40),
                      _buildSubmitButton(isEdit),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(Icons.library_books, color: _primaryNavy, size: 30),
        const SizedBox(width: 12),
        const Text("Detail Informasi Agenda",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildDatePickerField() {
    return InkWell(
      onTap: _pickDate,
      child: AbsorbPointer(
        child: TextFormField(
          controller: _tanggalCtrl,
          decoration: InputDecoration(
            labelText: "Tanggal Pelaksanaan",
            prefixIcon: const Icon(Icons.calendar_month, color: Colors.blue),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          validator: (v) => v!.isEmpty ? "Pilih tanggal" : null,
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController ctrl, IconData icon) {
    return TextFormField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedKlasifikasi,
      decoration: InputDecoration(
        labelText: "Klasifikasi",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      items: ["LOKAL", "REGIONAL", "NASIONAL", "INTERNASIONAL"]
          .map((v) => DropdownMenuItem(value: v, child: Text(v)))
          .toList(),
      onChanged: (v) => setState(() => _selectedKlasifikasi = v!),
    );
  }

  Widget _buildSubmitButton(bool isEdit) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _saveEvent,
        style: ElevatedButton.styleFrom(
          backgroundColor: _accentOrange,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        icon: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Icon(Icons.cloud_upload, color: Colors.white),
        label: Text(isEdit ? "PERBARUI DATA" : "PUBLIKASIKAN AGENDA",
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
