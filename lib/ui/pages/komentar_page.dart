import 'package:app_kebudyaan_lobar/data/providers/comment_provider.dart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
// Pastikan path import ini sesuai dengan struktur folder proyekmu
import '../../data/models/comment_model.dart';

class KomentarPage extends StatefulWidget {
  final String cagarId;

  const KomentarPage({super.key, required this.cagarId});

  @override
  State<KomentarPage> createState() => _KomentarPageState();
}

class _KomentarPageState extends State<KomentarPage> {
  // 🔥 PERBAIKAN: Deklarasikan controller untuk nama dan komentar
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _komentarController = TextEditingController();

  int _selectedRating = 5;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    // Memastikan provider hanya mendengarkan komentar untuk ID cagar ini saja
    Future.microtask(() {
      context.read<CommentProvider>().listenToComments(widget.cagarId);
    });
  }

  @override
  void dispose() {
    _namaController.dispose();
    _komentarController.dispose();
    super.dispose();
  }

  Future<void> _kirimKomentar() async {
    // Validasi agar nama dan komentar tidak kosong
    if (_komentarController.text.trim().isEmpty ||
        _namaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nama dan komentar wajib diisi!")),
      );
      return;
    }

    setState(() => _isSending = true);

    final provider = context.read<CommentProvider>();

    // 🔥 PERBAIKAN: Gunakan variabel lokal ini untuk dikirim ke provider
    String userId = "guest_${DateTime.now().millisecondsSinceEpoch}";
    String userName = _namaController.text.trim();

    bool success = await provider.addComment(
      cagarId: widget.cagarId, // Mengunci ulasan pada ID cagar yang spesifik
      content: _komentarController.text.trim(),
      rating: _selectedRating,
      userId: userId,
      userName: userName,
    );

    if (mounted) setState(() => _isSending = false);

    if (success && mounted) {
      _komentarController.clear();
      // _namaController.clear(); // Biarkan nama terisi jika user ingin komen lagi
      FocusScope.of(context).unfocus();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Matur Tampi Asih! Ulasan Anda telah terkirim."),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal mengirim ulasan")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CommentProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ulasan & Apresiasi"),
      ),
      body: Column(
        children: [
          // Bagian List Komentar
          Expanded(
            child: provider.comments.isEmpty
                ? const Center(child: Text("Belum ada ulasan di lokasi ini."))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.comments.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      return _buildCommentItem(provider.comments[index]);
                    },
                  ),
          ),

          // Bagian Input
          _buildInputSection(),
        ],
      ),
    );
  }

  Widget _buildInputSection() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 10,
        bottom: MediaQuery.of(context).viewInsets.bottom + 10,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(blurRadius: 10, color: Colors.black12),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Input Nama (Wajib agar tidak tercampur "Guest User" semua)
          TextField(
            controller: _namaController,
            decoration: const InputDecoration(
              hintText: "Masukkan Nama Anda...",
              isDense: true,
              border: InputBorder.none,
              icon: Icon(Icons.person_outline, size: 20),
            ),
          ),
          const Divider(),
          // Input Rating Bintang
          Row(
            children: [
              const Text("Rating: "),
              ...List.generate(
                5,
                (i) => GestureDetector(
                  onTap: () => setState(() => _selectedRating = i + 1),
                  child: Icon(
                    i < _selectedRating ? Icons.star : Icons.star_border,
                    color: Colors.orange,
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 8),
          // Input Teks Komentar
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _komentarController,
                  decoration: const InputDecoration(
                    hintText: "Tulis ulasan...",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _isSending
                  ? const CircularProgressIndicator()
                  : IconButton(
                      icon: const Icon(Icons.send, color: Colors.blue),
                      onPressed: _kirimKomentar,
                    )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildCommentItem(CommentModel c) {
    return Card(
      elevation: 0,
      color: Colors.grey[100],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child:
              Text(c.userName.isNotEmpty ? c.userName[0].toUpperCase() : "?"),
        ),
        title: Text(c.userName,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: List.generate(
                5,
                (i) => Icon(
                  i < c.rating ? Icons.star : Icons.star_border,
                  size: 14,
                  color: Colors.orange,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(c.content),
            const SizedBox(height: 4),
            Text(
              DateFormat('dd MMM yyyy HH:mm').format(c.createdAt),
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
