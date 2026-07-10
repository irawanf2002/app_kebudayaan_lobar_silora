// lib/ui/pages/komentar_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../data/models/comment_model.dart';
import '../../data/providers/comment_provider.dart';

class KomentarPage extends StatefulWidget {
  final String cagarId;

  const KomentarPage({super.key, required this.cagarId});

  @override
  State<KomentarPage> createState() => _KomentarPageState();
}

class _KomentarPageState extends State<KomentarPage> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _komentarController = TextEditingController();

  int _selectedRating = 5;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    // ✅ Memastikan provider mendengarkan komentar untuk cagar ini
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        context.read<CommentProvider>().listenToComments(widget.cagarId);
      } catch (e) {
        debugPrint("Error loading comments: $e");
      }
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
        const SnackBar(
          content: Text("Nama dan komentar wajib diisi!"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSending = true);

    try {
      final provider = context.read<CommentProvider>();

      String userId = "guest_${DateTime.now().millisecondsSinceEpoch}";
      String userName = _namaController.text.trim();

      bool success = await provider.addComment(
        cagarId: widget.cagarId,
        content: _komentarController.text.trim(),
        rating: _selectedRating,
        userId: userId,
        userName: userName,
      );

      if (mounted) setState(() => _isSending = false);

      if (success && mounted) {
        _komentarController.clear();
        FocusScope.of(context).unfocus();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Matur Tampi Asih! Ulasan Anda telah terkirim."),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("❌ Gagal mengirim ulasan. Coba lagi."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ulasan & Apresiasi"),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<CommentProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // Bagian List Komentar
              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : provider.comments.isEmpty
                        ? const Center(
                            child: Text(
                              "Belum ada ulasan di lokasi ini.",
                              style: TextStyle(fontSize: 16),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: provider.comments.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              return _buildCommentItem(
                                  provider.comments[index]);
                            },
                          ),
              ),

              // Bagian Input
              _buildInputSection(),
            ],
          );
        },
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
          // Input Nama
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
                    size: 28,
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
                  maxLines: 3,
                  minLines: 1,
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
                      icon: const Icon(Icons.send, color: Colors.blue, size: 30),
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
          child: Text(
            c.userName.isNotEmpty ? c.userName[0].toUpperCase() : "?",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          c.userName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rating Bintang
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
            // Isi Komentar
            Text(c.content),
            const SizedBox(height: 4),
            // ✅ PERBAIKAN: Format tanggal (createdAt sudah DateTime)
            Text(
              _formatDate(c.createdAt),
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Method untuk format tanggal
  String _formatDate(DateTime date) {
    try {
      return DateFormat('dd MMM yyyy HH:mm').format(date);
    } catch (e) {
      return "Baru saja";
    }
  }
}