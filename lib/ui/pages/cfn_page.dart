import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_fonts/google_fonts.dart'; // ✅ Konsistensi Font Poppins
import 'dart:ui' as ui; // ✅ Untuk Glassmorphism
import '../styles/colors.dart'; // ✅ Menggunakan AppColors

// =========================================================================
// 1. DATA REAL JADWAL CFN 2026 (Sesuai PDF) - TIDAK DIUBAH
// =========================================================================
final List<Map<String, String>> _cfnData = [
  // --- JANUARI ---
  {'no': '1', 'tanggal': '3 JANUARI 2026', 'pengisi_acara': 'DLH (Dinas Lingkungan Hidup)', 'jenis_kesenian': 'Musik Jalanan & Edukasi Lingkungan (Kampanye OPLAS)', 'lokasi': 'Taman Kota Giri Menang', 'status': 'Terjadwal', 'waktu': '19:30 WITA'},
  {'no': '2', 'tanggal': '10 JANUARI 2026', 'pengisi_acara': 'DLH (Dinas Lingkungan Hidup)', 'jenis_kesenian': 'Musik Jalanan & Edukasi Lingkungan', 'lokasi': 'Taman Kota Giri Menang', 'status': 'Terjadwal', 'waktu': '19:30 WITA'},
  {'no': '3', 'tanggal': '17 JANUARI 2026', 'pengisi_acara': 'DLH (Dinas Lingkungan Hidup)', 'jenis_kesenian': 'Musik Jalanan & Edukasi Lingkungan', 'lokasi': 'Taman Kota Giri Menang', 'status': 'Terjadwal', 'waktu': '19:30 WITA'},
  {'no': '4', 'tanggal': '24 JANUARI 2026', 'pengisi_acara': 'Dinas PUPRPERKIM', 'jenis_kesenian': 'Musik Jalanan & Pelayanan PBG/RKKPR', 'lokasi': 'Taman Kota Giri Menang', 'status': 'Terjadwal', 'waktu': '19:30 WITA'},
  {'no': '5', 'tanggal': '31 JANUARI 2026', 'pengisi_acara': 'DAMKARMAT', 'jenis_kesenian': 'Edukasi Pencegahan Kebakaran & Pameran Evakuasi', 'lokasi': 'Taman Kota Giri Menang', 'status': 'Terjadwal', 'waktu': '19:30 WITA'},
  // --- FEBRUARI ---
  {'no': '6', 'tanggal': '7 FEBRUARI 2026', 'pengisi_acara': 'DPMPTSP', 'jenis_kesenian': 'Musik Jalanan & Pelayanan Perizinan', 'lokasi': 'Taman Kota Giri Menang', 'status': 'Terjadwal', 'waktu': '19:30 WITA'},
  {'no': '7', 'tanggal': '14 FEBRUARI 2026', 'pengisi_acara': 'DLH (Dinas Lingkungan Hidup)', 'jenis_kesenian': 'Edukasi Lingkungan & Kampanye OPLAS', 'lokasi': 'Taman Kota Giri Menang', 'status': 'Terjadwal', 'waktu': '19:30 WITA'},
  {'no': '8', 'tanggal': '21 FEBRUARI 2026', 'pengisi_acara': 'DLH (Hari Peduli Sampah Nasional)', 'jenis_kesenian': 'Musik Jalanan & Kampanye OPLAS', 'lokasi': 'Taman Kota Giri Menang', 'status': 'Terjadwal', 'waktu': '19:30 WITA'},
  {'no': '9', 'tanggal': '28 FEBRUARI 2026', 'pengisi_acara': 'Umum / Street Food', 'jenis_kesenian': 'CFN Sore / Ngabuburit Ramadan & Musik Jalanan', 'lokasi': 'Taman Kota Giri Menang', 'status': 'Terjadwal', 'waktu': '16:00 WITA'},
  // --- MARET ---
  {'no': '10', 'tanggal': '7 MARET 2026', 'pengisi_acara': 'DAMKARMAT (Hari Pemadam Kebakaran)', 'jenis_kesenian': 'CFN Sore / Ngabuburit Ramadan & Musik Jalanan', 'lokasi': 'Taman Kota Giri Menang', 'status': 'Terjadwal', 'waktu': '16:00 WITA'},
  {'no': '11', 'tanggal': '14 MARET 2026', 'pengisi_acara': 'SATPOL PP (Hari Jadi Satpol PP)', 'jenis_kesenian': 'CFN Sore / Ngabuburit Ramadan & Musik Jalanan', 'lokasi': 'Taman Kota Giri Menang', 'status': 'Terjadwal', 'waktu': '16:00 WITA'},
  {'no': '12', 'tanggal': '28 MARET 2026', 'pengisi_acara': 'DPMPTSP', 'jenis_kesenian': 'Musik Jalanan & Pelayanan Perizinan', 'lokasi': 'Taman Kota Giri Menang', 'status': 'Terjadwal', 'waktu': '19:30 WITA'},
  // --- APRIL ---
  {'no': '13', 'tanggal': '4 APRIL 2026', 'pengisi_acara': 'DAMKARMAT', 'jenis_kesenian': 'Edukasi Kebakaran & Pameran Penyelamatan', 'lokasi': 'Taman Kota Giri Menang', 'status': 'Terjadwal', 'waktu': '19:30 WITA'},
  {'no': '14', 'tanggal': '11 APRIL 2026', 'pengisi_acara': 'DPMPTSP', 'jenis_kesenian': 'Musik Jalanan & Pelayanan Perizinan', 'lokasi': 'Taman Kota Giri Menang', 'status': 'Terjadwal', 'waktu': '19:30 WITA'},
  {'no': '15', 'tanggal': '18 APRIL 2026', 'pengisi_acara': 'SELURUH OPD & KECAMATAN', 'jenis_kesenian': 'HUT Kabupaten Lombok Barat (Street Food)', 'lokasi': 'Taman Kota Giri Menang', 'status': 'Terjadwal', 'waktu': '19:30 WITA'},
  {'no': '16', 'tanggal': '25 APRIL 2026', 'pengisi_acara': 'KECAMATAN GERUNG', 'jenis_kesenian': 'HUT Kecamatan Gerung (Street Food)', 'lokasi': 'Taman Kota Giri Menang', 'status': 'Terjadwal', 'waktu': '19:30 WITA'},
  // --- MEI ---
  {'no': '17', 'tanggal': '2 MEI 2026', 'pengisi_acara': 'DIKBUD (Hari Pendidikan)', 'jenis_kesenian': 'Street Food & Edukasi Lingkungan', 'lokasi': 'Taman Kota Giri Menang', 'status': 'Terjadwal', 'waktu': '19:30 WITA'},
  {'no': '18', 'tanggal': '9 MEI 2026', 'pengisi_acara': 'RS AWET MUDA NARMADA', 'jenis_kesenian': 'Edukasi Kesehatan, Tari & Menyanyi', 'lokasi': 'Taman Kota Giri Menang', 'status': 'Terjadwal', 'waktu': '19:30 WITA'},
  {'no': '19', 'tanggal': '16 MEI 2026', 'pengisi_acara': 'DISARPUS (Hari Buku Nasional)', 'jenis_kesenian': 'Edukasi Literasi & Kampanye OPLAS', 'lokasi': 'Taman Kota Giri Menang', 'status': 'Terjadwal', 'waktu': '19:30 WITA'},
  {'no': '20', 'tanggal': '23 MEI 2026', 'pengisi_acara': 'DPMPTSP', 'jenis_kesenian': 'Pelayanan Perizinan & Edukasi Lingkungan', 'lokasi': 'Taman Kota Giri Menang', 'status': 'Terjadwal', 'waktu': '19:30 WITA'},
  {'no': '21', 'tanggal': '30 MEI 2026', 'pengisi_acara': 'Dinas PUPRPERKIM & DAMKARMAT', 'jenis_kesenian': 'Pelayanan PBG/RKKPR & Edukasi Kebakaran', 'lokasi': 'Taman Kota Giri Menang', 'status': 'Terjadwal', 'waktu': '19:30 WITA'},
  // --- JUNI ---
  {'no': '22', 'tanggal': '6 JUNI 2026', 'pengisi_acara': 'DLH (Hari Lingkungan Hidup)', 'jenis_kesenian': 'Edukasi Lingkungan & Kampanye OPLAS', 'lokasi': 'Taman Kota Giri Menang', 'status': 'Terjadwal', 'waktu': '19:30 WITA'},
  {'no': '23', 'tanggal': '13 JUNI 2026', 'pengisi_acara': 'Dinas PUPRPERKIM & DPMPTSP', 'jenis_kesenian': 'Pelayanan PBG, RKKPR & Perizinan', 'lokasi': 'Taman Kota Giri Menang', 'status': 'Terjadwal', 'waktu': '19:30 WITA'},
  {'no': '24', 'tanggal': '20 JUNI 2026', 'pengisi_acara': 'DAMKARMAT', 'jenis_kesenian': 'Edukasi Pencegahan Kebakaran & Evakuasi', 'lokasi': 'Taman Kota Giri Menang', 'status': 'Terjadwal', 'waktu': '19:30 WITA'},
  {'no': '25', 'tanggal': '27 JUNI 2026', 'pengisi_acara': 'DINSOS & P3A (Hari Keluarga Nasional)', 'jenis_kesenian': 'Street Food & Edukasi Keluarga', 'lokasi': 'Taman Kota Giri Menang', 'status': 'Terjadwal', 'waktu': '19:30 WITA'},
  // --- JULI ---
  {'no': '26', 'tanggal': '4 JULI 2026', 'pengisi_acara': 'BAPPERIDA', 'jenis_kesenian': 'Street Food & Edukasi Lingkungan', 'lokasi': 'Taman Kota Giri Menang', 'status': 'Terjadwal', 'waktu': '19:30 WITA'},
  {'no': '27', 'tanggal': '11 JULI 2026', 'pengisi_acara': 'DPMPTSP', 'jenis_kesenian': 'Pelayanan Perizinan & Edukasi Lingkungan', 'lokasi': 'Taman Kota Giri Menang', 'status': 'Terjadwal', 'waktu': '19:30 WITA'},
  {'no': '28', 'tanggal': '18 JULI 2026', 'pengisi_acara': 'DISPERINKOP NAKER (Hari Koperasi)', 'jenis_kesenian': 'Street Food & Edukasi Koperasi', 'lokasi': 'Taman Kota Giri Menang', 'status': 'Terjadwal', 'waktu': '19:30 WITA'},
  {'no': '29', 'tanggal': '25 JULI 2026', 'pengisi_acara': 'DAMKARMAT', 'jenis_kesenian': 'Edukasi Kebakaran & Pameran Penyelamatan', 'lokasi': 'Taman Kota Giri Menang', 'status': 'Terjadwal', 'waktu': '19:30 WITA'},
  // --- AGUSTUS ---
  {'no': '30', 'tanggal': '1 AGUSTUS 2026', 'pengisi_acara': 'Dinas PUPRPERKIM', 'jenis_kesenian': 'Pelayanan PBG & RKKPR', 'lokasi': 'Taman Kota Giri Menang', 'status': 'Terjadwal', 'waktu': '19:30 WITA'},
  {'no': '31', 'tanggal': '8 AGUSTUS 2026', 'pengisi_acara': 'DWP (Hari Dharma Wanita)', 'jenis_kesenian': 'Street Food & Edukasi Lingkungan', 'lokasi': 'Taman Kota Giri Menang', 'status': 'Terjadwal', 'waktu': '19:30 WITA'},
  {'no': '32', 'tanggal': '15 AGUSTUS 2026', 'pengisi_acara': 'DPMPTSP', 'jenis_kesenian': 'Pelayanan Perizinan & Musik Jalanan', 'lokasi': 'Taman Kota Giri Menang', 'status': 'Terjadwal', 'waktu': '19:30 WITA'},
  {'no': '33', 'tanggal': '22 AGUSTUS 2026', 'pengisi_acara': 'DAMKARMAT', 'jenis_kesenian': 'Edukasi Kebakaran & Pameran Evakuasi', 'lokasi': 'Taman Kota Giri Menang', 'status': 'Terjadwal', 'waktu': '19:30 WITA'},
  {'no': '34', 'tanggal': '29 AGUSTUS 2026', 'pengisi_acara': 'Dinas PUPRPERKIM (Hari Perumahan)', 'jenis_kesenian': 'Street Food & Edukasi Lingkungan', 'lokasi': 'Taman Kota Giri Menang', 'status': 'Terjadwal', 'waktu': '19:30 WITA'},
  // --- SEPTEMBER ---
  {'no': '35', 'tanggal': '5 SEPTEMBER 2026', 'pengisi_acara': 'DAMKARMAT', 'jenis_kesenian': 'Edukasi Kebakaran & Pameran Penyelamatan', 'lokasi': 'Taman Kota Giri Menang', 'status': 'Terjadwal', 'waktu': '19:30 WITA'},
  {'no': '36', 'tanggal': '12 SEPTEMBER 2026', 'pengisi_acara': 'DPMPTSP', 'jenis_kesenian': 'Pelayanan Perizinan & Musik Jalanan', 'lokasi': 'Taman Kota Giri Menang', 'status': 'Terjadwal', 'waktu': '19:30 WITA'},
  {'no': '37', 'tanggal': '19 SEPTEMBER 2026', 'pengisi_acara': 'DISHUB & Dinas PUPRPERKIM', 'jenis_kesenian': 'Hari Perhubungan & Pelayanan PBG', 'lokasi': 'Taman Kota Giri Menang', 'status': 'Terjadwal', 'waktu': '19:30 WITA'},
  {'no': '38', 'tanggal': '26 SEPTEMBER 2026', 'pengisi_acara': 'DINAS PERTANIAN & DISPAREKRAF', 'jenis_kesenian': 'Hari Tani & Hari Pariwisata Dunia', 'lokasi': 'Taman Kota Giri Menang', 'status': 'Terjadwal', 'waktu': '19:30 WITA'},
  // --- OKTOBER ---
  {'no': '39', 'tanggal': '3 OKTOBER 2026', 'pengisi_acara': 'DISPAREKRAF & PORA', 'jenis_kesenian': 'World Walking Day (Street Food)', 'lokasi': 'Taman Kota Giri Menang', 'status': 'Terjadwal', 'waktu': '19:30 WITA'},
  {'no': '40', 'tanggal': '10 OKTOBER 2026', 'pengisi_acara': 'DPMPTSP', 'jenis_kesenian': 'Pelayanan Perizinan & Musik Jalanan', 'lokasi': 'Taman Kota Giri Menang', 'status': 'Terjadwal', 'waktu': '19:30 WITA'},
  {'no': '41', 'tanggal': '17 OKTOBER 2026', 'pengisi_acara': 'DISLUTKANPANGAN (Hari Pangan)', 'jenis_kesenian': 'Street Food & Edukasi Lingkungan', 'lokasi': 'Taman Kota Giri Menang', 'status': 'Terjadwal', 'waktu': '19:30 WITA'},
  {'no': '42', 'tanggal': '24 OKTOBER 2026', 'pengisi_acara': 'DISPAREKRAF (Hari Ekonomi Kreatif)', 'jenis_kesenian': 'Pameran Ekonomi Kreatif & Edukasi Kebakaran', 'lokasi': 'Taman Kota Giri Menang', 'status': 'Terjadwal', 'waktu': '19:30 WITA'},
  {'no': '43', 'tanggal': '31 OKTOBER 2026', 'pengisi_acara': 'DINAS DUKCAPIL & Dinas PUPRPERKIM', 'jenis_kesenian': 'Sosialisasi Adminduk & Pelayanan PBG', 'lokasi': 'Taman Kota Giri Menang', 'status': 'Terjadwal', 'waktu': '19:30 WITA'},
  // --- NOVEMBER ---
  {'no': '44', 'tanggal': '7 NOVEMBER 2026', 'pengisi_acara': 'RS PATUH PATUT PATJU', 'jenis_kesenian': 'Street Food & Edukasi Kebakaran', 'lokasi': 'Taman Kota Giri Menang', 'status': 'Terjadwal', 'waktu': '19:30 WITA'},
  {'no': '45', 'tanggal': '14 NOVEMBER 2026', 'pengisi_acara': 'DINAS KESEHATAN (Hari Kesehatan)', 'jenis_kesenian': 'Edukasi Kesehatan & Lingkungan', 'lokasi': 'Taman Kota Giri Menang', 'status': 'Terjadwal', 'waktu': '19:30 WITA'},
  {'no': '46', 'tanggal': '21 NOVEMBER 2026', 'pengisi_acara': 'Dinas PUPRPERKIM & DISLUTKANPANGAN', 'jenis_kesenian': 'Pelayanan PBG & Edukasi Olahan Ikan (Band)', 'lokasi': 'Taman Kota Giri Menang', 'status': 'Terjadwal', 'waktu': '19:30 WITA'},
  {'no': '47', 'tanggal': '28 NOVEMBER 2026', 'pengisi_acara': 'DIKBUD (HUT PGRI) & DPMPTSP', 'jenis_kesenian': 'Street Food & Pelayanan Perizinan', 'lokasi': 'Taman Kota Giri Menang', 'status': 'Terjadwal', 'waktu': '19:30 WITA'},
  // --- DESEMBER ---
  {'no': '48', 'tanggal': '5 DESEMBER 2026', 'pengisi_acara': 'Dinas PUPRPERKIM (Hari Bakti PU)', 'jenis_kesenian': 'Pelayanan PBG & Edukasi Lingkungan', 'lokasi': 'Taman Kota Giri Menang', 'status': 'Terjadwal', 'waktu': '19:30 WITA'},
  {'no': '49', 'tanggal': '12 DESEMBER 2026', 'pengisi_acara': 'DPMPTSP', 'jenis_kesenian': 'Pelayanan Perizinan & Edukasi Lingkungan', 'lokasi': 'Taman Kota Giri Menang', 'status': 'Terjadwal', 'waktu': '19:30 WITA'},
  {'no': '50', 'tanggal': '19 DESEMBER 2026', 'pengisi_acara': 'DAMKARMAT', 'jenis_kesenian': 'Edukasi Kebakaran & Pameran Penyelamatan', 'lokasi': 'Taman Kota Giri Menang', 'status': 'Terjadwal', 'waktu': '19:30 WITA'},
  {'no': '51', 'tanggal': '26 DESEMBER 2026', 'pengisi_acara': 'DINSOS & P3A (Hari Kesetiakawanan)', 'jenis_kesenian': 'Street Food & Edukasi Lingkungan', 'lokasi': 'Taman Kota Giri Menang', 'status': 'Terjadwal', 'waktu': '19:30 WITA'},
];

// =========================================================================
// 2. HALAMAN UTAMA CoE CFN (PREMIUM SILORA STYLE)
// =========================================================================

class CfnPage extends StatefulWidget {
  final Function(int)? onNavTapped;
  const CfnPage({super.key, this.onNavTapped});

  @override
  State<CfnPage> createState() => _CfnPageState();
}

class _CfnPageState extends State<CfnPage> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now().year == 2026 ? DateTime.now() : DateTime(2026, 1, 3);
  DateTime? _selectedDay;

  final List<String> _monthNames = [
    "", "JANUARI", "FEBRUARI", "MARET", "APRIL", "MEI", "JUNI", "JULI", "AGUSTUS", "SEPTEMBER", "OKTOBER", "NOVEMBER", "DESEMBER"
  ];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  // --- LOGIKA PARSE TANGGAL STRING KE DATETIME ---
  DateTime? _parseDateFromStr(String dateStr) {
    try {
      List<String> parts = dateStr.split(' ');
      if (parts.length >= 3) {
        int day = int.parse(parts[0]);
        String monthName = parts[1].toUpperCase();
        int year = int.parse(parts[2]);
        int monthIndex = _monthNames.indexOf(monthName);
        if (monthIndex != -1) return DateTime(year, monthIndex, day);
      }
      return null;
    } catch (e) { return null; }
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    String monthName = _monthNames[day.month];
    String dayStr = day.day.toString();
    return _cfnData.where((item) {
      String eventDate = item['tanggal']!.toUpperCase();
      return eventDate.contains(monthName) && (eventDate.startsWith("$dayStr ") || eventDate.startsWith("0$dayStr "));
    }).toList();
  }

  void _onItemTapped(Map<String, String> item) {
    DateTime? eventDate = _parseDateFromStr(item['tanggal']!);
    if (eventDate != null) setState(() { _focusedDay = eventDate; _selectedDay = eventDate; });
    _showDetailModal(context, item);
  }

  // ✨ GLASSMORPHISM WRAPPER
  Widget _buildGlassCard({required Widget child, Color? color, double opacity = 0.85}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          decoration: BoxDecoration(
            color: (color ?? AppColors.cardSurface).withValues(alpha: opacity),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 20, offset: const Offset(0, 8))],
          ),
          child: child,
        ),
      ),
    );
  }

  // --- MODAL DETAIL (GLASSMORPHISM PREMIUM) ---
  void _showDetailModal(BuildContext context, Map<String, String> item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 50, height: 5,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Icon(Icons.nightlife, color: AppColors.primary, size: 28),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Car Free Night", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
                      Text(item['jenis_kesenian']!, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 40),
            _buildDetailRow(Icons.calendar_today, "Tanggal", item['tanggal']!),
            const SizedBox(height: 15),
            _buildDetailRow(Icons.access_time_filled, "Waktu", item['waktu'] ?? "19:00 WITA"),
            const SizedBox(height: 15),
            _buildDetailRow(Icons.groups, "Pengisi Acara", item['pengisi_acara']!),
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
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text("Tutup", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
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
              Text(label, style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
              Text(value, style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 15, color: Colors.black87)),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // ✅ Menggunakan AppColors
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.nights_stay, color: AppColors.primary, size: 20),
            const SizedBox(width: 10),
            Text("Car Free Night 2026", style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined, color: Colors.black87),
            onPressed: () {
              setState(() {
                _calendarFormat = _calendarFormat == CalendarFormat.week ? CalendarFormat.month : CalendarFormat.week;
              });
            },
          )
        ],
      ),
      body: Column(
        children: [
          // 1. CALENDAR STRIP
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(bottom: 15),
            child: TableCalendar(
              locale: 'id_ID',
              firstDay: DateTime(2025, 1, 1),
              lastDay: DateTime(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              availableCalendarFormats: const { CalendarFormat.month: 'Bulan', CalendarFormat.week: 'Minggu' },
              onFormatChanged: (format) => setState(() => _calendarFormat = format),
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() { _selectedDay = selectedDay; _focusedDay = focusedDay; });
              },
              eventLoader: _getEventsForDay,
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: GoogleFonts.poppins(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold),
                leftChevronIcon: Icon(Icons.chevron_left, color: AppColors.primary),
                rightChevronIcon: Icon(Icons.chevron_right, color: AppColors.primary),
              ),
              calendarStyle: CalendarStyle(
                defaultTextStyle: GoogleFonts.poppins(color: Colors.black87),
                weekendTextStyle: GoogleFonts.poppins(color: Colors.redAccent),
                outsideTextStyle: GoogleFonts.poppins(color: Colors.grey.shade400),
                todayDecoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                todayTextStyle: GoogleFonts.poppins(color: AppColors.primary, fontWeight: FontWeight.bold),
                selectedDecoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                selectedTextStyle: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
                markerDecoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
              ),
            ),
          ),

          // 2. HEADER LIST
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Semua Jadwal CFN", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                Text("${_cfnData.length} Event", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),

          // 3. LIST SEMUA JADWAL (DENGAN GLASSMORPHISM)
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

  // --- KARTU PREMIUM (GLASSMORPHISM) ---
  Widget _buildCleanCard(Map<String, String> item) {
    return GestureDetector(
      onTap: () => _onItemTapped(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.cardSurface.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
          border: Border(left: BorderSide(color: AppColors.primary, width: 5)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Waktu (Kiri)
              Column(
                children: [
                  Text(item['waktu']?.split(' ')[0] ?? '19:00', style: GoogleFonts.poppins(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.bold)),
                  Text("WITA", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 10)),
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
                    Text(item['pengisi_acara']!, maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(color: Colors.black87, fontSize: 15, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(item['jenis_kesenian']!, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(item['tanggal']!, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(color: Colors.grey, fontSize: 11)),
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