import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'agenda_form_page.dart'; // Pastikan path import ini sesuai dengan folder kamu

class AgendaAdminListPage extends StatelessWidget {
  const AgendaAdminListPage({super.key});

  // Warna Tema (Samakan dengan AgendaFormPage agar serasi)
  final Color _primaryBlue = const Color(0xFF1E88E5);
  final Color _accentOrange = const Color(0xFFFF9800);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF0F4F8), // Background abu-abu muda bersih
      appBar: AppBar(
        title: const Text(
          "Manajemen Agenda Event",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.0),
        ),
        backgroundColor: _primaryBlue,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 2,
        actions: [
          // Tombol Tambah di Pojok Kanan Atas
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AgendaFormPage()),
                );
              },
              icon: const Icon(Icons.add_box_rounded, size: 20),
              label: const Text("Tambah Arsip"),
              style: ElevatedButton.styleFrom(
                backgroundColor: _accentOrange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Mengambil data dari koleksi 'agenda_events' di Firestore
        stream: FirebaseFirestore.instance
            .collection('agenda_events')
            .orderBy('tanggal', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Gagal memuat data event."));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.data!.docs.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

              return _buildEventCard(context, doc.id, data);
            },
          );
        },
      ),
    );
  }

  // Widget Tampilan Item Agenda
  Widget _buildEventCard(
      BuildContext context, String docId, Map<String, dynamic> data) {
    // Format Tanggal Sederhana
    DateTime? tgl;
    if (data['tanggal'] is Timestamp) {
      tgl = (data['tanggal'] as Timestamp).toDate();
    }

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon Tanggal
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: _primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today, color: _primaryBlue, size: 20),
                  Text(
                    tgl != null ? "${tgl.day}/${tgl.month}" : "-",
                    style: TextStyle(
                        color: _primaryBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            // Informasi Teks
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['nama'] ?? 'Tanpa Nama Event',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(data['lokasi'] ?? '-',
                          style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
            // Tombol Aksi (Edit & Hapus)
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_note, color: Colors.blueAccent),
                  tooltip: "Edit Event",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AgendaFormPage(
                          docId: docId,
                          existingData: data,
                        ),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon:
                      const Icon(Icons.delete_outline, color: Colors.redAccent),
                  tooltip: "Hapus Event",
                  onPressed: () => _deleteData(context, docId),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text("Belum ada data agenda event masuk.",
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Future<void> _deleteData(BuildContext context, String docId) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi Hapus"),
        content: const Text("Apakah Anda yakin ingin menghapus agenda ini?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Batal")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Hapus", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm) {
      await FirebaseFirestore.instance
          .collection('agenda_events')
          .doc(docId)
          .delete();
    }
  }
}
