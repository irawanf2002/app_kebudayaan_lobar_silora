import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../styles/colors.dart';

// =========================================================================
// 1. DATA EVENT MANUAL (STATIS)
// =========================================================================
final List<Map<String, String>> _staticEventData2026 = [
  {
    'no': '1',
    'tanggal': '8 FEBRUARI 2026',
    'kategori': 'EVENT',
    'nama': 'MERUMATTA COAST TRAIL',
    'lokasi': 'DESA SENGGIGI',
    'penyelenggara': 'MERUMATTA',
    'klasifikasi': 'INTERNASIONAL',
    'jenis': 'EVENT OLAHRAGA (SPORT TOURISM)',
  },
  {
    'no': '2',
    'tanggal': 'MARET 2026',
    'kategori': 'EVENT PEMASARAN PARIWISATA',
    'nama': 'PESONA RAMADHAN',
    'lokasi': 'DESA KEDIRI',
    'penyelenggara': 'KECAMATAN KEDIRI',
    'klasifikasi': 'LOKAL',
    'jenis': 'SUPPORTING EVENT (OPEN STAGE)',
  },
  {
    'no': '3',
    'tanggal': 'MARET 2026',
    'kategori': 'EVENT BUDAYA',
    'nama': 'REKOR MURI ZIKIR MASAL/HADRAH',
    'lokasi': 'LAPANGAN KANTOR BUPATI DINAS LOMBOK BARAT',
    'penyelenggara': 'DINAS PARIWISATA KAB. LOMBOK BARAT',
    'klasifikasi': 'NASIONAL',
    'jenis': 'MAIN EVENT (EVENT UTAMA)',
  },
  {
    'no': '4',
    'tanggal': 'MARET 2026',
    'kategori': 'EVENT BUDAYA',
    'nama': 'LEBARAN TOPAT NTB 2026',
    'lokasi': 'DESA SENGGIGI',
    'penyelenggara': 'DINAS PARIWISATA KAB. LOMBOK BARAT',
    'klasifikasi': 'REGIONAL',
    'jenis': 'MAIN EVENT (EVENT UTAMA)',
  },
  {
    'no': '5',
    'tanggal': 'APRIL 2026',
    'kategori': 'EVENT PEMASARAN PARIWISATA',
    'nama': 'LOMBOK BARAT TRAVEL MART',
    'lokasi': 'NARMADA',
    'penyelenggara': 'PELAKU PARIWISATA INDONESIA (ASPPI)',
    'klasifikasi': 'REGIONAL',
    'jenis': 'EVENT',
  },
  {
    'no': '6',
    'tanggal': 'APRIL 2026',
    'kategori': 'EVENT BUDAYA',
    'nama': 'CFN IDOL',
    'lokasi': 'ALUN-ALUN GIRI MENANG',
    'penyelenggara': 'DINAS PARIWISATA KAB. LOMBOK BARAT',
    'klasifikasi': 'LOKAL',
    'jenis': 'EVENT',
  },
  {
    'no': '7',
    'tanggal': 'APRIL 2026',
    'kategori': 'EVENT OLAHRAGA',
    'nama': 'JELOBAR HASH HUT LOMBOK BARAT',
    'lokasi': 'DESA SENGGIGI',
    'penyelenggara': 'DINAS PARIWISATA KAB. LOMBOK BARAT',
    'klasifikasi': 'LOKAL',
    'jenis': 'OPEN STAGE',
  },
  {
    'no': '8',
    'tanggal': 'APRIL 2026',
    'kategori': 'EVENT OLAHRAGA',
    'nama': 'FESTIVAL PRESEAN HUT LOMBOK BARAT',
    'lokasi': 'PTAM GIRI MENANG',
    'penyelenggara': 'ALUN-ALUN GIRI MENANG',
    'klasifikasi': 'LOKAL',
    'jenis': 'EVENT',
  },
  {
    'no': '9',
    'tanggal': 'MEI 2026',
    'kategori': 'EVENT PEMASARAN PARIWISATA',
    'nama': 'TRAVEL MART LOMBOK NETWORK',
    'lokasi': 'DESA SENGGIGI',
    'penyelenggara': 'INSAN PARIWISATA TRAVEL INDONESIA (IPI)',
    'klasifikasi': 'REGIONAL',
    'jenis': 'EVENT',
  },
  {
    'no': '10',
    'tanggal': 'MEI 2026',
    'kategori': 'EVENT OLAHRAGA',
    'nama': 'MANCING MANIA',
    'lokasi': 'DESA LEMBAR SELATAN',
    'penyelenggara': 'DINAS PERIKANAN DAN KELAUTAN',
    'klasifikasi': 'LOKAL',
    'jenis': 'SUPPORTING EVENT',
  },
  {
    'no': '11',
    'tanggal': 'JUNI 2026',
    'kategori': 'EVENT OLAHRAGA',
    'nama': 'SENGGIGI FUN RUN',
    'lokasi': 'DESA SENGGIGI',
    'penyelenggara': 'ASTINDO',
    'klasifikasi': 'INTERNASIONAL',
    'jenis': 'EVENT',
  },
  {
    'no': '12',
    'tanggal': 'JUNI 2026',
    'kategori': 'EVENT OLAHRAGA',
    'nama': 'CEMARE TRAIL RUN BY I.B.F.',
    'lokasi': 'DESA LEMBAR SELATAN',
    'penyelenggara': 'INDONESIA BIRU FOUNDATION',
    'klasifikasi': 'INTERNASIONAL',
    'jenis': 'EVENT',
  },
  {
    'no': '13',
    'tanggal': 'JUNI 2026',
    'kategori': 'EVENT PEMASARAN PARIWISATA',
    'nama': 'TRAVEL MART',
    'lokasi': 'DESA SENGGIGI',
    'penyelenggara': 'AITTA',
    'klasifikasi': 'REGIONAL',
    'jenis': 'EVENT',
  },
  {
    'no': '14',
    'tanggal': 'JULI 2026',
    'kategori': 'EVENT MUSIK',
    'nama': 'ARUNA SOUND AND MOVE',
    'lokasi': 'DESA SENGGIGI',
    'penyelenggara': 'ARUNA',
    'klasifikasi': 'REGIONAL',
    'jenis': 'EVENT',
  },
  {
    'no': '15',
    'tanggal': 'JULI 2026',
    'kategori': 'EVENT BUDAYA',
    'nama': 'FESTIVAL TAMAN NARMADA',
    'lokasi': 'TAMAN NARMADA',
    'penyelenggara': 'PT. TRIPAT',
    'klasifikasi': 'LOKAL',
    'jenis': 'EVENT',
  },
  {
    'no': '16',
    'tanggal': 'AGUSTUS 2026',
    'kategori': 'EVENT OLAHRAGA',
    'nama': 'SAIL BOAT RACE 2026',
    'lokasi': 'DESA SEKOTONG BARAT',
    'penyelenggara': 'KELOMPOK NELAYAN PESISIR MAS',
    'klasifikasi': 'REGIONAL',
    'jenis': 'EVENT',
  },
  {
    'no': '17',
    'tanggal': 'AGUSTUS 2026',
    'kategori': 'EVENT OLAHRAGA',
    'nama': 'ARUNA SENGGIGI NITE RUN',
    'lokasi': 'DESA SENGGIGI',
    'penyelenggara': 'ARUNA',
    'klasifikasi': 'REGIONAL',
    'jenis': 'EVENT',
  },
  {
    'no': '18',
    'tanggal': 'AGUSTUS 2026',
    'kategori': 'EVENT BUDAYA',
    'nama': 'FESTIVAL GENDANG BELEQ',
    'lokasi': 'ALUN-ALUN GIRI MENANG',
    'penyelenggara': 'PTAM GIRI MENANG',
    'klasifikasi': 'LOKAL',
    'jenis': 'EVENT',
  },
  {
    'no': '19',
    'tanggal': 'AGUSTUS 2026',
    'kategori': 'EVENT OLAHRAGA',
    'nama': 'JELOBAR HASH HUT INDONESIA',
    'lokasi': 'DESA SENGGIGI',
    'penyelenggara': 'DINAS PARIWISATA',
    'klasifikasi': 'LOKAL',
    'jenis': 'EVENT',
  },
  {
    'no': '20',
    'tanggal': 'AGUSTUS 2026',
    'kategori': 'EVENT OLAHRAGA',
    'nama': 'FESTIVAL PRESEAN HUT INDONESIA',
    'lokasi': 'ALUN-ALUN GIRI MENANG',
    'penyelenggara': 'PTAM GIRI MENANG',
    'klasifikasi': 'LOKAL',
    'jenis': 'EVENT',
  },
  {
    'no': '21',
    'tanggal': 'AGUSTUS 2026',
    'kategori': 'EVENT BUDAYA',
    'nama': 'PESONA KERIS NUSANTARA',
    'lokasi': 'PASAR SENI SENGGIGI',
    'penyelenggara': 'PAGUYUBAN ANJANI',
    'klasifikasi': 'REGIONAL',
    'jenis': 'EVENT',
  },
  {
    'no': '22',
    'tanggal': 'SEPTEMBER 2026',
    'kategori': 'EVENT PEMASARAN',
    'nama': 'ROAD TO MOTOGP 2026',
    'lokasi': 'PASAR SENI SENGGIGI',
    'penyelenggara': 'DINAS PARIWISATA',
    'klasifikasi': 'LOKAL',
    'jenis': 'SUPPORTING EVENT',
  },
  {
    'no': '23',
    'tanggal': 'OKTOBER 2026',
    'kategori': 'EVENT BUDAYA',
    'nama': 'FESTIVAL 2 GUNUNG',
    'lokasi': 'DESA KURIPAN',
    'penyelenggara': 'DINAS PARIWISATA',
    'klasifikasi': 'REGIONAL',
    'jenis': 'EVENT',
  },
  {
    'no': '24',
    'tanggal': 'OKTOBER 2026',
    'kategori': 'EVENT PEMASARAN',
    'nama': 'LAUNCHING COE 2027',
    'lokasi': 'DESA SENGGIGI',
    'penyelenggara': 'DINAS PARIWISATA',
    'klasifikasi': 'REGIONAL',
    'jenis': 'SUPPORTING EVENT',
  },
  {
    'no': '25',
    'tanggal': 'OKTOBER 2026',
    'kategori': 'EVENT OLAHRAGA',
    'nama': 'KEJUARAAN PARALAYANG 2026',
    'lokasi': 'SEKOTONG',
    'penyelenggara': 'DINAS PARIWISATA',
    'klasifikasi': 'INTERNASIONAL',
    'jenis': 'SUPPORTING EVENT',
  },
  {
    'no': '26',
    'tanggal': 'OKTOBER 2026',
    'kategori': 'EVENT BUDAYA',
    'nama': 'FESTIVAL SEKOTONG',
    'lokasi': 'DESA SEKOTONG BARAT',
    'penyelenggara': 'DINAS PARIWISATA',
    'klasifikasi': 'REGIONAL',
    'jenis': 'MAIN EVENT',
  },
  {
    'no': '27',
    'tanggal': 'OKTOBER 2026',
    'kategori': 'EVENT OLAHRAGA',
    'nama': 'MERUMATTA HALF MARATHON',
    'lokasi': 'DESA SENGGIGI',
    'penyelenggara': 'MERUMATTA',
    'klasifikasi': 'INTERNASIONAL',
    'jenis': 'EVENT',
  },
  {
    'no': '28',
    'tanggal': 'NOVEMBER 2026',
    'kategori': 'EVENT BUDAYA',
    'nama': 'FESTIVAL PESONA SENGGIGI 2026',
    'lokasi': 'DESA SENGGIGI',
    'penyelenggara': 'DINAS PARIWISATA',
    'klasifikasi': 'NASIONAL',
    'jenis': 'MAIN EVENT',
  },
  {
    'no': '29',
    'tanggal': 'NOVEMBER 2026',
    'kategori': 'EVENT MUSIK',
    'nama': 'SENGGIGI SUNSET JAZZ 2026',
    'lokasi': 'DESA SENGGIGI',
    'penyelenggara': 'NURAGA',
    'klasifikasi': 'NASIONAL',
    'jenis': 'EVENT',
  },
  {
    'no': '30',
    'tanggal': 'NOVEMBER 2026',
    'kategori': 'EVENT BUDAYA',
    'nama': 'PERANG TOPAT 2026',
    'lokasi': 'DESA LINGSAR',
    'penyelenggara': 'DINAS PARIWISATA',
    'klasifikasi': 'NASIONAL',
    'jenis': 'MAIN EVENT',
  },
  {
    'no': '31',
    'tanggal': 'DESEMBER 2026',
    'kategori': 'EVENT OLAHRAGA',
    'nama': 'FAMILY FUN RUN',
    'lokasi': 'ALUN-ALUN GIRI MENANG',
    'penyelenggara': 'AITTA',
    'klasifikasi': 'LOKAL',
    'jenis': 'SUPPORTING EVENT',
  },
  {
    'no': '32',
    'tanggal': '31 DESEMBER 2026',
    'kategori': 'EVENT BUDAYA',
    'nama': 'TAHUN BARU 2027',
    'lokasi': 'ALUN-ALUN GIRI MENANG',
    'penyelenggara': 'DINAS PARIWISATA',
    'klasifikasi': 'LOKAL',
    'jenis': 'OPEN STAGE',
  },
];

class CoePage extends StatefulWidget {
  // 1. TAMBAHKAN PARAMETER INI UNTUK MEMPERBAIKI ERROR
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
    "JANUARI": 1,
    "FEBRUARI": 2,
    "MARET": 3,
    "APRIL": 4,
    "MEI": 5,
    "JUNI": 6,
    "JULI": 7,
    "AGUSTUS": 8,
    "SEPTEMBER": 9,
    "OKTOBER": 10,
    "NOVEMBER": 11,
    "DESEMBER": 12
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
      var parts = dateStr.split(' '); // [20, FEBRUARI, 2026] atau [MARET]

      int year = 2026;
      if (parts.length >= 3 && int.tryParse(parts[2]) != null) {
        year = int.parse(parts[2]);
      } else if (parts.length == 2 &&
          int.tryParse(parts[1]) != null &&
          parts[1].length == 4) {
        year = int.parse(parts[1]);
      }

      int day = 1;
      if (parts.isNotEmpty && int.tryParse(parts[0]) != null) {
        day = int.parse(parts[0]);
      }

      String monthStr = "";
      for (var p in parts) {
        if (_monthMap.containsKey(p)) {
          monthStr = p;
          break;
        }
      }

      if (monthStr.isNotEmpty) {
        return DateTime(year, _monthMap[monthStr]!, day);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  String _extractMonthName(String dateStr) {
    DateTime? dt = _parseEventDate(dateStr);
    if (dt != null) {
      const months = [
        "JANUARI",
        "FEBRUARI",
        "MARET",
        "APRIL",
        "MEI",
        "JUNI",
        "JULI",
        "AGUSTUS",
        "SEPTEMBER",
        "OKTOBER",
        "NOVEMBER",
        "DESEMBER"
      ];
      return months[dt.month - 1];
    }
    try {
      var parts = dateStr.toUpperCase().split(' ');
      for (var p in parts) {
        if (_monthMap.containsKey(p)) return p;
      }
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
  List<Map<String, dynamic>> _getCombinedAndFilteredEvents(
      List<DocumentSnapshot> firebaseDocs) {
    // 1. Konversi Data Firebase ke Format Map
    List<Map<String, dynamic>> firebaseEvents = firebaseDocs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {
        'id': doc.id,
        'nama': data['nama'] ?? 'Tanpa Nama',
        'tanggal': data['tanggal'] ?? '-',
        'lokasi': data['lokasi'] ?? '-',
        'penyelenggara': data['penyelenggara'] ?? '-',
        'klasifikasi': data['klasifikasi'] ?? 'UMUM',
        'kategori': 'EVENT',
        'is_new': true,
        'created_at': data['createdAt']
      };
    }).toList();

    List<Map<String, dynamic>> manualEvents = List.from(_staticEventData2026);
    List<Map<String, dynamic>> allEvents = [...firebaseEvents, ...manualEvents];

    var filtered = allEvents.where((event) {
      bool matchSearch = true;
      if (_searchQuery.isNotEmpty) {
        String nama = (event['nama'] ?? '').toString().toLowerCase();
        String lokasi = (event['lokasi'] ?? '').toString().toLowerCase();
        matchSearch = nama.contains(_searchQuery.toLowerCase()) ||
            lokasi.contains(_searchQuery.toLowerCase());
      }

      bool matchCategory = true;
      if (_selectedCategoryFilter != "Semua") {
        String kategori = (event['kategori'] ?? '').toString().toUpperCase();
        String klasifikasi =
            (event['klasifikasi'] ?? '').toString().toUpperCase();
        String jenis = (event['jenis'] ?? '').toString().toUpperCase();

        if (_selectedCategoryFilter == "BUDAYA" &&
            !klasifikasi.contains("BUDAYA") &&
            !kategori.contains("BUDAYA") &&
            !jenis.contains("BUDAYA")) matchCategory = false;
        if (_selectedCategoryFilter == "OLAHRAGA" &&
            !klasifikasi.contains("OLAHRAGA") &&
            !kategori.contains("OLAHRAGA") &&
            !jenis.contains("OLAHRAGA")) matchCategory = false;
        if (_selectedCategoryFilter == "PARIWISATA" &&
            !klasifikasi.contains("PARIWISATA") &&
            !kategori.contains("PARIWISATA") &&
            !jenis.contains("PARIWISATA")) matchCategory = false;
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

  // Helper untuk titik di kalender
  List<dynamic> _getEventsForDay(
      DateTime day, List<Map<String, dynamic>> events) {
    return events.where((event) {
      DateTime? eventDate = _parseEventDate(event['tanggal']);
      if (eventDate == null) return false;
      return isSameDay(eventDate, day);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.grey.shade50,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
              onPressed: () {
                // LOGIKA KEMBALI:
                // Jika dari BottomNav (onNavTapped ada) -> Pindah ke Tab Home (0)
                // Jika dari Push -> Navigator Pop
                if (widget.onNavTapped != null) {
                  widget.onNavTapped!(0);
                } else {
                  Navigator.pop(context);
                }
              },
            ),
          ),
        ),
        title: const Column(
          children: [
            Text("Kalender Event",
                style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
            Text("Lombok Barat 2026",
                style: TextStyle(color: Colors.grey, fontSize: 11)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.today_rounded, color: AppColors.primary),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime(2026, 1, 1);
                _selectedDay = _focusedDay;
              });
            },
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('agenda_events')
              .snapshots(),
          builder: (context, snapshot) {
            List<DocumentSnapshot> firebaseDocs = [];
            if (snapshot.hasData) {
              firebaseDocs = snapshot.data!.docs;
            }

            final displayedEvents = _getCombinedAndFilteredEvents(firebaseDocs);

            return Column(
              children: [
                // 1. KALENDER
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 20,
                          offset: const Offset(0, 4))
                    ],
                  ),
                  child: TableCalendar(
                    locale: 'id_ID',
                    firstDay: DateTime(2024, 1, 1),
                    lastDay: DateTime(2030, 12, 31),
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    onFormatChanged: (format) =>
                        setState(() => _calendarFormat = format),
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    eventLoader: (day) =>
                        _getEventsForDay(day, displayedEvents),
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      leftChevronIcon: Icon(Icons.chevron_left_rounded,
                          color: AppColors.primary),
                      rightChevronIcon: Icon(Icons.chevron_right_rounded,
                          color: AppColors.primary),
                    ),
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.3),
                          shape: BoxShape.circle),
                      todayTextStyle: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold),
                      selectedDecoration: const BoxDecoration(
                          color: AppColors.primary, shape: BoxShape.circle),
                      markerDecoration: const BoxDecoration(
                          color: Colors.orange, shape: BoxShape.circle),
                    ),
                  ),
                ),

                // 2. SEARCH & FILTER
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _searchController,
                        onChanged: (value) =>
                            setState(() => _searchQuery = value),
                        decoration: InputDecoration(
                          hintText: "Cari event...",
                          prefixIcon:
                              const Icon(Icons.search, color: Colors.grey),
                          fillColor: Colors.white,
                          filled: true,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 0),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip("Semua"),
                            _buildFilterChip("BUDAYA"),
                            _buildFilterChip("OLAHRAGA"),
                            _buildFilterChip("PARIWISATA"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // 3. HEADER TOTAL
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Daftar Agenda",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      Text("${displayedEvents.length} Event Ditemukan",
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),

                // 4. LIST EVENT GABUNGAN
                Expanded(
                  child: displayedEvents.isEmpty
                      ? _buildEmptyState("Tidak ada event yang cocok")
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 5),
                          itemCount: displayedEvents.length,
                          itemBuilder: (context, index) {
                            final event = displayedEvents[index];

                            bool showHeader = false;
                            if (index == 0) {
                              showHeader = true;
                            } else {
                              final prevEvent = displayedEvents[index - 1];
                              String currMonth =
                                  _extractMonthName(event['tanggal']);
                              String prevMonth =
                                  _extractMonthName(prevEvent['tanggal']);
                              if (currMonth != prevMonth) showHeader = true;
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (showHeader)
                                  _buildMonthHeader(
                                      _extractMonthName(event['tanggal']),
                                      _extractYearOnly(event['tanggal'])),
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

  Widget _buildFilterChip(String label) {
    bool isSelected = _selectedCategoryFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (val) => setState(() => _selectedCategoryFilter = label),
        selectedColor: AppColors.primary.withOpacity(0.2),
        checkmarkColor: AppColors.primary,
        backgroundColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primary : Colors.grey[700],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
                color: isSelected ? AppColors.primary : Colors.transparent)),
      ),
    );
  }

  Widget _buildModernEventCard(Map<String, dynamic> event) {
    Color badgeColor = Colors.blue;
    String klasifikasi = (event['klasifikasi'] ?? '').toString().toUpperCase();
    String kategori = (event['kategori'] ?? '').toString().toUpperCase();

    if (klasifikasi.contains('NASIONAL') || kategori.contains('BUDAYA'))
      badgeColor = Colors.orange;
    if (klasifikasi.contains('INTERNASIONAL') || kategori.contains('OLAHRAGA'))
      badgeColor = Colors.green;

    bool isNew = event['is_new'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isNew ? Colors.blue.withOpacity(0.03) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isNew ? Border.all(color: Colors.blue.withOpacity(0.3)) : null,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5))
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 85,
                decoration:
                    BoxDecoration(color: AppColors.primary.withOpacity(0.08)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_extractDateOnly(event['tanggal']),
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary)),
                    Text(_extractYearOnly(event['tanggal']),
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary)),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                  color: badgeColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8)),
                              child: Text(
                                  klasifikasi.isEmpty ? kategori : klasifikasi,
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: badgeColor)),
                            ),
                            if (isNew) ...[
                              const SizedBox(width: 8),
                              const Text("BARU",
                                  style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue)),
                            ]
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(event['nama'],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                height: 1.2)),
                        const SizedBox(height: 8),
                        Row(children: [
                          Icon(Icons.location_on_rounded,
                              size: 14, color: Colors.grey[400]),
                          const SizedBox(width: 4),
                          Expanded(
                              child: Text(event['lokasi'],
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey[600]))),
                        ]),
                      ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthHeader(String monthName, String year) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 25, 10, 10),
      child: Row(
        children: [
          Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(4))),
          const SizedBox(width: 10),
          Text("$monthName $year",
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                  letterSpacing: 0.5)),
          const SizedBox(width: 10),
          Expanded(child: Container(height: 1, color: Colors.grey.shade200)),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.search_off_rounded, size: 50, color: Colors.grey.shade400),
        const SizedBox(height: 10),
        Text(message, style: TextStyle(color: Colors.grey.shade500)),
      ]),
    );
  }
}
