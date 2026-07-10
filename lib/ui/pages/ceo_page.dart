import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_fonts/google_fonts.dart'; // ✅ Font Poppins
import 'dart:ui' as ui; // ✅ Efek Glassmorphism

import '../styles/colors.dart';

// =========================================================================
// 1. DATA EVENT MANUAL (STATIS)
// =========================================================================
final List<Map<String, String>> _staticEventData2026 = [
  {'no': '1', 'tanggal': '8 FEBRUARI 2026', 'kategori': 'EVENT', 'nama': 'MERUMATTA COAST TRAIL', 'lokasi': 'DESA SENGGIGI', 'penyelenggara': 'MERUMATTA', 'klasifikasi': 'INTERNASIONAL', 'jenis': 'EVENT OLAHRAGA (SPORT TOURISM)'},
  {'no': '2', 'tanggal': 'MARET 2026', 'kategori': 'EVENT PEMASARAN PARIWISATA', 'nama': 'PESONA RAMADHAN', 'lokasi': 'DESA KEDIRI', 'penyelenggara': 'KECAMATAN KEDIRI', 'klasifikasi': 'LOKAL', 'jenis': 'SUPPORTING EVENT (OPEN STAGE)'},
  {'no': '3', 'tanggal': 'MARET 2026', 'kategori': 'EVENT BUDAYA', 'nama': 'REKOR MURI ZIKIR MASAL/HADRAH', 'lokasi': 'LAPANGAN KANTOR BUPATI DINAS LOMBOK BARAT', 'penyelenggara': 'DINAS PARIWISATA KAB. LOMBOK BARAT', 'klasifikasi': 'NASIONAL', 'jenis': 'MAIN EVENT (EVENT UTAMA)'},
  {'no': '4', 'tanggal': 'MARET 2026', 'kategori': 'EVENT BUDAYA', 'nama': 'LEBARAN TOPAT NTB 2026', 'lokasi': 'DESA SENGGIGI', 'penyelenggara': 'DINAS PARIWISATA KAB. LOMBOK BARAT', 'klasifikasi': 'REGIONAL', 'jenis': 'MAIN EVENT (EVENT UTAMA)'},
  {'no': '5', 'tanggal': 'APRIL 2026', 'kategori': 'EVENT PEMASARAN PARIWISATA', 'nama': 'LOMBOK BARAT TRAVEL MART', 'lokasi': 'NARMADA', 'penyelenggara': 'PELAKU PARIWISATA INDONESIA (ASPPI)', 'klasifikasi': 'REGIONAL', 'jenis': 'EVENT'},
  {'no': '6', 'tanggal': 'APRIL 2026', 'kategori': 'EVENT BUDAYA', 'nama': 'CFN IDOL', 'lokasi': 'ALUN-ALUN GIRI MENANG', 'penyelenggara': 'DINAS PARIWISATA KAB. LOMBOK BARAT', 'klasifikasi': 'LOKAL', 'jenis': 'EVENT'},
  {'no': '7', 'tanggal': 'APRIL 2026', 'kategori': 'EVENT OLAHRAGA', 'nama': 'JELOBAR HASH HUT LOMBOK BARAT', 'lokasi': 'DESA SENGGIGI', 'penyelenggara': 'DINAS PARIWISATA KAB. LOMBOK BARAT', 'klasifikasi': 'LOKAL', 'jenis': 'OPEN STAGE'},
  {'no': '8', 'tanggal': 'APRIL 2026', 'kategori': 'EVENT OLAHRAGA', 'nama': 'FESTIVAL PRESEAN HUT LOMBOK BARAT', 'lokasi': 'PTAM GIRI MENANG', 'penyelenggara': 'ALUN-ALUN GIRI MENANG', 'klasifikasi': 'LOKAL', 'jenis': 'EVENT'},
  {'no': '9', 'tanggal': 'MEI 2026', 'kategori': 'EVENT PEMASARAN PARIWISATA', 'nama': 'TRAVEL MART LOMBOK NETWORK', 'lokasi': 'DESA SENGGIGI', 'penyelenggara': 'INSAN PARIWISATA TRAVEL INDONESIA (IPI)', 'klasifikasi': 'REGIONAL', 'jenis': 'EVENT'},
  {'no': '10', 'tanggal': 'MEI 2026', 'kategori': 'EVENT OLAHRAGA', 'nama': 'MANCING MANIA', 'lokasi': 'DESA LEMBAR SELATAN', 'penyelenggara': 'DINAS PERIKANAN DAN KELAUTAN', 'klasifikasi': 'LOKAL', 'jenis': 'SUPPORTING EVENT'},
  {'no': '11', 'tanggal': 'JUNI 2026', 'kategori': 'EVENT OLAHRAGA', 'nama': 'SENGGIGI FUN RUN', 'lokasi': 'DESA SENGGIGI', 'penyelenggara': 'ASTINDO', 'klasifikasi': 'INTERNASIONAL', 'jenis': 'EVENT'},
  {'no': '12', 'tanggal': 'JUNI 2026', 'kategori': 'EVENT OLAHRAGA', 'nama': 'CEMARE TRAIL RUN BY I.B.F.', 'lokasi': 'DESA LEMBAR SELATAN', 'penyelenggara': 'INDONESIA BIRU FOUNDATION', 'klasifikasi': 'INTERNASIONAL', 'jenis': 'EVENT'},
  {'no': '13', 'tanggal': 'JUNI 2026', 'kategori': 'EVENT PEMASARAN PARIWISATA', 'nama': 'TRAVEL MART', 'lokasi': 'DESA SENGGIGI', 'penyelenggara': 'AITTA', 'klasifikasi': 'REGIONAL', 'jenis': 'EVENT'},
  {'no': '14', 'tanggal': 'JULI 2026', 'kategori': 'EVENT MUSIK', 'nama': 'ARUNA SOUND AND MOVE', 'lokasi': 'DESA SENGGIGI', 'penyelenggara': 'ARUNA', 'klasifikasi': 'REGIONAL', 'jenis': 'EVENT'},
  {'no': '15', 'tanggal': 'JULI 2026', 'kategori': 'EVENT BUDAYA', 'nama': 'FESTIVAL TAMAN NARMADA', 'lokasi': 'TAMAN NARMADA', 'penyelenggara': 'PT. TRIPAT', 'klasifikasi': 'LOKAL', 'jenis': 'EVENT'},
  {'no': '16', 'tanggal': 'AGUSTUS 2026', 'kategori': 'EVENT OLAHRAGA', 'nama': 'SAIL BOAT RACE 2026', 'lokasi': 'DESA SEKOTONG BARAT', 'penyelenggara': 'KELOMPOK NELAYAN PESISIR MAS', 'klasifikasi': 'REGIONAL', 'jenis': 'EVENT'},
  {'no': '17', 'tanggal': 'AGUSTUS 2026', 'kategori': 'EVENT OLAHRAGA', 'nama': 'ARUNA SENGGIGI NITE RUN', 'lokasi': 'DESA SENGGIGI', 'penyelenggara': 'ARUNA', 'klasifikasi': 'REGIONAL', 'jenis': 'EVENT'},
  {'no': '18', 'tanggal': 'AGUSTUS 2026', 'kategori': 'EVENT BUDAYA', 'nama': 'FESTIVAL GENDANG BELEQ', 'lokasi': 'ALUN-ALUN GIRI MENANG', 'penyelenggara': 'PTAM GIRI MENANG', 'klasifikasi': 'LOKAL', 'jenis': 'EVENT'},
  {'no': '19', 'tanggal': 'AGUSTUS 2026', 'kategori': 'EVENT OLAHRAGA', 'nama': 'JELOBAR HASH HUT INDONESIA', 'lokasi': 'DESA SENGGIGI', 'penyelenggara': 'DINAS PARIWISATA', 'klasifikasi': 'LOKAL', 'jenis': 'EVENT'},
  {'no': '20', 'tanggal': 'AGUSTUS 2026', 'kategori': 'EVENT OLAHRAGA', 'nama': 'FESTIVAL PRESEAN HUT INDONESIA', 'lokasi': 'ALUN-ALUN GIRI MENANG', 'penyelenggara': 'PTAM GIRI MENANG', 'klasifikasi': 'LOKAL', 'jenis': 'EVENT'},
  {'no': '21', 'tanggal': 'AGUSTUS 2026', 'kategori': 'EVENT BUDAYA', 'nama': 'PESONA KERIS NUSANTARA', 'lokasi': 'PASAR SENI SENGGIGI', 'penyelenggara': 'PAGUYUBAN ANJANI', 'klasifikasi': 'REGIONAL', 'jenis': 'EVENT'},
  {'no': '22', 'tanggal': 'SEPTEMBER 2026', 'kategori': 'EVENT PEMASARAN', 'nama': 'ROAD TO MOTOGP 2026', 'lokasi': 'PASAR SENI SENGGIGI', 'penyelenggara': 'DINAS PARIWISATA', 'klasifikasi': 'LOKAL', 'jenis': 'SUPPORTING EVENT'},
  {'no': '23', 'tanggal': 'OKTOBER 2026', 'kategori': 'EVENT BUDAYA', 'nama': 'FESTIVAL 2 GUNUNG', 'lokasi': 'DESA KURIPAN', 'penyelenggara': 'DINAS PARIWISATA', 'klasifikasi': 'REGIONAL', 'jenis': 'EVENT'},
  {'no': '24', 'tanggal': 'OKTOBER 2026', 'kategori': 'EVENT PEMASARAN', 'nama': 'LAUNCHING COE 2027', 'lokasi': 'DESA SENGGIGI', 'penyelenggara': 'DINAS PARIWISATA', 'klasifikasi': 'REGIONAL', 'jenis': 'SUPPORTING EVENT'},
  {'no': '25', 'tanggal': 'OKTOBER 2026', 'kategori': 'EVENT OLAHRAGA', 'nama': 'KEJUARAAN PARALAYANG 2026', 'lokasi': 'SEKOTONG', 'penyelenggara': 'DINAS PARIWISATA', 'klasifikasi': 'INTERNASIONAL', 'jenis': 'SUPPORTING EVENT'},
  {'no': '26', 'tanggal': 'OKTOBER 2026', 'kategori': 'EVENT BUDAYA', 'nama': 'FESTIVAL SEKOTONG', 'lokasi': 'DESA SEKOTONG BARAT', 'penyelenggara': 'DINAS PARIWISATA', 'klasifikasi': 'REGIONAL', 'jenis': 'MAIN EVENT'},
  {'no': '27', 'tanggal': 'OKTOBER 2026', 'kategori': 'EVENT OLAHRAGA', 'nama': 'MERUMATTA HALF MARATHON', 'lokasi': 'DESA SENGGIGI', 'penyelenggara': 'MERUMATTA', 'klasifikasi': 'INTERNASIONAL', 'jenis': 'EVENT'},
  {'no': '28', 'tanggal': 'NOVEMBER 2026', 'kategori': 'EVENT BUDAYA', 'nama': 'FESTIVAL PESONA SENGGIGI 2026', 'lokasi': 'DESA SENGGIGI', 'penyelenggara': 'DINAS PARIWISATA', 'klasifikasi': 'NASIONAL', 'jenis': 'MAIN EVENT'},
  {'no': '29', 'tanggal': 'NOVEMBER 2026', 'kategori': 'EVENT MUSIK', 'nama': 'SENGGIGI SUNSET JAZZ 2026', 'lokasi': 'DESA SENGGIGI', 'penyelenggara': 'NURAGA', 'klasifikasi': 'NASIONAL', 'jenis': 'EVENT'},
  {'no': '30', 'tanggal': 'NOVEMBER 2026', 'kategori': 'EVENT BUDAYA', 'nama': 'PERANG TOPAT 2026', 'lokasi': 'DESA LINGSAR', 'penyelenggara': 'DINAS PARIWISATA', 'klasifikasi': 'NASIONAL', 'jenis': 'MAIN EVENT'},
  {'no': '31', 'tanggal': 'DESEMBER 2026', 'kategori': 'EVENT OLAHRAGA', 'nama': 'FAMILY FUN RUN', 'lokasi': 'ALUN-ALUN GIRI MENANG', 'penyelenggara': 'AITTA', 'klasifikasi': 'LOKAL', 'jenis': 'SUPPORTING EVENT'},
  {'no': '32', 'tanggal': '31 DESEMBER 2026', 'kategori': 'EVENT BUDAYA', 'nama': 'TAHUN BARU 2027', 'lokasi': 'ALUN-ALUN GIRI MENANG', 'penyelenggara': 'DINAS PARIWISATA', 'klasifikasi': 'LOKAL', 'jenis': 'OPEN STAGE'},
];

class CoePage extends StatefulWidget {
  final Function(int)? onNavTapped;
  const CoePage({super.key, this.onNavTapped});

  @override
  State<CoePage> createState() => _CoePageState();
}

class _CoePageState extends State<CoePage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime(2026, 1, 1);
  DateTime? _selectedDay;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _selectedCategoryFilter = "Semua";

  // Helper Bulan
  final Map<String, int> _monthMap = {
    "JANUARI": 1, "FEBRUARI": 2, "MARET": 3, "APRIL": 4, "MEI": 5, "JUNI": 6,
    "JULI": 7, "AGUSTUS": 8, "SEPTEMBER": 9, "OKTOBER": 10, "NOVEMBER": 11, "DESEMBER": 12
  };

  // ➕ Variabel ikon filter premium
  final Map<String, IconData> _filterIcons = {
    "Semua": Icons.grid_view_rounded,
    "BUDAYA": Icons.museum_rounded,
    "OLAHRAGA": Icons.directions_run_rounded,
    "PARIWISATA": Icons.flight_takeoff_rounded,
  };

  @override
  void initState() {
    super.initState();
    if (DateTime.now().year == 2026) {
      _focusedDay = DateTime.now();
    }
    _selectedDay = _focusedDay;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- LOGIKA PARSE TANGGAL PINTAR ---
  DateTime? _parseEventDate(String dateStr) {
    try {
      dateStr = dateStr.toUpperCase().trim().replaceAll('-', ' ');
      var parts = dateStr.split(' ');
      int year = 2026;
      if (parts.length >= 3 && int.tryParse(parts[2]) != null) year = int.parse(parts[2]);
      else if (parts.length == 2 && int.tryParse(parts[1]) != null && parts[1].length == 4) year = int.parse(parts[1]);

      int day = 1;
      if (parts.isNotEmpty && int.tryParse(parts[0]) != null) day = int.parse(parts[0]);

      String monthStr = "";
      for (var p in parts) { if (_monthMap.containsKey(p)) { monthStr = p; break; } }

      if (monthStr.isNotEmpty) return DateTime(year, _monthMap[monthStr]!, day);
      return null;
    } catch (e) { return null; }
  }

  String _extractMonthName(String dateStr) {
    DateTime? dt = _parseEventDate(dateStr);
    if (dt != null) {
      const months = ["JANUARI", "FEBRUARI", "MARET", "APRIL", "MEI", "JUNI", "JULI", "AGUSTUS", "SEPTEMBER", "OKTOBER", "NOVEMBER", "DESEMBER"];
      return months[dt.month - 1];
    }
    try {
      var parts = dateStr.toUpperCase().split(' ');
      for (var p in parts) { if (_monthMap.containsKey(p)) return p; }
    } catch (_) {}
    return "AGENDA";
  }

  String _extractDateOnly(String fullDate) {
    var parts = fullDate.split(RegExp(r'[\s-]'));
    if (parts.isNotEmpty && int.tryParse(parts[0]) != null) return parts[0];
    return "🗓️";
  }

  String _extractYearOnly(String fullDate) {
    DateTime? dt = _parseEventDate(fullDate);
    return dt != null ? dt.year.toString() : "2026";
  }

  // --- FILTER & SORTING ---
  List<Map<String, dynamic>> _getCombinedAndFilteredEvents(List<DocumentSnapshot> firebaseDocs) {
    List<Map<String, dynamic>> firebaseEvents = firebaseDocs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {'id': doc.id, 'nama': data['nama'] ?? 'Tanpa Nama', 'tanggal': data['tanggal'] ?? '-', 'lokasi': data['lokasi'] ?? '-', 'penyelenggara': data['penyelenggara'] ?? '-', 'klasifikasi': data['klasifikasi'] ?? 'UMUM', 'kategori': 'EVENT', 'is_new': true, 'created_at': data['createdAt']};
    }).toList();

    List<Map<String, dynamic>> manualEvents = List.from(_staticEventData2026);
    List<Map<String, dynamic>> allEvents = [...firebaseEvents, ...manualEvents];

    var filtered = allEvents.where((event) {
      bool matchSearch = true;
      if (_searchQuery.isNotEmpty) {
        String nama = (event['nama'] ?? '').toString().toLowerCase();
        String lokasi = (event['lokasi'] ?? '').toString().toLowerCase();
        matchSearch = nama.contains(_searchQuery.toLowerCase()) || lokasi.contains(_searchQuery.toLowerCase());
      }

      bool matchCategory = true;
      if (_selectedCategoryFilter != "Semua") {
        String kategori = (event['kategori'] ?? '').toString().toUpperCase();
        String klasifikasi = (event['klasifikasi'] ?? '').toString().toUpperCase();
        String jenis = (event['jenis'] ?? '').toString().toUpperCase();

        if (_selectedCategoryFilter == "BUDAYA" && !klasifikasi.contains("BUDAYA") && !kategori.contains("BUDAYA") && !jenis.contains("BUDAYA")) matchCategory = false;
        if (_selectedCategoryFilter == "OLAHRAGA" && !klasifikasi.contains("OLAHRAGA") && !kategori.contains("OLAHRAGA") && !jenis.contains("OLAHRAGA")) matchCategory = false;
        if (_selectedCategoryFilter == "PARIWISATA" && !klasifikasi.contains("PARIWISATA") && !kategori.contains("PARIWISATA") && !jenis.contains("PARIWISATA")) matchCategory = false;
      }
      return matchSearch && matchCategory;
    }).toList();

    filtered.sort((a, b) {
      DateTime? dateA = _parseEventDate(a['tanggal']);
      DateTime? dateB = _parseEventDate(b['tanggal']);
      if (dateA == null) return 1;
      if (dateB == null) return -1;
      return dateA.compareTo(dateB);
    });

    return filtered;
  }

  List<dynamic> _getEventsForDay(DateTime day, List<Map<String, dynamic>> events) {
    return events.where((event) {
      DateTime? eventDate = _parseEventDate(event['tanggal']);
      if (eventDate == null) return false;
      return isSameDay(eventDate, day);
    }).toList();
  }

  // ➕ GLASSMORPHISM CARD WRAPPER (Sama seperti di MapsPage)
  Widget _buildGlassCard({required Widget child, Color? color, double opacity = 0.85}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
        child: Container(
          decoration: BoxDecoration(
            color: (color ?? Colors.white).withOpacity(opacity),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.25), width: 1),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 8))],
          ),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      // ➕ Ganti AppBar standar dengan AppBar transparan/premium
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: _buildGlassCard(
            color: Colors.white, 
            opacity: 0.9,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () {
                if (widget.onNavTapped != null) {
                  widget.onNavTapped!(0);
                } else {
                  Navigator.pop(context);
                }
              },
              child: const Icon(Icons.arrow_back_rounded, color: Colors.black87, size: 20),
            ),
          ),
        ),
        title: Column(
          children: [
            Text("Kalender Event", style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16)),
            Text("Lombok Barat 2026", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 11)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: _buildGlassCard(
              color: Colors.white,
              opacity: 0.9,
              child: InkWell(
                customBorder: const CircleBorder(),
                // ✅ PERBAIKAN ERROR DI SINI: Ganti 'onPressed' menjadi 'onTap'
                onTap: () { 
                  setState(() {
                    _focusedDay = DateTime(2026, 1, 1);
                    _selectedDay = _focusedDay;
                  });
                },
                child: const Padding(padding: EdgeInsets.all(8.0), child: Icon(Icons.today_rounded, color: AppColors.primary, size: 20)),
              ),
            ),
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('agenda_events').snapshots(),
          builder: (context, snapshot) {
            List<DocumentSnapshot> firebaseDocs = [];
            if (snapshot.hasData) { firebaseDocs = snapshot.data!.docs; }

            final displayedEvents = _getCombinedAndFilteredEvents(firebaseDocs);

            return Column(
              children: [
                // 1. KALENDER
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 4))]
                  ),
                  child: TableCalendar(
                    locale: 'id_ID',
                    firstDay: DateTime(2024, 1, 1),
                    lastDay: DateTime(2030, 12, 31),
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    onFormatChanged: (format) => setState(() => _calendarFormat = format),
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() { _selectedDay = selectedDay; _focusedDay = focusedDay; });
                    },
                    eventLoader: (day) => _getEventsForDay(day, displayedEvents),
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      leftChevronIcon: Icon(Icons.chevron_left_rounded, color: AppColors.primary),
                      rightChevronIcon: Icon(Icons.chevron_right_rounded, color: AppColors.primary),
                    ),
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(color: AppColors.primary.withOpacity(0.3), shape: BoxShape.circle),
                      todayTextStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                      selectedDecoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      markerDecoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                    ),
                  ),
                ),

                // 2. SEARCH & FILTER
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      _buildGlassCard(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            children: [
                              const Icon(Icons.search_rounded, color: Colors.grey),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: (value) => setState(() => _searchQuery = value),
                                  style: GoogleFonts.poppins(fontSize: 15),
                                  decoration: InputDecoration(
                                    hintText: "Cari nama event atau lokasi...",
                                    hintStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 15),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              if (_searchQuery.isNotEmpty) 
                                IconButton(icon: const Icon(Icons.close, color: Colors.grey), onPressed: () { _searchController.clear(); setState(() => _searchQuery = ""); })
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: ["Semua", "BUDAYA", "OLAHRAGA", "PARIWISATA"].map((label) {
                            final isSelected = _selectedCategoryFilter == label;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                avatar: isSelected ? null : Icon(_filterIcons[label], size: 16, color: Colors.grey.shade600),
                                label: Text(label, style: GoogleFonts.poppins(fontSize: 12, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
                                selected: isSelected,
                                onSelected: (_) => setState(() => _selectedCategoryFilter = label),
                                selectedColor: AppColors.primary.withOpacity(0.15),
                                backgroundColor: Colors.white.withOpacity(0.6),
                                labelStyle: GoogleFonts.poppins(color: isSelected ? AppColors.primary : Colors.black87, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: isSelected ? AppColors.primary : Colors.transparent)),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),

                // 3. HEADER TOTAL
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Agenda Mendatang", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text("${displayedEvents.length} Event", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),

                // 4. LIST EVENT
                Expanded(
                  child: displayedEvents.isEmpty
                      ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.search_off_rounded, size: 50, color: Colors.grey.shade400), const SizedBox(height: 10), Text("Tidak ada event yang cocok", style: GoogleFonts.poppins(color: Colors.grey.shade500))]))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                          itemCount: displayedEvents.length,
                          itemBuilder: (context, index) {
                            final event = displayedEvents[index];
                            bool showHeader = false;
                            if (index == 0) {
                              showHeader = true;
                            } else {
                              final prevEvent = displayedEvents[index - 1];
                              if (_extractMonthName(event['tanggal']) != _extractMonthName(prevEvent['tanggal'])) showHeader = true;
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (showHeader) _buildMonthHeader(_extractMonthName(event['tanggal']), _extractYearOnly(event['tanggal'])),
                                _buildModernEventCard(event),
                              ],
                            );
                          },
                        ),
                ),
              ],
            );
          }),
    );
  }

  Widget _buildMonthHeader(String monthName, String year) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
      child: Row(
        children: [
          Container(width: 4, height: 24, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(4))),
          const SizedBox(width: 10),
          Text("$monthName $year", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black87, letterSpacing: 0.5)),
          const SizedBox(width: 10),
          Expanded(child: Container(height: 1, color: Colors.grey.shade200)),
        ],
      ),
    );
  }

  // ➕ DESAIN KARTU EVENT YANG LEBIH ELEGAN
  Widget _buildModernEventCard(Map<String, dynamic> event) {
    Color badgeColor = Colors.blue;
    String klasifikasi = (event['klasifikasi'] ?? '').toString().toUpperCase();
    String kategori = (event['kategori'] ?? '').toString().toUpperCase();
    if (klasifikasi.contains('NASIONAL') || kategori.contains('BUDAYA')) badgeColor = Colors.orange;
    if (klasifikasi.contains('INTERNASIONAL') || kategori.contains('OLAHRAGA')) badgeColor = Colors.green;

    bool isNew = event['is_new'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ➕ Desain Tanggal lebih modern (tidak perlu kotak jumbo)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_extractDateOnly(event['tanggal']), style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.primary, height: 1)),
                Text(_extractYearOnly(event['tanggal']), style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, height: 1)),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: badgeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                        child: Text(klasifikasi.isEmpty ? kategori : klasifikasi, style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: badgeColor)),
                      ),
                      if (isNew) ...[
                        const SizedBox(width: 6),
                        Container(
                           padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                           decoration: BoxDecoration(color: Colors.blue.withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
                           child: Text("BARU", style: GoogleFonts.poppins(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.blue)),
                        )
                      ]
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(event['nama'], maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, height: 1.3)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.location_on_rounded, size: 14, color: Colors.grey[400]),
                      const SizedBox(width: 4),
                      Expanded(child: Text(event['lokasi'], maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[600]))),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}