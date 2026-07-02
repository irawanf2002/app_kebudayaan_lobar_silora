import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../styles/colors.dart';

// =========================================================================
// 1. DATA REAL JADWAL CFN 2026 (Sesuai PDF)
// =========================================================================

final List<Map<String, String>> _cfnData = [
  // --- JANUARI ---
  {
    'no': '1',
    'tanggal': '3 JANUARI 2026',
    'pengisi_acara': 'DLH (Dinas Lingkungan Hidup)',
    'jenis_kesenian': 'Musik Jalanan & Edukasi Lingkungan (Kampanye OPLAS)',
    'lokasi': 'Taman Kota Giri Menang',
    'status': 'Terjadwal',
    'waktu': '19:30 WITA'
  },
  {
    'no': '2',
    'tanggal': '10 JANUARI 2026',
    'pengisi_acara': 'DLH (Dinas Lingkungan Hidup)',
    'jenis_kesenian': 'Musik Jalanan & Edukasi Lingkungan',
    'lokasi': 'Taman Kota Giri Menang',
    'status': 'Terjadwal',
    'waktu': '19:30 WITA'
  },
  {
    'no': '3',
    'tanggal': '17 JANUARI 2026',
    'pengisi_acara': 'DLH (Dinas Lingkungan Hidup)',
    'jenis_kesenian': 'Musik Jalanan & Edukasi Lingkungan',
    'lokasi': 'Taman Kota Giri Menang',
    'status': 'Terjadwal',
    'waktu': '19:30 WITA'
  },
  {
    'no': '4',
    'tanggal': '24 JANUARI 2026',
    'pengisi_acara': 'Dinas PUPRPERKIM',
    'jenis_kesenian': 'Musik Jalanan & Pelayanan PBG/RKKPR',
    'lokasi': 'Taman Kota Giri Menang',
    'status': 'Terjadwal',
    'waktu': '19:30 WITA'
  },
  {
    'no': '5',
    'tanggal': '31 JANUARI 2026',
    'pengisi_acara': 'DAMKARMAT',
    'jenis_kesenian': 'Edukasi Pencegahan Kebakaran & Pameran Evakuasi',
    'lokasi': 'Taman Kota Giri Menang',
    'status': 'Terjadwal',
    'waktu': '19:30 WITA'
  },

  // --- FEBRUARI ---
  {
    'no': '6',
    'tanggal': '7 FEBRUARI 2026',
    'pengisi_acara': 'DPMPTSP',
    'jenis_kesenian': 'Musik Jalanan & Pelayanan Perizinan',
    'lokasi': 'Taman Kota Giri Menang',
    'status': 'Terjadwal',
    'waktu': '19:30 WITA'
  },
  {
    'no': '7',
    'tanggal': '14 FEBRUARI 2026',
    'pengisi_acara': 'DLH (Dinas Lingkungan Hidup)',
    'jenis_kesenian': 'Edukasi Lingkungan & Kampanye OPLAS',
    'lokasi': 'Taman Kota Giri Menang',
    'status': 'Terjadwal',
    'waktu': '19:30 WITA'
  },
  {
    'no': '8',
    'tanggal': '21 FEBRUARI 2026',
    'pengisi_acara': 'DLH (Hari Peduli Sampah Nasional)',
    'jenis_kesenian': 'Musik Jalanan & Kampanye OPLAS',
    'lokasi': 'Taman Kota Giri Menang',
    'status': 'Terjadwal',
    'waktu': '19:30 WITA'
  },
  {
    'no': '9',
    'tanggal': '28 FEBRUARI 2026',
    'pengisi_acara': 'Umum / Street Food',
    'jenis_kesenian': 'CFN Sore / Ngabuburit Ramadan & Musik Jalanan',
    'lokasi': 'Taman Kota Giri Menang',
    'status': 'Terjadwal',
    'waktu': '16:00 WITA'
  },

  // --- MARET ---
  {
    'no': '10',
    'tanggal': '7 MARET 2026',
    'pengisi_acara': 'DAMKARMAT (Hari Pemadam Kebakaran)',
    'jenis_kesenian': 'CFN Sore / Ngabuburit Ramadan & Musik Jalanan',
    'lokasi': 'Taman Kota Giri Menang',
    'status': 'Terjadwal',
    'waktu': '16:00 WITA'
  },
  {
    'no': '11',
    'tanggal': '14 MARET 2026',
    'pengisi_acara': 'SATPOL PP (Hari Jadi Satpol PP)',
    'jenis_kesenian': 'CFN Sore / Ngabuburit Ramadan & Musik Jalanan',
    'lokasi': 'Taman Kota Giri Menang',
    'status': 'Terjadwal',
    'waktu': '16:00 WITA'
  },
  {
    'no': '12',
    'tanggal': '28 MARET 2026',
    'pengisi_acara': 'DPMPTSP',
    'jenis_kesenian': 'Musik Jalanan & Pelayanan Perizinan',
    'lokasi': 'Taman Kota Giri Menang',
    'status': 'Terjadwal',
    'waktu': '19:30 WITA'
  },

  // --- APRIL ---
  {
    'no': '13',
    'tanggal': '4 APRIL 2026',
    'pengisi_acara': 'DAMKARMAT',
    'jenis_kesenian': 'Edukasi Kebakaran & Pameran Penyelamatan',
    'lokasi': 'Taman Kota Giri Menang',
    'status': 'Terjadwal',
    'waktu': '19:30 WITA'
  },
  {
    'no': '14',
    'tanggal': '11 APRIL 2026',
    'pengisi_acara': 'DPMPTSP',
    'jenis_kesenian': 'Musik Jalanan & Pelayanan Perizinan',
    'lokasi': 'Taman Kota Giri Menang',
    'status': 'Terjadwal',
    'waktu': '19:30 WITA'
  },
  {
    'no': '15',
    'tanggal': '18 APRIL 2026',
    'pengisi_acara': 'SELURUH OPD & KECAMATAN',
    'jenis_kesenian': 'HUT Kabupaten Lombok Barat (Street Food)',
    'lokasi': 'Taman Kota Giri Menang',
    'status': 'Terjadwal',
    'waktu': '19:30 WITA'
  },
  {
    'no': '16',
    'tanggal': '25 APRIL 2026',
    'pengisi_acara': 'KECAMATAN GERUNG',
    'jenis_kesenian': 'HUT Kecamatan Gerung (Street Food)',
    'lokasi': 'Taman Kota Giri Menang',
    'status': 'Terjadwal',
    'waktu': '19:30 WITA'
  },

  // --- MEI ---
  {
    'no': '17',
    'tanggal': '2 MEI 2026',
    'pengisi_acara': 'DIKBUD (Hari Pendidikan)',
    'jenis_kesenian': 'Street Food & Edukasi Lingkungan',
    'lokasi': 'Taman Kota Giri Menang',
    'status': 'Terjadwal',
    'waktu': '19:30 WITA'
  },
  {
    'no': '18',
    'tanggal': '9 MEI 2026',
    'pengisi_acara': 'RS AWET MUDA NARMADA',
    'jenis_kesenian': 'Edukasi Kesehatan, Tari & Menyanyi',
    'lokasi': 'Taman Kota Giri Menang',
    'status': 'Terjadwal',
    'waktu': '19:30 WITA'
  },
  {
    'no': '19',
    'tanggal': '16 MEI 2026',
    'pengisi_acara': 'DISARPUS (Hari Buku Nasional)',
    'jenis_kesenian': 'Edukasi Literasi & Kampanye OPLAS',
    'lokasi': 'Taman Kota Giri Menang',
    'status': 'Terjadwal',
    'waktu': '19:30 WITA'
  },
  {
    'no': '20',
    'tanggal': '23 MEI 2026',
    'pengisi_acara': 'DPMPTSP',
    'jenis_kesenian': 'Pelayanan Perizinan & Edukasi Lingkungan',
    'lokasi': 'Taman Kota Giri Menang',
    'status': 'Terjadwal',
    'waktu': '19:30 WITA'
  },
  {
    'no': '21',
    'tanggal': '30 MEI 2026',
    'pengisi_acara': 'Dinas PUPRPERKIM & DAMKARMAT',
    'jenis_kesenian': 'Pelayanan PBG/RKKPR & Edukasi Kebakaran',
    'lokasi': 'Taman Kota Giri Menang',
    'status': 'Terjadwal',
    'waktu': '19:30 WITA'
  },

  // --- JUNI ---
  {
    'no': '22',
    'tanggal': '6 JUNI 2026',
    'pengisi_acara': 'DLH (Hari Lingkungan Hidup)',
    'jenis_kesenian': 'Edukasi Lingkungan & Kampanye OPLAS',
    'lokasi': 'Taman Kota Giri Menang',
    'status': 'Terjadwal',
    'waktu': '19:30 WITA'
  },
  {
    'no': '23',
    'tanggal': '13 JUNI 2026',
    'pengisi_acara': 'Dinas PUPRPERKIM & DPMPTSP',
    'jenis_kesenian': 'Pelayanan PBG, RKKPR & Perizinan',
    'lokasi': 'Taman Kota Giri Menang',
    'status': 'Terjadwal',
    'waktu': '19:30 WITA'
  },
  {
    'no': '24',
    'tanggal': '20 JUNI 2026',
    'pengisi_acara': 'DAMKARMAT',
    'jenis_kesenian': 'Edukasi Pencegahan Kebakaran & Evakuasi',
    'lokasi': 'Taman Kota Giri Menang',
    'status': 'Terjadwal',
    'waktu': '19:30 WITA'
  },
  {
    'no': '25',
    'tanggal': '27 JUNI 2026',
    'pengisi_acara': 'DINSOS & P3A (Hari Keluarga Nasional)',
    'jenis_kesenian': 'Street Food & Edukasi Keluarga',
    'lokasi': 'Taman Kota Giri Menang',
    'status': 'Terjadwal',
    'waktu': '19:30 WITA'
  },

  // --- JULI ---
  {
    'no': '26',
    'tanggal': '4 JULI 2026',
    'pengisi_acara': 'BAPPERIDA',
    'jenis_kesenian': 'Street Food & Edukasi Lingkungan',
    'lokasi': 'Taman Kota Giri Menang',
    'status': 'Terjadwal',
    'waktu': '19:30 WITA'
  },
  {
    'no': '27',
    'tanggal': '11 JULI 2026',
    'pengisi_acara': 'DPMPTSP',
    'jenis_kesenian': 'Pelayanan Perizinan & Edukasi Lingkungan',
    'lokasi': 'Taman Kota Giri Menang',
    'status': 'Terjadwal',
    'waktu': '19:30 WITA'
  },
  {
    'no': '28',
    'tanggal': '18 JULI 2026',
    'pengisi_acara': 'DISPERINKOP NAKER (Hari Koperasi)',
    'jenis_kesenian': 'Street Food & Edukasi Koperasi',
    'lokasi': 'Taman Kota Giri Menang',
    'status': 'Terjadwal',
    'waktu': '19:30 WITA'
  },
  {
    'no': '29',
    'tanggal': '25 JULI 2026',
    'pengisi_acara': 'DAMKARMAT',
    'jenis_kesenian': 'Edukasi Kebakaran & Pameran Penyelamatan',
    'lokasi': 'Taman Kota Giri Menang',
    'status': 'Terjadwal',
    'waktu': '19:30 WITA'
  },

  // --- AGUSTUS ---
  {
    'no': '30',
    'tanggal': '1 AGUSTUS 2026',
    'pengisi_acara': 'Dinas PUPRPERKIM',
    'jenis_kesenian': 'Pelayanan PBG & RKKPR',
    'lokasi': 'Taman Kota Giri Menang',
    'status': 'Terjadwal',
    'waktu': '19:30 WITA'
  },
  {
    'no': '31',
    'tanggal': '8 AGUSTUS 2026',
    'pengisi_acara': 'DWP (Hari Dharma Wanita)',
    'jenis_kesenian': 'Street Food & Edukasi Lingkungan',
    'lokasi': 'Taman Kota Giri Menang',
    'status': 'Terjadwal',
    'waktu': '19:30 WITA'
  },
  {
    'no': '32',
    'tanggal': '15 AGUSTUS 2026',
    'pengisi_acara': 'DPMPTSP',
    'jenis_kesenian': 'Pelayanan Perizinan & Musik Jalanan',
    'lokasi': 'Taman Kota Giri Menang',
    'status': 'Terjadwal',
    'waktu': '19:30 WITA'
  },
  {
    'no': '33',
    'tanggal': '22 AGUSTUS 2026',
    'pengisi_acara': 'DAMKARMAT',
    'jenis_kesenian': 'Edukasi Kebakaran & Pameran Evakuasi',
    'lokasi': 'Taman Kota Giri Menang',
    'status': 'Terjadwal',
    'waktu': '19:30 WITA'
  },
  {
    'no': '34',
    'tanggal': '29 AGUSTUS 2026',
    'pengisi_acara': 'Dinas PUPRPERKIM (Hari Perumahan)',
    'jenis_kesenian': 'Street Food & Edukasi Lingkungan',
    'lokasi': 'Taman Kota Giri Menang',
    'status': 'Terjadwal',
    'waktu': '19:30 WITA'
  },

  // --- SEPTEMBER ---
  {
    'no': '35',
    'tanggal': '5 SEPTEMBER 2026',
    'pengisi_acara': 'DAMKARMAT',
    'jenis_kesenian': 'Edukasi Kebakaran & Pameran Penyelamatan',
    'lokasi': 'Taman Kota Giri Menang',
    'status': 'Terjadwal',
    'waktu': '19:30 WITA'
  },
  {
    'no': '36',
    'tanggal': '12 SEPTEMBER 2026',
    'pengisi_acara': 'DPMPTSP',
    'jenis_kesenian': 'Pelayanan Perizinan & Musik Jalanan',
    'lokasi': 'Taman Kota Giri Menang',
    'status': 'Terjadwal',
    'waktu': '19:30 WITA'
  },
  {
    'no': '37',
    'tanggal': '19 SEPTEMBER 2026',
    'pengisi_acara': 'DISHUB & Dinas PUPRPERKIM',
    'jenis_kesenian': 'Hari Perhubungan & Pelayanan PBG',
    'lokasi': 'Taman Kota Giri Menang',
    'status': 'Terjadwal',
    'waktu': '19:30 WITA'
  },
  {
    'no': '38',
    'tanggal': '26 SEPTEMBER 2026',
    'pengisi_acara': 'DINAS PERTANIAN & DISPAREKRAF',
    'jenis_kesenian': 'Hari Tani & Hari Pariwisata Dunia',
    'lokasi': 'Taman Kota Giri Menang',
    'status': 'Terjadwal',
    'waktu': '19:30 WITA'
  },

  // --- OKTOBER ---
  {
    'no': '39',
    'tanggal': '3 OKTOBER 2026',
    'pengisi_acara': 'DISPAREKRAF & PORA',
    'jenis_kesenian': 'World Walking Day (Street Food)',
    'lokasi': 'Taman Kota Giri Menang',
    'status': 'Terjadwal',
    'waktu': '19:30 WITA'
  },
  {
    'no': '40',
    'tanggal': '10 OKTOBER 2026',
    'pengisi_acara': 'DPMPTSP',
    'jenis_kesenian': 'Pelayanan Perizinan & Musik Jalanan',
    'lokasi': 'Taman Kota Giri Menang',
    'status': 'Terjadwal',
    'waktu': '19:30 WITA'
  },
  {
    'no': '41',
    'tanggal': '17 OKTOBER 2026',
    'pengisi_acara': 'DISLUTKANPANGAN (Hari Pangan)',
    'jenis_kesenian': 'Street Food & Edukasi Lingkungan',
    'lokasi': 'Taman Kota Giri Menang',
    'status': 'Terjadwal',
    'waktu': '19:30 WITA'
  },
  {
    'no': '42',
    'tanggal': '24 OKTOBER 2026',
    'pengisi_acara': 'DISPAREKRAF (Hari Ekonomi Kreatif)',
    'jenis_kesenian': 'Pameran Ekonomi Kreatif & Edukasi Kebakaran',
    'lokasi': 'Taman Kota Giri Menang',
    'status': 'Terjadwal',
    'waktu': '19:30 WITA'
  },
  {
    'no': '43',
    'tanggal': '31 OKTOBER 2026',
    'pengisi_acara': 'DINAS DUKCAPIL & Dinas PUPRPERKIM',
    'jenis_kesenian': 'Sosialisasi Adminduk & Pelayanan PBG',
    'lokasi': 'Taman Kota Giri Menang',
    'status': 'Terjadwal',
    'waktu': '19:30 WITA'
  },

  // --- NOVEMBER ---
  {
    'no': '44',
    'tanggal': '7 NOVEMBER 2026',
    'pengisi_acara': 'RS PATUH PATUT PATJU',
    'jenis_kesenian': 'Street Food & Edukasi Kebakaran',
    'lokasi': 'Taman Kota Giri Menang',
    'status': 'Terjadwal',
    'waktu': '19:30 WITA'
  },
  {
    'no': '45',
    'tanggal': '14 NOVEMBER 2026',
    'pengisi_acara': 'DINAS KESEHATAN (Hari Kesehatan)',
    'jenis_kesenian': 'Edukasi Kesehatan & Lingkungan',
    'lokasi': 'Taman Kota Giri Menang',
    'status': 'Terjadwal',
    'waktu': '19:30 WITA'
  },
  {
    'no': '46',
    'tanggal': '21 NOVEMBER 2026',
    'pengisi_acara': 'Dinas PUPRPERKIM & DISLUTKANPANGAN',
    'jenis_kesenian': 'Pelayanan PBG & Edukasi Olahan Ikan (Band)',
    'lokasi': 'Taman Kota Giri Menang',
    'status': 'Terjadwal',
    'waktu': '19:30 WITA'
  },
  {
    'no': '47',
    'tanggal': '28 NOVEMBER 2026',
    'pengisi_acara': 'DIKBUD (HUT PGRI) & DPMPTSP',
    'jenis_kesenian': 'Street Food & Pelayanan Perizinan',
    'lokasi': 'Taman Kota Giri Menang',
    'status': 'Terjadwal',
    'waktu': '19:30 WITA'
  },

  // --- DESEMBER ---
  {
    'no': '48',
    'tanggal': '5 DESEMBER 2026',
    'pengisi_acara': 'Dinas PUPRPERKIM (Hari Bakti PU)',
    'jenis_kesenian': 'Pelayanan PBG & Edukasi Lingkungan',
    'lokasi': 'Taman Kota Giri Menang',
    'status': 'Terjadwal',
    'waktu': '19:30 WITA'
  },
  {
    'no': '49',
    'tanggal': '12 DESEMBER 2026',
    'pengisi_acara': 'DPMPTSP',
    'jenis_kesenian': 'Pelayanan Perizinan & Edukasi Lingkungan',
    'lokasi': 'Taman Kota Giri Menang',
    'status': 'Terjadwal',
    'waktu': '19:30 WITA'
  },
  {
    'no': '50',
    'tanggal': '19 DESEMBER 2026',
    'pengisi_acara': 'DAMKARMAT',
    'jenis_kesenian': 'Edukasi Kebakaran & Pameran Penyelamatan',
    'lokasi': 'Taman Kota Giri Menang',
    'status': 'Terjadwal',
    'waktu': '19:30 WITA'
  },
  {
    'no': '51',
    'tanggal': '26 DESEMBER 2026',
    'pengisi_acara': 'DINSOS & P3A (Hari Kesetiakawanan)',
    'jenis_kesenian': 'Street Food & Edukasi Lingkungan',
    'lokasi': 'Taman Kota Giri Menang',
    'status': 'Terjadwal',
    'waktu': '19:30 WITA'
  },
];

// =========================================================================
// 2. HALAMAN UTAMA CoE CFN (CLEAN WHITE STYLE)
// =========================================================================

class CfnPage extends StatefulWidget {
  final Function(int)? onNavTapped;
  const CfnPage({super.key, this.onNavTapped});

  @override
  State<CfnPage> createState() => _CfnPageState();
}

class _CfnPageState extends State<CfnPage> {
  // Warna Tema Khusus Light Mode (Clean)
  final Color _bgLight = const Color(0xFFF8F9FA); // Putih Abu
  final Color _accentColor = const Color(0xFF3F51B5); // Indigo Elegan
  final Color _weekendColor = Colors.redAccent;

  CalendarFormat _calendarFormat = CalendarFormat.week;

  DateTime _focusedDay = DateTime.now().year == 2026
      ? DateTime.now()
      : DateTime(2026, 1, 3); // Default ke Januari 2026
  DateTime? _selectedDay;

  final List<String> _monthNames = [
    "",
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

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  // --- LOGIKA PARSE TANGGAL STRING KE DATETIME ---
  DateTime? _parseDateFromStr(String dateStr) {
    try {
      // Format: "7 FEBRUARI 2026"
      List<String> parts = dateStr.split(' ');
      if (parts.length >= 3) {
        int day = int.parse(parts[0]);
        String monthName = parts[1].toUpperCase();
        int year = int.parse(parts[2]);

        int monthIndex = _monthNames.indexOf(monthName);
        if (monthIndex != -1) {
          return DateTime(year, monthIndex, day);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Helper: Marker Titik di Kalender
  List<dynamic> _getEventsForDay(DateTime day) {
    String monthName = _monthNames[day.month];
    String dayStr = day.day.toString();
    return _cfnData.where((item) {
      String eventDate = item['tanggal']!.toUpperCase();
      return eventDate.contains(monthName) &&
          (eventDate.startsWith("$dayStr ") ||
              eventDate.startsWith("0$dayStr "));
    }).toList();
  }

  // --- INTERAKSI KLIK ---
  void _onItemTapped(Map<String, String> item) {
    // 1. Pindahkan Kalender
    DateTime? eventDate = _parseDateFromStr(item['tanggal']!);
    if (eventDate != null) {
      setState(() {
        _focusedDay = eventDate;
        _selectedDay = eventDate;
      });
    }

    // 2. Tampilkan Detail
    _showDetailModal(context, item);
  }

  // --- MODAL DETAIL (THEME PUTIH) ---
  void _showDetailModal(BuildContext context, Map<String, String> item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white, // Putih
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Icon(Icons.nightlife, color: _accentColor, size: 28),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Car Free Night",
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade600)),
                      Text(item['jenis_kesenian']!,
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary)),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 40),
            _buildDetailRow(Icons.calendar_today, "Tanggal", item['tanggal']!),
            const SizedBox(height: 15),
            _buildDetailRow(Icons.access_time_filled, "Waktu",
                item['waktu'] ?? "19:00 WITA"),
            const SizedBox(height: 15),
            _buildDetailRow(
                Icons.groups, "Pengisi Acara", item['pengisi_acara']!),
            const SizedBox(height: 15),
            _buildDetailRow(Icons.location_on, "Lokasi", item['lokasi']!),
            const SizedBox(height: 15),
            _buildDetailRow(Icons.info_outline, "Status", item['status']!),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accentColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Tutup",
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(fontSize: 11, color: Colors.grey)),
              Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                      color: Colors.black87)),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight, // Background Putih/Abu
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.nights_stay, color: _accentColor, size: 20),
            const SizedBox(width: 10),
            const Text("Car Free Night 2026",
                style: TextStyle(
                    color: Colors.black87, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined,
                color: Colors.black87),
            onPressed: () {
              setState(() {
                _calendarFormat = _calendarFormat == CalendarFormat.week
                    ? CalendarFormat.month
                    : CalendarFormat.week;
              });
            },
          )
        ],
      ),
      body: Column(
        children: [
          // 1. CALENDAR STRIP (LIGHT THEME)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(bottom: 15),
            child: TableCalendar(
              locale: 'id_ID',
              firstDay: DateTime(2025, 1, 1),
              lastDay: DateTime(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              availableCalendarFormats: const {
                CalendarFormat.month: 'Bulan',
                CalendarFormat.week: 'Minggu',
              },
              onFormatChanged: (format) =>
                  setState(() => _calendarFormat = format),
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                // Jangan paksa update filter di sini agar list tetap menampilkan semua
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              eventLoader: _getEventsForDay,
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
                leftChevronIcon:
                    Icon(Icons.chevron_left, color: Colors.black87),
                rightChevronIcon:
                    Icon(Icons.chevron_right, color: Colors.black87),
              ),
              calendarStyle: CalendarStyle(
                defaultTextStyle: const TextStyle(color: Colors.black87),
                weekendTextStyle: TextStyle(color: _weekendColor),
                outsideTextStyle: TextStyle(color: Colors.grey.shade400),
                todayDecoration: BoxDecoration(
                    color: _accentColor.withOpacity(0.1),
                    shape: BoxShape.circle),
                todayTextStyle:
                    TextStyle(color: _accentColor, fontWeight: FontWeight.bold),
                selectedDecoration:
                    BoxDecoration(color: _accentColor, shape: BoxShape.circle),
                selectedTextStyle: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
                markerDecoration: const BoxDecoration(
                    color: Colors.orange, shape: BoxShape.circle),
              ),
            ),
          ),

          // 2. HEADER LIST
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Semua Jadwal CFN",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  "${_cfnData.length} Event",
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),

          // 3. LIST SEMUA JADWAL
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _cfnData.length,
              itemBuilder: (context, index) {
                return _buildCleanCard(_cfnData[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- KARTU CLEAN (GAYA BARU) ---
  Widget _buildCleanCard(Map<String, String> item) {
    return GestureDetector(
      onTap: () => _onItemTapped(item), // INTERAKSI PINDAH KALENDER
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4))
            ],
            // Garis Aksen di sebelah kiri (Indigo)
            border: Border(
              left: BorderSide(color: _accentColor, width: 4),
            )),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Waktu (Kiri)
              Column(
                children: [
                  Text(item['waktu']?.split(' ')[0] ?? '19:00',
                      style: TextStyle(
                          color: _accentColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  const Text("WITA",
                      style: TextStyle(color: Colors.grey, fontSize: 10)),
                ],
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                height: 40,
                width: 1,
                color: Colors.grey.shade200,
              ),

              // Info (Kanan)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['pengisi_acara']!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.black87,
                            fontSize:
                                15, // Font size sedikit dikecilkan agar muat
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(item['jenis_kesenian']!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                            fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.calendar_today,
                            size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(item['tanggal']!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 11)),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 14)
            ],
          ),
        ),
      ),
    );
  }
}
