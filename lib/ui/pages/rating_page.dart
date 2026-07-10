import 'package:app_kebudyaan_lobar/data/providers/comment_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RatingPage extends StatefulWidget {
  final String cagarId;

  const RatingPage({super.key, required this.cagarId});

  @override
  State<RatingPage> createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  int rating = 0;
  bool isLoading = false;

  final TextEditingController controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  // 🔥 UI BINTANG
  Widget _buildStars() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () {
            setState(() => rating = index + 1);
          },
          child: Icon(
            index < rating ? Icons.star : Icons.star_border,
            color: Colors.orange,
            size: 36,
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<CommentProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Beri Ulasan"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              "Bagaimana pengalaman Anda?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            // ⭐ BINTANG
            _buildStars(),

            const SizedBox(height: 20),

            // 📝 INPUT KOMENTAR
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Tulis ulasan Anda...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // 🚀 BUTTON KIRIM
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        if (rating == 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Pilih rating dulu ⭐"),
                            ),
                          );
                          return;
                        }

                        if (controller.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Komentar tidak boleh kosong"),
                            ),
                          );
                          return;
                        }

                        setState(() => isLoading = true);

                        bool success = await provider.addComment(
                          cagarId: widget.cagarId,
                          content: controller.text.trim(),
                          rating: rating,
                          userId: "guest_user",

                          // 🔥 GANTI NANTI DENGAN USER LOGIN
                          userName: "Irawan",
                        );

                        setState(() => isLoading = false);

                        if (success && context.mounted) {
                          Navigator.pop(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Ulasan berhasil dikirim!"),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Gagal mengirim ulasan"),
                            ),
                          );
                        }
                      },
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("KIRIM ULASAN"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
