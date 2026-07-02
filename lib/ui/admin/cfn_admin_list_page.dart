import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'cfn_form_page.dart';

class CfnAdminListPage extends StatefulWidget {
  const CfnAdminListPage({super.key});

  @override
  State<CfnAdminListPage> createState() => _CfnAdminListPageState();
}

class _CfnAdminListPageState extends State<CfnAdminListPage> {
  // 🔥 TEMA WARNA KHUSUS CFN (Premium Purple)
  final Color _headerPurple = const Color(0xFF4C1D95); // Ungu Gelap Elegan
  final Color _accentPurple = const Color(0xFF7C3AED); // Ungu Cerah
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🔥 Background Transparan agar menyatu dengan gradasi Dashboard
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. HEADER (Judul, Pencarian, Tambah)
            _buildHeaderControls(context),

            const SizedBox(height: 24),
            Divider(color: Colors.blueGrey.withOpacity(0.2), thickness: 1.5),
            const SizedBox(height: 24),

            // 2. AREA KONTEN (Daftar Kartu atau Status Kosong)
            Expanded(
              child: _buildDataList(),
            ),
          ],
        ),
      ),
    );
  }

  // WIDGET: Bagian Atas dengan Animasi Meluncur Turun
  Widget _buildHeaderControls(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, -20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Sisi Kiri: Judul
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Manajemen Jadwal CFN",
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                    letterSpacing: -0.5),
              ),
              const SizedBox(height: 6),
              Text("Kelola penampil, artis, dan panggung Car Free Night",
                  style: TextStyle(color: Color(0xFF475569), fontSize: 14)),
            ],
          ),

          // Sisi Kanan: Kolom Cari & Tombol
          Row(
            children: [
              // Search Bar Putih Melayang
              Container(
                width: 320,
                height: 48,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 15,
                          offset: const Offset(0, 5))
                    ]),
                child: TextField(
                  onChanged: (val) =>
                      setState(() => _searchQuery = val.toLowerCase()),
                  decoration: InputDecoration(
                    hintText: "Cari nama artis atau panggung...",
                    hintStyle: TextStyle(
                        color: Colors.blueGrey.shade300, fontSize: 13),
                    prefixIcon: Icon(Icons.search_rounded,
                        color: Colors.blueGrey.shade400, size: 20),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Tombol Tambah
              ElevatedButton.icon(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const CfnFormPage())),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _headerPurple,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 6,
                  shadowColor: _headerPurple.withOpacity(0.5),
                ),
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text("Tambah Jadwal",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // WIDGET: Aliran Data dari Firestore
  Widget _buildDataList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('cfn_schedules')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: _headerPurple));
        }

        if (snapshot.hasError) {
          return Center(
              child: Text("Terjadi kesalahan sistem",
                  style: TextStyle(color: Colors.red.shade300)));
        }

        final docs = snapshot.data?.docs ?? [];

        // Filter Pencarian
        final filteredDocs = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final nama = (data['nama_artis'] ?? '').toString().toLowerCase();
          final panggung = (data['panggung'] ?? '').toString().toLowerCase();
          return nama.contains(_searchQuery) || panggung.contains(_searchQuery);
        }).toList();

        // 🔥 JIKA DATA KOSONG, TAMPILKAN EMPTY STATE ANIMASI
        if (filteredDocs.isEmpty) {
          return AnimatedCfnEmptyState(headerColor: _headerPurple);
        }

        // 🔥 JIKA ADA DATA, TAMPILKAN LIST KARTU ANIMASI BERURUTAN
        return ListView.builder(
          itemCount: filteredDocs.length,
          padding: const EdgeInsets.only(bottom: 40),
          itemBuilder: (context, index) {
            final doc = filteredDocs[index];
            final data = doc.data() as Map<String, dynamic>;

            // Waktu tunda bertambah untuk setiap item agar muncul berurutan (Staggered)
            int delayMs = 100 + (index * 100);
            if (delayMs > 1000) delayMs = 1000;

            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: delayMs),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.translate(
                  offset:
                      Offset(0, 30 * (1 - value)), // Meluncur halus dari bawah
                  child: Opacity(opacity: value, child: child),
                );
              },
              child: AnimatedCfnHoverCard(
                docId: doc.id,
                data: data,
                accentColor: _accentPurple,
                onEdit: () {
                  // 🔥 AMAN DARI ERROR: CfnFormPage memang meminta docId dan existingData
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => CfnFormPage(
                                docId: doc.id,
                                existingData: data,
                              )));
                },
                onDelete: () => _showDeleteDialog(doc.id, data['nama_artis']),
              ),
            );
          },
        );
      },
    );
  }

  // WIDGET: Dialog Konfirmasi Hapus
  void _showDeleteDialog(String id, String? nama) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_rounded, color: Colors.redAccent, size: 28),
            SizedBox(width: 12),
            Text('Hapus Jadwal CFN'),
          ],
        ),
        content: Text('Anda yakin ingin menghapus penampilan "$nama"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal',
                  style: TextStyle(color: Colors.blueGrey))),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await FirebaseFirestore.instance
                  .collection('cfn_schedules')
                  .doc(id)
                  .delete();
              if (mounted)
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Jadwal berhasil dihapus'),
                    backgroundColor: Colors.redAccent));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child:
                const Text('Ya, Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// 🔥 WIDGET: EMPTY STATE CFN KHUSUS
// =====================================================================
class AnimatedCfnEmptyState extends StatefulWidget {
  final Color headerColor;
  const AnimatedCfnEmptyState({super.key, required this.headerColor});

  @override
  State<AnimatedCfnEmptyState> createState() => _AnimatedCfnEmptyStateState();
}

class _AnimatedCfnEmptyStateState extends State<AnimatedCfnEmptyState>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final scaleVal = CurvedAnimation(
                  parent: _controller,
                  curve: const Interval(0.0, 0.4, curve: Curves.easeOutBack))
              .value;
          final fadeTop = CurvedAnimation(
                  parent: _controller,
                  curve: const Interval(0.2, 0.6, curve: Curves.easeOut))
              .value;

          return Transform.scale(
            scale: 0.95 + (0.05 * scaleVal),
            child: Opacity(
              opacity: scaleVal,
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 800),
                padding:
                    const EdgeInsets.symmetric(vertical: 48, horizontal: 32),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                          color: widget.headerColor.withOpacity(0.08),
                          blurRadius: 40,
                          offset: const Offset(0, 15))
                    ]),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform.translate(
                      offset: Offset(0, 20 * (1 - fadeTop)),
                      child: Opacity(
                        opacity: fadeTop,
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                  color: Colors.purple.shade50,
                                  shape: BoxShape.circle),
                              child: Icon(Icons.nightlife_rounded,
                                  size: 64, color: Colors.purple.shade300),
                            ),
                            const SizedBox(height: 24),
                            const Text("Belum Ada Jadwal CFN",
                                style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87)),
                            const SizedBox(height: 8),
                            Text(
                                "Daftar penampilan artis dan panggung akan muncul di sini.",
                                style: TextStyle(
                                    color: Colors.blueGrey.shade400,
                                    fontSize: 14)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// =====================================================================
// 🔥 WIDGET KHUSUS KARTU DATA CFN (Dengan Efek Melayang Saat Di-Hover)
// =====================================================================
class AnimatedCfnHoverCard extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> data;
  final Color accentColor;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AnimatedCfnHoverCard(
      {super.key,
      required this.docId,
      required this.data,
      required this.accentColor,
      required this.onEdit,
      required this.onDelete});

  @override
  State<AnimatedCfnHoverCard> createState() => _AnimatedCfnHoverCardState();
}

class _AnimatedCfnHoverCardState extends State<AnimatedCfnHoverCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final genre = widget.data['genre'] ?? '-';

    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        margin: EdgeInsets.only(bottom: 20, top: isHovered ? 0 : 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isHovered
                  ? widget.accentColor.withOpacity(0.3)
                  : Colors.transparent,
              width: 1.5),
          boxShadow: [
            BoxShadow(
              color: widget.accentColor.withOpacity(isHovered ? 0.15 : 0.04),
              blurRadius: isHovered ? 30 : 15,
              offset: Offset(0, isHovered ? 12 : 5),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Ikon Genre Keren
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.accentColor.withOpacity(0.1),
                    border:
                        Border.all(color: widget.accentColor.withOpacity(0.2))),
                child: Center(
                  child: Icon(_getIconByGenre(genre),
                      color: widget.accentColor, size: 36),
                ),
              ),
              const SizedBox(width: 24),

              // 2. Info Detail Teks
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.data['nama_artis'] ?? 'Tanpa Nama',
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87)),
                    const SizedBox(height: 8),
                    _buildGenreBadge(genre),
                  ],
                ),
              ),

              // 3. Info Waktu & Panggung
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.access_time_filled_rounded,
                            size: 18, color: Colors.blueGrey.shade400),
                        const SizedBox(width: 8),
                        Text(widget.data['jam_tampil'] ?? '-',
                            style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.stadium_rounded,
                            size: 18, color: Colors.blueGrey.shade400),
                        const SizedBox(width: 8),
                        Text(widget.data['panggung'] ?? '-',
                            style: TextStyle(
                                color: Colors.blueGrey.shade600,
                                fontSize: 14,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 32),

              // 4. Tombol Aksi Kanan
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      decoration: BoxDecoration(
                          color: widget.accentColor.withOpacity(0.1),
                          shape: BoxShape.circle),
                      child: IconButton(
                          icon: Icon(Icons.edit_rounded,
                              color: widget.accentColor),
                          tooltip: "Edit Jadwal",
                          onPressed: widget.onEdit)),
                  const SizedBox(height: 12),
                  Container(
                      decoration: BoxDecoration(
                          color: Colors.red.shade50, shape: BoxShape.circle),
                      child: IconButton(
                          icon: const Icon(Icons.delete_rounded,
                              color: Colors.redAccent),
                          tooltip: "Hapus Jadwal",
                          onPressed: widget.onDelete)),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  // WIDGET HELPER: Label Genre Cantik
  Widget _buildGenreBadge(String genre) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
          color: widget.accentColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: widget.accentColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 3))
          ]),
      child: Text(genre.toUpperCase(),
          style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0)),
    );
  }

  // LOGIKA IKON CFN
  IconData _getIconByGenre(String genre) {
    switch (genre.toLowerCase()) {
      case 'musik tradisional':
        return Icons.queue_music_rounded;
      case 'tari':
        return Icons.accessibility_new_rounded;
      case 'teater':
        return Icons.theater_comedy_rounded;
      case 'akustik':
        return Icons.music_note_rounded;
      case 'band':
        return Icons.speaker_group_rounded;
      default:
        return Icons.mic_rounded;
    }
  }
}
