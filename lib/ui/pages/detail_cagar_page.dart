import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:ui';
import 'dart:async';
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

// ✅ IMPORT YANG BENAR
import '../../data/models/cagar_model.dart';
import '../../data/models/agenda_model.dart';
import '../../data/models/comment_model.dart';
import 'maps_page.dart';
import 'komentar_page.dart';
import '../../data/providers/comment_provider.dart';
import '../../data/providers/agenda_provider.dart';
import '../../ui/styles/colors.dart';

class DetailCagarPage extends StatefulWidget {
  final CagarModel cagar;

  const DetailCagarPage({super.key, required this.cagar});

  @override
  State<DetailCagarPage> createState() => _DetailCagarPageState();
}

class _DetailCagarPageState extends State<DetailCagarPage>
    with TickerProviderStateMixin {
  bool _isTextExpanded = false;
  int _userRating = 0;
  bool _isFavorited = false;

  // State Bahasa Chat (Default: Indo)
  String _chatLanguage = 'indo';

  late ScrollController _scrollController;
  bool _isScrolled = false;

  final TextEditingController _chatController = TextEditingController();

  // --- TEXT TO SPEECH (TTS) ---
  late FlutterTts _flutterTts;
  bool _isVoiceEnabled = false;
  String _ttsState = "stopped";

  // --- SPEECH TO TEXT (STT) ---
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _sttAvailable = false;

  late List<Map<String, String>> _chatMessages;
  bool _isTyping = false;

  // --- AI VIDEO STORYTELLER STATE ---
  bool _isAiStoryPlaying = false;
  int _currentSlideIndex = 0;
  Timer? _slideTimer;
  List<String> _storyImages = [];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.offset > 250 && !_isScrolled) {
        setState(() => _isScrolled = true);
      } else if (_scrollController.offset <= 250 && _isScrolled) {
        setState(() => _isScrolled = false);
      }
    });

    _storyImages = [widget.cagar.gambarUrl, ...widget.cagar.images];

    _initTts();
    _initStt();
    _resetChat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshComments();
      
      // ✅ PERBAIKAN LOGIN: Otomatis login anonim saat halaman dibuka agar bisa kirim ulasan tanpa registrasi
      _ensureAnonymousLogin();
    });
  }

  // --- PERBAIKAN: Login anonim otomatis untuk memastikan pengguna tamu bisa menulis ulasan ---
  Future<void> _ensureAnonymousLogin() async {
    try {
      // Cek apakah sudah ada user login
      if (FirebaseAuth.instance.currentUser == null) {
        await FirebaseAuth.instance.signInAnonymously();
        debugPrint("✅ Login anonim otomatis berhasil");
      }
    } catch (e) {
      debugPrint("⚠️ Gagal login anonim: $e");
    }
  }

  // --- METODE LOGIKA ---

  Future<void> _initTts() async {
    _flutterTts = FlutterTts();
    try {
      await _flutterTts.setLanguage("id-ID");
      await _flutterTts.setSpeechRate(0.85);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      _flutterTts.setCompletionHandler(() {
        if (_isAiStoryPlaying) {
          _stopAiStoryteller();
        }
      });
    } catch (e) {
      debugPrint("TTS Error: $e");
    }
  }

  // --- LOGIKA AI STORYTELLER ---
  void _toggleAiStoryteller() {
    if (_isAiStoryPlaying) {
      _stopAiStoryteller();
    } else {
      _startAiStoryteller();
    }
  }

  Future<void> _startAiStoryteller() async {
    if (_isVoiceEnabled) setState(() => _isVoiceEnabled = false);
    await _flutterTts.stop();

    setState(() {
      _isAiStoryPlaying = true;
      _currentSlideIndex = 0;
    });

    await _flutterTts.speak(widget.cagar.deskripsi);

    _slideTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;
      setState(() {
        _currentSlideIndex = (_currentSlideIndex + 1) % _storyImages.length;
      });
    });
  }

  Future<void> _stopAiStoryteller() async {
    await _flutterTts.stop();
    _slideTimer?.cancel();
    if (mounted) {
      setState(() {
        _isAiStoryPlaying = false;
        _currentSlideIndex = 0;
      });
    }
  }

  void _initStt() async {
    _speech = stt.SpeechToText();
    try {
      _sttAvailable = await _speech.initialize(
        onError: (val) => debugPrint('STT Error: $val'),
        onStatus: (val) {
          if (val == 'done' || val == 'notListening') {
            if (mounted && _isListening) setState(() => _isListening = false);
          }
        },
      );
    } catch (e) {
      _sttAvailable = false;
    }
    if (mounted) setState(() {});
  }

  void _listen() async {
    if (!_isListening && _sttAvailable) {
      await _flutterTts.stop();
      _stopAiStoryteller();
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (val) {
          if (!mounted) return;
          setState(() {
            _chatController.text = val.recognizedWords;
            if (_chatController.text.isNotEmpty) {
              _chatController.selection = TextSelection.fromPosition(
                  TextPosition(offset: _chatController.text.length));
            }
          });

          if (val.finalResult) {
            setState(() => _isListening = false);
            if (_chatController.text.trim().isNotEmpty) {
              _sendChatMessage(_chatController.text, isVoiceInput: true);
            }
          }
        },
        localeId: 'id_ID',
      );
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  Future<void> _speak(String text) async {
    if (!_isVoiceEnabled) return;
    if (_isAiStoryPlaying) return;

    await _flutterTts.stop();
    if (text.isNotEmpty) {
      await _flutterTts.speak(text.replaceAll("\n", " "));
    }
  }

  void _resetChat() {
    String greeting = _chatLanguage == 'sasak'
        ? "Tabeq! Tiang Pemandu Budaya (AI). Silaq metakon seputar budaya."
        : "Halo! Saya Pemandu Budaya (AI). Silakan tanya apapun seputar budaya.";
    setState(() {
      _chatMessages = [
        {'role': 'system', 'message': greeting}
      ];
    });
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) _speak(greeting);
    });
  }

  void _refreshComments() {
    final String currentId = widget.cagar.id.toString();
    context.read<CommentProvider>().listenToComments(currentId);
  }

  Future<void> _openComments() async {
    final String cagarId = widget.cagar.id.toString();

    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => KomentarPage(cagarId: cagarId)));

    _refreshComments();
  }

  // --- PERBAIKAN: Fungsi Submit Rating dengan Login Anonim ---
  void _submitRating(int initialRating) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Beri Ulasan", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("⭐ $initialRating Bintang", style: GoogleFonts.poppins()),
            const SizedBox(height: 15),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                  labelText: "Nama Anda", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: commentController,
              maxLines: 2,
              decoration: const InputDecoration(
                  labelText: "Komentar", border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Batal", style: GoogleFonts.poppins())),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Mohon isi nama Anda")),
                );
                return;
              }

              if (commentController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Mohon isi komentar")),
                );
                return;
              }

              final String currentId = widget.cagar.id.toString();

              // ✅ AMANKAN: Pastikan login anonim sudah berjalan sebelum mengirim
              User? currentUser = FirebaseAuth.instance.currentUser;
              if (currentUser == null) {
                try {
                  UserCredential userCredential = await FirebaseAuth.instance.signInAnonymously();
                  currentUser = userCredential.user;
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Koneksi terputus. Pastikan internet Anda aktif.")),
                    );
                  }
                  return;
                }
              }

              // ✅ Kirim userId asli dari Firebase agar aturan keamanan `request.auth != null` lulus
              bool success = await context.read<CommentProvider>().addComment(
                    cagarId: currentId,
                    content: commentController.text.trim(),
                    rating: initialRating,
                    userId: currentUser!.uid,
                    userName: nameController.text.trim(),
                  );

              if (success && mounted) {
                Navigator.pop(context);
                _refreshComments();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("✅ Ulasan berhasil dikirim!")),
                );
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("❌ Gagal mengirim ulasan. Coba lagi.")),
                );
              }
            },
            child: Text("Kirim", style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  Future<String> _generateCulturalAIResponse(String query) async {
    String lowerQuery = query.toLowerCase();

    if (lowerQuery.contains("tiket") || lowerQuery.contains("harga")) {
      return "Harga tiket masuk adalah ${widget.cagar.hargaTiket}.";
    }
    if (lowerQuery.contains("jam") || lowerQuery.contains("buka")) {
      return "Kami buka pukul ${widget.cagar.jamBuka}.";
    }
    if (lowerQuery.contains("sejarah") || lowerQuery.contains("cerita")) {
      return "Berikut sejarah singkatnya: ${widget.cagar.deskripsi}";
    }

    return _chatLanguage == 'sasak'
        ? "Ampure, tiang ndek man paham. Cobe takon soal tiket atau sejarah."
        : "Maaf, saya kurang mengerti. Coba tanya soal tiket, jam buka, atau sejarah.";
  }

  void _sendChatMessage(String text, {bool isVoiceInput = false}) async {
    if (text.trim().isEmpty) return;
    _flutterTts.stop();
    if (_isAiStoryPlaying) _stopAiStoryteller();

    setState(() {
      _chatMessages.add({'role': 'user', 'message': text});
      _isTyping = true;
    });
    _chatController.clear();
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    String finalResponse = await _generateCulturalAIResponse(text);
    setState(() {
      _isTyping = false;
      _chatMessages.add({'role': 'system', 'message': finalResponse});
    });
    if (isVoiceInput) setState(() => _isVoiceEnabled = true);
    if (_isVoiceEnabled) _speak(finalResponse);
  }

  void _openInternalMap() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const MapsPage()));
  }

  void _showReviewInputSheet({int initialRating = 0}) {
    int currentInputRating = initialRating > 0 ? initialRating : 5;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(builder: (context, setModalState) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 30),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24))
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2)
                  )
                ),
                Text(
                  "Tulis Apresiasi",
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary
                  )
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    5,
                    (index) => GestureDetector(
                      onTap: () => setModalState(() => currentInputRating = index + 1),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Icon(
                          index < currentInputRating
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: AppColors.rating,
                          size: 42
                        )
                      )
                    )
                  )
                ),
                const SizedBox(height: 30),
                TextField(
                  maxLines: 4,
                  maxLength: 500,
                  decoration: InputDecoration(
                    hintText: "Berembe pendapat side?",
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none
                    )
                  )
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _submitRating(currentInputRating);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)
                      )
                    ),
                    child: Text(
                      "Kirim Apresiasi",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 16
                      )
                    )
                  )
                )
              ]
            )
          )
        );
      })
    );
  }

  void _showShareOptions() {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
            height: 200,
            decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
            child: const Center(child: Text("Menu Share"))));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _chatController.dispose();
    _flutterTts.stop();
    _speech.stop();
    _slideTimer?.cancel();
    super.dispose();
  }

  // --- UI BUILDER METHODS ---

  Widget _buildImageProvider(String url, {double? width, double? height}) {
    if (url.startsWith('http') || url.startsWith('https')) {
      return Image.network(
        url,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (c, e, s) => Container(
          width: width,
          height: height,
          color: AppColors.divider,
          child: const Center(child: Icon(Icons.image_outlined, size: 30, color: Colors.grey)),
        ),
      );
    } else {
      return Image.asset(
        url,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (c, e, s) =>
            Image.asset('assets/images/placeholder.jpg', fit: BoxFit.cover),
      );
    }
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 340,
      pinned: true,
      backgroundColor: AppColors.background,
      elevation: 0,
      title: _isScrolled
          ? Text(widget.cagar.nama,
              style: GoogleFonts.poppins(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18))
          : null,
      centerTitle: true,
      leading: Center(
          child: _buildCircleBtn(
              Icons.arrow_back_ios_new_rounded, () => Navigator.pop(context),
              forceDark: _isScrolled)),
      actions: [
        Row(mainAxisSize: MainAxisSize.min, children: [
          _buildCircleBtn(
              _isFavorited ? Icons.favorite : Icons.favorite_border_rounded,
              () => setState(() => _isFavorited = !_isFavorited),
              color: _isFavorited ? Colors.redAccent : null,
              forceDark: _isScrolled),
          const SizedBox(width: 8),
          _buildCircleBtn(Icons.share_rounded, _showShareOptions,
              forceDark: _isScrolled),
          const SizedBox(width: 16),
        ]),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(fit: StackFit.expand, children: [
          Hero(
              tag: 'img-${widget.cagar.id}',
              child: _buildImageProvider(widget.cagar.gambarUrl)),
          Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
            Colors.black.withOpacity(0.5),
            Colors.transparent,
            AppColors.primary.withOpacity(0.2)
          ], begin: Alignment.bottomCenter, end: Alignment.topCenter))),
        ]),
      ),
    );
  }

  // ✅ PERUBAHAN BOTTOM BAR: Jam Operasional & Tombol Beri Ulasan
  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        boxShadow: [
          BoxShadow(
              color: AppColors.textPrimary.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -5))
        ]
      ),
      child: SafeArea(
        child: Row(children: [
          Expanded(
              flex: 4,
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Jam Operasional",
                        style: GoogleFonts.poppins(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500)),
                    const SizedBox(height: 2),
                    Text(widget.cagar.jamBuka,
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                            color: AppColors.primary))
                  ])),
          Expanded(
              flex: 5,
              child: ElevatedButton.icon(
                  onPressed: _showReviewInputSheet,
                  icon: const Icon(Icons.star_rounded, size: 20),
                  label: Text("Beri Ulasan", style: GoogleFonts.poppins()),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 2))),
        ]),
      ),
    );
  }

  Widget _buildHeaderTitle() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border:
                    Border.all(color: AppColors.primary.withOpacity(0.2))),
            child: Text(widget.cagar.kategori.toUpperCase(),
                style: GoogleFonts.poppins(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                    letterSpacing: 1.2))),
        const Spacer(),
        const Icon(Icons.star, color: AppColors.rating, size: 18),
        const SizedBox(width: 4),
        Text("4.8",
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                fontSize: 16)),
        Consumer<CommentProvider>(builder: (context, provider, _) {
          return Text(" (${provider.comments.length})",
              style: GoogleFonts.poppins(
                  color: AppColors.textSecondary, fontSize: 12));
        }),
      ]),
      const SizedBox(height: 16),
      Text(widget.cagar.nama,
          style: GoogleFonts.poppins(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              height: 1.1,
              color: AppColors.textPrimary)),
      const SizedBox(height: 12),
      Row(children: [
        const Icon(Icons.location_on, color: AppColors.primary, size: 18),
        const SizedBox(width: 6),
        Expanded(
            child: Text(widget.cagar.lokasi,
                style: GoogleFonts.poppins(
                    color: AppColors.textSecondary, fontSize: 14)))
      ]),
    ]);
  }

  Widget _buildEtikaCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          image: const DecorationImage(
              image: NetworkImage(
                  "https://www.transparenttextures.com/patterns/batik.png"),
              opacity: 0.05,
              fit: BoxFit.cover),
          gradient: LinearGradient(colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8)
          ], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8))
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.tips_and_updates_outlined, color: Colors.white),
            const SizedBox(width: 10),
            Text("Etika & Tata Krame",
                style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16))
          ]),
          const SizedBox(height: 16),
          Text("• Silaq bekelambi sak sopan (Berpakaian sopan).",
              style: GoogleFonts.poppins(color: Colors.white, height: 1.5)),
          Text("• Ndak naek ojok bangunan (Dilarang memanjat).",
              style: GoogleFonts.poppins(color: Colors.white, height: 1.5)),
          Text("• Jage kebersihan tetu niki (Jaga kebersihan).",
              style: GoogleFonts.poppins(color: Colors.white, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildSectionDivider() {
    return Padding(
        padding: const EdgeInsets.only(bottom: 24.0),
        child: Center(
            child: Container(
                width: 60,
                height: 3,
                decoration: BoxDecoration(
                    color: AppColors.rating.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(1.5)))));
  }

  Widget _buildTags() {
    final tags = ["#CagarBudaya", "#Sejarah", "#Edukasi", "#Arsitektur"];
    return Wrap(
        spacing: 8,
        children: tags
            .map((tag) => Chip(
                label: Text(tag,
                    style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500)),
                backgroundColor: AppColors.background,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(color: Colors.transparent)),
                padding: const EdgeInsets.all(0),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap))
            .toList());
  }

  Widget _buildInfoRow() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
                color: AppColors.textPrimary.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 5))
          ]),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        _buildInfoItem(
            Icons.access_time, "Jam Operasional", widget.cagar.jamBuka),
        Container(
            width: 1,
            height: 30,
            color: AppColors.primary.withOpacity(0.2)),
        _buildInfoItem(Icons.wb_sunny_outlined, "Waktu Terbaik", "Pagi Hari"),
        Container(
            width: 1,
            height: 30,
            color: AppColors.primary.withOpacity(0.2)),
        _buildInfoItem(Icons.confirmation_number_outlined, "Tiket Masuk",
            widget.cagar.hargaTiket)
      ]),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Expanded(
        child: Column(children: [
      Icon(icon, color: AppColors.primary, size: 24),
      const SizedBox(height: 8),
      Text(label,
          style: GoogleFonts.poppins(
              fontSize: 10,
              color: AppColors.textSecondary,
              letterSpacing: 0.5)),
      const SizedBox(height: 4),
      Text(value,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: AppColors.textPrimary))
    ]));
  }

  Widget _buildDescription() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      AnimatedSize(
          duration: const Duration(milliseconds: 400),
          alignment: Alignment.topCenter,
          curve: Curves.easeInOut,
          child: Text(widget.cagar.deskripsi,
              maxLines: _isTextExpanded ? null : 6,
              overflow: _isTextExpanded
                  ? TextOverflow.visible
                  : TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                  fontSize: 16,
                  height: 1.8,
                  color: AppColors.textSecondary),
              textAlign: TextAlign.justify)),
      GestureDetector(
          onTap: () => setState(() => _isTextExpanded = !_isTextExpanded),
          child: Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(_isTextExpanded ? "Lipat Kembali" : "Baca Kisah Lengkap",
                    style: GoogleFonts.poppins(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5)),
                const SizedBox(width: 6),
                Icon(
                    _isTextExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 18,
                    color: AppColors.primary)
              ]))),
    ]);
  }

  Widget _buildChatSection() {
    return Container(
      height: 400,
      decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withOpacity(0.1))),
      child: Column(children: [
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                border: const Border(bottom: BorderSide(color: AppColors.divider))),
            child: Row(children: [
              CircleAvatar(
                  backgroundColor: AppColors.primary,
                  radius: 18,
                  child: const Icon(Icons.history_edu_rounded,
                      size: 20, color: Colors.white)),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text("Pemandu Budaya",
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppColors.textPrimary)),
                    Text("Pilih bahasa percakapan",
                        style: GoogleFonts.poppins(
                            color: AppColors.textSecondary, fontSize: 10))
                  ])),
              Container(
                  height: 32,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: AppColors.primary.withOpacity(0.2))),
                  child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                          value: _chatLanguage,
                          icon: Icon(Icons.keyboard_arrow_down,
                              size: 16, color: AppColors.primary),
                          style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _chatLanguage = newValue;
                              });
                              _resetChat();
                            }
                          },
                          items: const [
                        DropdownMenuItem(
                            value: 'indo', child: Text("Indonesia")),
                        DropdownMenuItem(value: 'sasak', child: Text("Sasak"))
                      ]))),
              const SizedBox(width: 8),
              IconButton(
                  icon: Icon(
                      _isVoiceEnabled
                          ? Icons.volume_up_rounded
                          : Icons.volume_off_rounded,
                      color: _isVoiceEnabled
                          ? AppColors.primary
                          : Colors.grey,
                      size: 20),
                  tooltip: _isVoiceEnabled ? "Matikan Suara" : "Aktifkan Suara",
                  onPressed: () {
                    setState(() => _isVoiceEnabled = !_isVoiceEnabled);
                    if (!_isVoiceEnabled) _flutterTts.stop();
                  }),
              IconButton(
                  icon: const Icon(Icons.refresh_rounded,
                      color: AppColors.textSecondary, size: 20),
                  onPressed: _resetChat)
            ])),
        Expanded(
            child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _chatMessages.length + (_isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _chatMessages.length)
                    return _buildTypingIndicator();
                  final msg = _chatMessages[index];
                  final isUser = msg['role'] == 'user';
                  return Align(
                      alignment:
                          isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.75),
                          decoration: BoxDecoration(
                              color: isUser
                                  ? AppColors.primary
                                  : AppColors.cardSurface,
                              borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(16),
                                  topRight: const Radius.circular(16),
                                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                                  bottomRight:
                                      Radius.circular(isUser ? 4 : 16)),
                              boxShadow: [
                                BoxShadow(
                                    color: AppColors.textPrimary
                                        .withOpacity(0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2))
                              ]),
                          child: Text(msg['message']!,
                              style: GoogleFonts.poppins(
                                  color: isUser
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                  fontSize: 13,
                                  height: 1.5))));
                })),
        Container(
            height: 40,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildQuickAskChip("Tiket masuk?"),
                  _buildQuickAskChip("Sejarah tempat ini?"),
                  _buildQuickAskChip("Apa itu Peresean?"),
                  _buildQuickAskChip("Kuliner khas?")
                ])),
        Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(20))),
            child: Row(children: [
              Expanded(
                  child: Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                              color: AppColors.primary.withOpacity(0.1))),
                      child: Row(children: [
                        Expanded(
                            child: TextField(
                                controller: _chatController,
                                style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: AppColors.textPrimary),
                                decoration: InputDecoration(
                                    hintText: _chatLanguage == 'sasak'
                                        ? "Kirim pitakon..."
                                        : (_isListening
                                            ? "Mendengarkan..."
                                            : "Tanya tentang budaya..."),
                                    hintStyle: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: _isListening
                                            ? AppColors.primary
                                            : Colors.grey),
                                    border: InputBorder.none,
                                    contentPadding:
                                        const EdgeInsets.only(bottom: 8)),
                                onSubmitted: (value) =>
                                    _sendChatMessage(value))),
                        GestureDetector(
                            onTap: _listen,
                            child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _isListening
                                        ? Colors.redAccent.withOpacity(0.1)
                                        : Colors.transparent),
                                child: Icon(
                                    _isListening
                                        ? Icons.mic_rounded
                                        : Icons.mic_none_rounded,
                                    size: 20,
                                    color: _isListening
                                        ? Colors.redAccent
                                        : Colors.grey)))
                      ]))),
              const SizedBox(width: 8),
              CircleAvatar(
                  backgroundColor: AppColors.primary,
                  radius: 22,
                  child: IconButton(
                      icon: const Icon(Icons.send_rounded,
                          color: Colors.white, size: 20),
                      onPressed: () => _sendChatMessage(_chatController.text)))
            ]))
      ]),
    );
  }

  Widget _buildQuickAskChip(String text) {
    return GestureDetector(
        onTap: () => _sendChatMessage(text),
        child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(20),
                border:
                    Border.all(color: AppColors.rating.withOpacity(0.5))),
            child: Text(text,
                style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600))));
  }

  Widget _buildTypingIndicator() {
    return Align(
        alignment: Alignment.centerLeft,
        child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                    bottomLeft: Radius.circular(4)),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.textPrimary.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2))
                ]),
            child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                    3,
                    (index) => Container(
                        width: 6,
                        height: 6,
                        margin: EdgeInsets.only(right: index < 2 ? 4 : 0),
                        decoration: const BoxDecoration(
                            color: AppColors.textSecondary,
                            shape: BoxShape.circle))))));
  }

  // ✅ GALERI VISUAL, AI STORYTELLER, DAN LOKASI SITUS TELAH DIHAPUS

  Widget _buildReviewSection() {
    return Consumer<CommentProvider>(builder: (context, provider, child) {
      final comments = provider.comments;
      final totalApresiasi = comments.length;

      double rataRata = 0.0;
      if (totalApresiasi > 0) {
        final totalBintang =
            comments.fold<double>(0, (sum, item) => sum + (item.rating ?? 5));
        rataRata = totalBintang / totalApresiasi;
      }

      Map<int, int> starCount = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};

      for (var c in comments) {
        int rating = (c.rating ?? 5).clamp(1, 5);
        starCount[rating] = (starCount[rating] ?? 0) + 1;
      }

      double getPercent(int star) {
        if (totalApresiasi == 0) return 0;
        return (starCount[star]! / totalApresiasi);
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Ulasan & Rating / Reviews",
                  style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary)),
              if (totalApresiasi > 0)
                GestureDetector(
                    onTap: _openComments,
                    child: const Icon(Icons.arrow_forward,
                        color: AppColors.primary))
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          totalApresiasi == 0
                              ? "0.0"
                              : rataRata.toStringAsFixed(1),
                          style: GoogleFonts.poppins(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              height: 1,
                              color: AppColors.textPrimary),
                        ),
                        Text("/5.0",
                            style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < rataRata.floor()
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: AppColors.rating,
                          size: 18,
                        );
                      }),
                    ),
                    const SizedBox(height: 4),
                    Text("$totalApresiasi ulasan / reviews",
                        style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.textSecondary.withOpacity(0.8))),
                  ],
                ),
              ),
              if (totalApresiasi > 0)
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      _buildBar(5, getPercent(5)),
                      _buildBar(4, getPercent(4)),
                      _buildBar(3, getPercent(3)),
                      _buildBar(2, getPercent(2)),
                      _buildBar(1, getPercent(1)),
                    ],
                  ),
                )
            ],
          ),
          const SizedBox(height: 30),
          Text("Ceritakan pengalaman di sini / Share your experience",
              style: GoogleFonts.poppins(
                  color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () => _showReviewInputSheet(initialRating: index + 1),
                child: Icon(
                  index < _userRating
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  size: 40,
                  color: index < _userRating
                      ? AppColors.rating
                      : Colors.grey.shade300,
                ),
              );
            }),
          ),
          const SizedBox(height: 30),
          if (comments.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(16)),
              child: Center(
                child: Text(
                    "Belum ada ulasan. Jadilah yang pertama!\n(No reviews yet. Be the first!)",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic)),
              ),
            )
          else
            Column(
              children: comments
                  .take(3)
                  .map((comment) => _buildReviewItem(comment))
                  .toList(),
            ),
          if (totalApresiasi > 0)
            Center(
              child: TextButton(
                onPressed: _openComments,
                style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary),
                child: Text("Lihat semua ulasan / See all reviews", style: GoogleFonts.poppins()),
              ),
            )
        ],
      );
    });
  }

  Widget _buildBar(int star, double val) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(children: [
          SizedBox(
              width: 12,
              child: Text("$star",
                  style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary))),
          const SizedBox(width: 8),
          Expanded(
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                      value: val,
                      backgroundColor: Colors.grey.shade200,
                      color: AppColors.rating,
                      minHeight: 6)))
        ]));
  }

  Widget _buildReviewItem(CommentModel comment) {
    return Container(
        margin: const EdgeInsets.only(bottom: 24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            CircleAvatar(
                radius: 18,
                backgroundColor: _getColorFromname(comment.userName),
                child: Text(
                    comment.userName.isNotEmpty
                        ? comment.userName[0].toUpperCase()
                        : 'A',
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold))),
            const SizedBox(width: 12),
            Text(comment.userName,
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.textPrimary)),
            const Spacer(),
            const Icon(Icons.more_vert, size: 18, color: Colors.grey)
          ]),
          const SizedBox(height: 6),
          Row(children: [
            Row(
                children: List.generate(
                    comment.rating ?? 5,
                    (i) => const Icon(Icons.star_rounded,
                        size: 14, color: AppColors.rating),
                ),
            ),
            const SizedBox(width: 8),
            Text(
                _formatDate(comment.createdAt),
                style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
            ),
          ]),
          const SizedBox(height: 8),
          Text(comment.content,
              style: GoogleFonts.poppins(
                  color: AppColors.textPrimary, height: 1.5, fontSize: 14))
        ]));
  }

  String _formatDate(DateTime date) {
    return "${date.day} ${_getMonthName(date.month)} ${date.year}";
  }

  String _getMonthName(int month) {
    const months = [
      "Jan", "Feb", "Mar", "Apr", "Mei", "Jun",
      "Jul", "Agu", "Sep", "Okt", "Nov", "Des"
    ];
    return months[month - 1];
  }

  Widget _buildCircleBtn(IconData icon, VoidCallback onTap,
      {Color? color, bool forceDark = false}) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: forceDark
                    ? AppColors.cardSurface
                    : Colors.black.withOpacity(0.3),
                shape: BoxShape.circle,
                border:
                    forceDark ? Border.all(color: AppColors.divider) : null),
            child: Icon(icon,
                color: color ??
                    (forceDark ? AppColors.textPrimary : Colors.white),
                size: 20)));
  }

  Color _getColorFromname(String name) {
    if (name.isEmpty) return AppColors.primary;
    final colors = [
      AppColors.primary,
      const Color(0xFFA1887F),
      const Color(0xFF8D6E63),
      const Color(0xFF5D4037),
      const Color(0xFF795548)
    ];
    return colors[name.length % colors.length];
  }

  Widget _buildBackgroundPattern() {
    return Opacity(
      opacity: 0.03,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 6),
        itemBuilder: (context, index) => Transform.rotate(
          angle: math.pi / 4,
          child: Icon(index % 2 == 0 ? Icons.spa : Icons.local_florist,
              size: 24, color: AppColors.textPrimary),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            _isScrolled ? Brightness.dark : Brightness.light));

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: _buildBottomBar(),
      body: Stack(
        children: [
          Positioned.fill(child: _buildBackgroundPattern()),
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              _buildSliverAppBar(),
              SliverToBoxAdapter(
                child: Container(
                  transform: Matrix4.translationValues(0, -24, 0),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(32)),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black12,
                          blurRadius: 20,
                          offset: Offset(0, -5))
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                            child: Container(
                                width: 40,
                                height: 4,
                                margin:
                                    const EdgeInsets.only(top: 12, bottom: 20),
                                decoration: BoxDecoration(
                                    color: AppColors.divider,
                                    borderRadius: BorderRadius.circular(2)))),
                        _buildHeaderTitle(),
                        const SizedBox(height: 20),
                        _buildTags(),
                        const SizedBox(height: 30),
                        _buildInfoRow(),
                        const SizedBox(height: 32),
                        _buildSectionDivider(),
                        Text("Kisah Sejarah",
                            style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary)),
                        const SizedBox(height: 16),
                        _buildDescription(),
                        const SizedBox(height: 32),
                        // ✅ AI STORYTELLER TELAH DIHAPUS
                        _buildEtikaCard(),
                        const SizedBox(height: 32),
                        _buildSectionDivider(),
                        Text("Pemandu Budaya (AI)",
                            style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary)),
                        const SizedBox(height: 16),
                        _buildChatSection(),
                        const SizedBox(height: 32),
                        // ✅ GALERI VISUAL & LOKASI SITUS TELAH DIHAPUS
                        _buildSectionDivider(),
                        _buildReviewSection(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}