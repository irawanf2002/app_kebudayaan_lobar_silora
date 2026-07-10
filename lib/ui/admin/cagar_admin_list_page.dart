import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// 🔥 Pastikan import ini benar sesuai struktur folder kamu
import 'cagar_form_page.dart';
import '../../../data/models/cagar_model.dart';

class CagarAdminListPage extends StatefulWidget {
  const CagarAdminListPage({super.key});

  @override
  State<CagarAdminListPage> createState() => _CagarAdminListPageState();
}

class _CagarAdminListPageState extends State<CagarAdminListPage> {
  final Color _headerBlue = const Color(0xFF2A3470);
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFE0E7FF),
              Color(0xFFF1F5F9),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderControls(context),
              const SizedBox(height: 24),
              Divider(
                color: Colors.blueGrey.withOpacity(0.2),
                thickness: 1.5,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: _buildDataList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Manajemen Cagar Budaya",
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                    letterSpacing: -0.5),
              ),
              const SizedBox(height: 6),
              Text("Kelola seluruh arsip situs dan benda bersejarah",
                  style: TextStyle(color: Color(0xFF475569), fontSize: 14)),
            ],
          ),
          Row(
            children: [
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
                    hintText: "Cari nama situs atau lokasi...",
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
              ElevatedButton.icon(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const CagarFormPage())),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _headerBlue,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 6,
                  shadowColor: _headerBlue.withOpacity(0.5),
                ),
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text("Tambah Arsip",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDataList() {
    return StreamBuilder<QuerySnapshot>(
      // ✅ PERBAIKAN: Hapus orderBy jika kolom belum ada, atau ganti nama kolomnya
      stream: FirebaseFirestore.instance
          .collection('cagar_budaya')
          // .orderBy('createdAt', descending: true) // ⬅️ KOMEN DULU jika belum ada kolom ini
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: _headerBlue));
        }

        // ✅ PERBAIKAN: Tampilkan pesan error jelas
        if (snapshot.hasError) {
          debugPrint("Error Firestore: ${snapshot.error}");
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                const SizedBox(height: 16),
                Text("Terjadi kesalahan: ${snapshot.error}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.redAccent)),
              ],
            ),
          );
        }

        final docs = snapshot.data?.docs ?? [];

        final filteredDocs = docs.where((doc) {
          try {
            final data = doc.data() as Map<String, dynamic>;
            final nama = (data['nama'] ?? '').toString().toLowerCase();
            return nama.contains(_searchQuery);
          } catch (e) {
            return false;
          }
        }).toList();

        if (filteredDocs.isEmpty) {
          return const AnimatedDenseEmptyState();
        }

        return ListView.builder(
          itemCount: filteredDocs.length,
          padding: const EdgeInsets.only(bottom: 40),
          itemBuilder: (context, index) {
            final doc = filteredDocs[index];
            final data = doc.data() as Map<String, dynamic>;

            int delayMs = 100 + (index * 100);
            if (delayMs > 1000) delayMs = 1000;

            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: delayMs),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 30 * (1 - value)),
                  child: Opacity(opacity: value, child: child),
                );
              },
              child: AnimatedHoverCard(
                docId: doc.id,
                data: data,
                onEdit: () {
                  try {
                    final modelCagar = CagarModel(
                      id: doc.id,
                      nama: data['nama']?.toString() ?? '',
                      lokasi: data['lokasi']?.toString() ?? '',
                      deskripsi: data['deskripsi']?.toString() ?? '',
                      gambarUrl: data['gambar_url']?.toString() ?? '',
                      kategori: data['kategori']?.toString() ?? 'Benda Cagar Budaya',
                      jamBuka: data['jamBuka']?.toString() ?? '-',
                      hargaTiket: data['hargaTiket']?.toString() ?? '-',
                    );
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => CagarFormPage(cagar: modelCagar)));
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("❌ Gagal memuat data: $e"), backgroundColor: Colors.red),
                    );
                  }
                },
                onDelete: () => _showDeleteDialog(doc.id, data['nama']?.toString() ?? ''),
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteDialog(String id, String nama) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_rounded, color: Colors.redAccent, size: 28),
            SizedBox(width: 12),
            Text('Hapus Cagar Budaya'),
          ],
        ),
        content: Text('Anda yakin ingin menghapus "$nama"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal',
                  style: TextStyle(color: Colors.blueGrey))),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await FirebaseFirestore.instance
                    .collection('cagar_budaya')
                    .doc(id)
                    .delete();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Arsip berhasil dihapus'),
                      backgroundColor: Colors.green));
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Gagal hapus: $e'),
                      backgroundColor: Colors.red));
                }
              }
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
class AnimatedDenseEmptyState extends StatefulWidget {
  const AnimatedDenseEmptyState({super.key});

  @override
  State<AnimatedDenseEmptyState> createState() =>
      _AnimatedDenseEmptyStateState();
}

class _AnimatedDenseEmptyStateState extends State<AnimatedDenseEmptyState>
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
                          color: const Color(0xFF1E3A8A).withOpacity(0.08),
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
                                  color: Colors.blue.shade50,
                                  shape: BoxShape.circle),
                              child: Icon(Icons.museum_rounded,
                                  size: 64, color: Colors.blue.shade300),
                            ),
                            const SizedBox(height: 24),
                            const Text("Sistem Belum Memiliki Arsip",
                                style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87)),
                            const SizedBox(height: 8),
                            Text(
                                "Data cagar budaya yang Anda tambahkan akan ditampilkan di ruang ini.",
                                style: TextStyle(
                                    color: Colors.blueGrey.shade400,
                                    fontSize: 14)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Opacity(opacity: fadeTop, child: const Divider()),
                    const SizedBox(height: 32),
                    Opacity(
                      opacity: fadeTop,
                      child: const Text("Panduan Menambahkan Arsip Baru:",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black54)),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildAnimatedStep(
                            0.3,
                            Icons.image_search_rounded,
                            "Siapkan Foto",
                            "Siapkan tautan URL\nfoto resolusi tinggi"),
                        _buildAnimatedStep(
                            0.4,
                            Icons.edit_document,
                            "Lengkapi Form",
                            "Isi detail lokasi, sejarah\ndan kategori cagar",
                            isDivider: true),
                        _buildAnimatedStep(
                            0.5,
                            Icons.cloud_done_rounded,
                            "Simpan Data",
                            "Data akan tersinkron\nke aplikasi Mobile",
                            isDivider: true),
                      ],
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

  Widget _buildAnimatedStep(
      double delayStart, IconData icon, String title, String subtitle,
      {bool isDivider = false}) {
    final stepAnim = CurvedAnimation(
            parent: _controller,
            curve: Interval(delayStart, delayStart + 0.4,
                curve: Curves.easeOutCubic))
        .value;
    return Transform.translate(
      offset: Offset(0, 20 * (1 - stepAnim)),
      child: Opacity(
        opacity: stepAnim,
        child: Row(
          children: [
            if (isDivider)
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Container(
                      width: 40, height: 2, color: Colors.grey.shade200)),
            Column(
              children: [
                Icon(icon, color: const Color(0xFF2A3470).withOpacity(0.6), size: 32),
                const SizedBox(height: 12),
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black87)),
                const SizedBox(height: 4),
                Text(subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.blueGrey.shade400,
                        height: 1.4)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================================
class AnimatedHoverCard extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> data;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AnimatedHoverCard(
      {super.key,
      required this.docId,
      required this.data,
      required this.onEdit,
      required this.onDelete});

  @override
  State<AnimatedHoverCard> createState() => _AnimatedHoverCardState();
}

class _AnimatedHoverCardState extends State<AnimatedHoverCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
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
              color: isHovered ? Colors.blue.shade100 : Colors.transparent,
              width: 1.5),
          boxShadow: [
            BoxShadow(
              color:
                  const Color(0xFF1E3A8A).withOpacity(isHovered ? 0.1 : 0.04),
              blurRadius: isHovered ? 30 : 15,
              offset: Offset(0, isHovered ? 12 : 5),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.blueGrey.shade50,
                    border: Border.all(color: Colors.grey.shade200)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    widget.data['gambar_url']?.toString() ?? '',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.museum_outlined,
                      color: Colors.blueGrey.shade300,
                      size: 40,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.data['nama']?.toString() ?? 'Tanpa Nama',
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildCategoryBadge(widget.data['kategori']?.toString() ?? '-'),
                        const SizedBox(width: 16),
                        Icon(Icons.location_on_rounded,
                            size: 16, color: Colors.blueGrey.shade400),
                        const SizedBox(width: 4),
                        Expanded(
                            child: Text(
                          widget.data['lokasi']?.toString() ?? '-',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Colors.blueGrey.shade600, fontSize: 14),
                        )),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.access_time_rounded,
                              size: 16, color: Colors.blueGrey.shade400),
                          const SizedBox(width: 6),
                          Text(
                            widget.data['jamBuka']?.toString() ?? '-',
                            style: TextStyle(
                                color: Colors.blueGrey.shade700,
                                fontSize: 13,
                                fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(width: 20),
                          Icon(Icons.confirmation_number_rounded,
                              size: 16, color: Colors.blueGrey.shade400),
                          const SizedBox(width: 6),
                          Text(
                            widget.data['hargaTiket']?.toString() ?? '-',
                            style: TextStyle(
                                color: Colors.blueGrey.shade700,
                                fontSize: 13,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                      decoration: BoxDecoration(
                          color: Colors.blue.shade50, shape: BoxShape.circle),
                      child: IconButton(
                          icon: const Icon(Icons.edit_note_rounded,
                              color: Colors.blueAccent),
                          tooltip: "Edit Data",
                          onPressed: widget.onEdit)),
                  const SizedBox(height: 12),
                  Container(
                      decoration: BoxDecoration(
                          color: Colors.red.shade50, shape: BoxShape.circle),
                      child: IconButton(
                          icon: const Icon(Icons.delete_outline_rounded,
                              color: Colors.redAccent),
                          tooltip: "Hapus Data",
                          onPressed: widget.onDelete)),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryBadge(String kategori) {
    Color color = Colors.blue;
    final kategoriLower = kategori.toLowerCase();
    if (kategoriLower.contains("benda")) color = Colors.blueGrey;
    if (kategoriLower.contains("situs")) color = Colors.orange;
    if (kategoriLower.contains("struktur")) color = Colors.purple;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8)),
      child: Text(kategori,
          style: TextStyle(
              color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}