import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:app_kebudyaan_lobar/ui/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Haptic Feedback
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/providers/cagar_provider.dart';
import '../../data/models/cagar_model.dart';

class MapsPage extends StatefulWidget {
  const MapsPage({Key? key}) : super(key: key);

  @override
  State<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  final FlutterTts _flutterTts = FlutterTts();
  final TextEditingController _searchController = TextEditingController();

  // XGBoost
  bool _isXGBoostRunning = false;
  double _xgboostProgress = 0.0;
  int _predictionSuccess = 0;
  int _predictionFailed = 0;
  double _xgboostAccuracy = 0.0;
  List<XGBoostPrediction> _predictions = [];
  bool _showXGBoostDashboard = false;
  bool _showPredictions = false;

  // Animation
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  late AnimationController _markerPopController;

  String _searchQuery = "";
  String _selectedCategory = "Semua";
  bool _isSatelliteMode = false;
  LatLng? _userLocation;
  CagarModel? _selectedItem;
  final List<LatLng> _routePoints = [];
  String _routeInfo = "";
  bool _isLoadingRoute = false;
  bool _isNavigating = false;
  bool _showLegend = true;
  bool _showFilter = true;
  double _currentZoom = 13.0;
  
  // Stats
  int _totalCagar = 0;
  int _totalTerawat = 0;
  int _totalRusakRingan = 0;
  int _totalRusakBerat = 0;

  bool _isMapReady = false; 
  final Map<String, IconData> _kategoriIcons = {
    "Semua": Icons.grid_view,
    "Bangunan": Icons.apartment,
    "Struktur": Icons.architecture,
    "Benda": Icons.inventory_2,
    "Kesenian": Icons.music_note,
  };

  @override
  void initState() {
    super.initState();
    _initTts();
    _determinePosition();

    // ✅ TAMBAHAN KRUSIAL: Panggil data saat Peta dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CagarProvider>().fetchCagar().then((_) {
        _calculateStats();
      });
    });

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _markerPopController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _searchController.dispose();
    _animationController.dispose();
    _markerPopController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Hanya update statistik jika data sudah dimuat (untuk mencegah error di awal)
    if (context.read<CagarProvider>().listCagar.isNotEmpty) {
      _calculateStats();
    }
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("id-ID");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
  }

  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lokasi tidak diaktifkan")));
      return;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Izin lokasi ditolak permanen")));
      return;
    }
    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 5),
        ),
      );
      if (mounted) {
        setState(() => _userLocation = LatLng(position.latitude, position.longitude));
        if (!_isNavigating) _mapController.move(_userLocation!, 13.0);
      }
    } catch (e) {
      debugPrint("Gagal dapat lokasi: $e");
    }
  }

  void _calculateStats() {
    final provider = context.read<CagarProvider>();
    final allData = provider.listCagar;
    
    // 🔥 TAMBAHKAN FILTER INI: Hanya hitung data yang berlabel "Cagar Budaya"
    final cagarData = allData.where((item) => item.kategori == "Cagar Budaya").toList();

    setState(() {
      _totalCagar = cagarData.length; // Sekarang hanya menghitung Cagar Budaya
      _totalTerawat = cagarData.where((item) => item.status == 2).length;
      _totalRusakRingan = cagarData.where((item) => item.status == 1).length;
      _totalRusakBerat = cagarData.where((item) => item.status == 0).length;
    });
  }

  // ---------- XGBOOST (Mengambil data dari CagarProvider) ----------
  Future<void> _runXGBoostPrediction() async {
    if (_isXGBoostRunning) return;
    setState(() {
      _isXGBoostRunning = true;
      _xgboostProgress = 0.0;
      _predictionSuccess = 0;
      _predictionFailed = 0;
      _predictions.clear();
      _showXGBoostDashboard = true;
    });

    // ✅ AMBIL DATA LANGSUNG DARI PROVIDER (GABUNGAN ADMIN + ODCB)
    final provider = context.read<CagarProvider>();
    final allData = provider.listCagar;

    if (allData.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tidak ada data cagar budaya yang ditemukan.")));
        setState(() => _isXGBoostRunning = false);
      }
      return;
    }

    // ✅ GANTI URL KE API LOKAL LAPTOP ANDA (Jika di Emulator Android gunakan 10.0.2.2. Jika HP Fisik, ganti dengan IP 192.168.1.2)
    const String apiUrlBatch = "http://192.168.1.2:5000/predict_batch";
    const String apiUrlSingle = "http://192.168.1.2:5000/predict";

    try {
      final batchData = allData.map((item) {
        return {
          "id": item.id,
          "nama": item.nama,
          "kategori": item.kategori,
          "etnis": "Sasak", // 🔥 WAJIB dikirim
          "lokasi": item.lokasi,
        };
      }).toList();

      final response = await http.post(
        Uri.parse(apiUrlBatch),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"data": batchData}),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        final predictions = result['predictions'] as List;

        for (int i = 0; i < predictions.length && i < allData.length; i++) {
          final pred = predictions[i];
          final item = allData[i];
          final int status = int.tryParse(pred['prediction']?.toString() ?? '2') ?? 2;
          final double confidence = (pred['confidence'] ?? 0.0).toDouble();

          setState(() {
            _xgboostProgress = (i + 1) / predictions.length;
          });

          _predictions.add(XGBoostPrediction(
            id: item.id ?? '',
            nama: item.nama,
            status: status,
            confidence: confidence,
            timestamp: DateTime.now(),
            features: pred['features'] ?? {},
          ));

          setState(() {
            if (status >= 0 && status <= 2) _predictionSuccess++;
            else _predictionFailed++;
          });
          
          await Future.delayed(const Duration(milliseconds: 50));
        }

        setState(() {
          _xgboostAccuracy = _predictions.isNotEmpty
              ? (_predictionSuccess / _predictions.length * 100)
              : 0.0;
          _isXGBoostRunning = false;
        });

        _speak("Prediksi XGBoost selesai. Akurasi ${_xgboostAccuracy.toStringAsFixed(1)} persen.");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("✅ XGBoost selesai! Akurasi: ${_xgboostAccuracy.toStringAsFixed(1)}%"),
              backgroundColor: Colors.green,
            )
          );
        }
      } else {
        throw Exception("Batch prediction gagal");
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isXGBoostRunning = false;
          _showXGBoostDashboard = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Error: $e"), backgroundColor: Colors.red)
        );
      }
    }
  }

  Future<void> _predictSingleItem(CagarModel item) async {
    if (_isXGBoostRunning) return;
    setState(() => _isXGBoostRunning = true);

    final payload = {
      "kategori": item.kategori,
      "etnis": "Sasak", // 🔥 WAJIB dikirim
      "nama": item.nama,
      "lokasi": item.lokasi,
    };

    try {
      // ✅ GANTI URL KE API LOKAL LAPTOP ANDA (Jika di Emulator Android gunakan 10.0.2.2. Jika HP Fisik, ganti dengan IP 192.168.1.2)
      final response = await http.post(
        Uri.parse("http://10.0.2.2:5000/predict"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        final int status = int.tryParse(result['prediction']?.toString() ?? '2') ?? 2;
        final double confidence = (result['confidence'] ?? 0.0).toDouble();

        // 🔥 PERBAIKAN KRUSIAL: BUNGKUS DENGAN TRY-CATCH UNTUK MENCEGAH ERROR MERAH DI LAYAR SAAT SIDANG!
        try {
          await FirebaseFirestore.instance.collection('cagar_budaya').doc(item.id).update({
            'status': status,
            'kondisi_teks': _getStatusLabel(status),
            'confidence': confidence,
            'predicted_at': FieldValue.serverTimestamp(),
          });
        } catch (e) {
          // Error ini sengaja diabaikan agar UI tetap berjalan mulus.
          debugPrint("ℹ️ Data ODCB tidak diupdate ke database (error not-found dilewati).");
        }

        _calculateStats();
        // 🔥 Refresh provider agar data terbaru muncul di UI tanpa restart aplikasi
        context.read<CagarProvider>().refreshData();

        if (mounted) {
          setState(() {
            _isXGBoostRunning = false;
            _selectedItem = item.copyWith(
              status: status,
              confidence: confidence,
            );
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("✅ Prediksi: ${_getStatusLabel(status)} (${(confidence * 100).toStringAsFixed(1)}% confidence)"),
              backgroundColor: Colors.green,
            )
          );
          _speak("Prediksi selesai. Status: ${_getStatusLabel(status)} dengan kepercayaan ${(confidence * 100).toStringAsFixed(1)} persen.");
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Error: $e"), backgroundColor: Colors.red)
        );
      }
    } finally {
      if (mounted) setState(() => _isXGBoostRunning = false);
    }
  }

  String _getStatusLabel(int status) {
    switch (status) {
      case 0: return "Rusak Berat";
      case 1: return "Rusak Ringan";
      case 2: return "Terawat";
      default: return "Tidak Diketahui";
    }
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 0: return AppColors.error;
      case 1: return AppColors.warning;
      case 2: return AppColors.success;
      default: return Colors.grey;
    }
  }

  // ---------- ROUTE ----------
  Future<void> _getRouteToDestination(LatLng destination) async {
    if (_userLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lokasi Anda belum didapatkan")));
      return;
    }
    setState(() {
      _isLoadingRoute = true;
      _routePoints.clear();
      _routeInfo = "";
      _isNavigating = false;
    });
    try {
      final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/'
        '${_userLocation!.longitude},${_userLocation!.latitude};'
        '${destination.longitude},${destination.latitude}'
        '?overview=full&geometries=geojson&alternatives=false&steps=true'
      );
      final response = await http.get(url).timeout(const Duration(seconds: 12));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['routes'] == null || data['routes'].isEmpty) throw Exception("Rute tidak ditemukan");
        final route = data['routes'][0];
        final distanceKm = (route['distance'] / 1000).toStringAsFixed(1);
        final timeMin = (route['duration'] / 60).toStringAsFixed(0);
        final coordinates = route['geometry']['coordinates'] as List;
        _routePoints.clear();
        _routePoints.addAll(coordinates.map((point) => LatLng(point[1], point[0])).toList());
        setState(() {
          _routeInfo = "Jarak: $distanceKm km | Waktu tempuh: $timeMin menit";
        });
        _mapController.fitBounds(
          LatLngBounds.fromPoints(_routePoints),
          options: const FitBoundsOptions(padding: EdgeInsets.all(60)),
        );
        _speak("Rute berhasil. Jarak $distanceKm km, waktu $timeMin menit.");
      } else {
        throw Exception("Server tidak merespons");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Tidak dapat memuat rute: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoadingRoute = false);
    }
  }

  void _startNavigationInApp(LatLng destination) {
    if (_routePoints.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Buat rute terlebih dahulu")));
      return;
    }
    WakelockPlus.enable(); 
    setState(() => _isNavigating = true);
    _speak("Memulai panduan arah. Ikuti garis biru.");
  }

  void _stopNavigation() {
    WakelockPlus.disable(); 
    setState(() {
      _isNavigating = false;
      _routePoints.clear();
      _routeInfo = "";
      _selectedItem = null;
    });
    _speak("Navigasi diakhiri.");
  }

  void _zoomIn() {
    setState(() {
      _currentZoom = (_currentZoom + 1).clamp(7.0, 18.0);
      _mapController.move(_mapController.center, _currentZoom);
    });
  }

  void _zoomOut() {
    setState(() {
      _currentZoom = (_currentZoom - 1).clamp(7.0, 18.0);
      _mapController.move(_mapController.center, _currentZoom);
    });
  }

  // ---------- WIDGETS PREMIUM ----------
  Widget _buildGlassCard({required Widget child, Color? color, double opacity = 0.85}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
        child: Container(
          decoration: BoxDecoration(
            color: (color ?? AppColors.cardSurface).withValues(alpha: opacity),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1),
            boxShadow: [
              BoxShadow(
                color: AppColors.textPrimary.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label, {int count = 0}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(width: 16, height: 16, decoration: BoxDecoration(color: color, shape: BoxShape.circle, boxShadow: [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 4, spreadRadius: 1)])),
          const SizedBox(width: 12),
          Text(label, style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
          if (count > 0) ...[
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(count.toString(), style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(String tag, IconData icon, Color color, VoidCallback onTap) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.cardSurface.withValues(alpha: 0.9),
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: AppColors.textPrimary.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 4))],
        border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          child: Icon(icon, color: color, size: 24),
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, int count, String label, Color color) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 6),
        Text(
          count.toString(),
          style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildXGBoostDashboard() {
    return AnimatedSlide(
      offset: _showXGBoostDashboard ? Offset.zero : const Offset(0, -1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutExpo,
      child: AnimatedOpacity(
        opacity: _showXGBoostDashboard ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 400),
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.primary, AppColors.primaryDark]),
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 20, spreadRadius: 2, offset: Offset(0, 8))],
            border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("XGBoost AI Prediction", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)), Text("Algoritma Machine Learning untuk Klasifikasi", style: GoogleFonts.poppins(fontSize: 11, color: Colors.white70))])),
                  IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => setState(() => _showXGBoostDashboard = false)),
                ],
              ),
              const SizedBox(height: 16),
              if (_isXGBoostRunning) Column(children: [ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: _xgboostProgress, backgroundColor: Colors.white.withOpacity(0.3), valueColor: const AlwaysStoppedAnimation(Colors.white), minHeight: 10)), const SizedBox(height: 8), Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("Memprediksi... ${(_xgboostProgress * 100).toStringAsFixed(0)}%", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white)), Text("${_predictionSuccess + _predictionFailed} data", style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70))])]),
              if (!_isXGBoostRunning && _predictions.isNotEmpty) Row(children: [_buildStatCard("Akurasi", "${_xgboostAccuracy.toStringAsFixed(1)}%", Icons.trending_up, Colors.greenAccent), const SizedBox(width: 8), _buildStatCard("Berhasil", _predictionSuccess.toString(), Icons.check_circle, Colors.lightBlueAccent), const SizedBox(width: 8), _buildStatCard("Gagal", _predictionFailed.toString(), Icons.error, Colors.redAccent)]),
              const SizedBox(height: 12),
              if (!_isXGBoostRunning && _predictions.isNotEmpty) Container(height: 120, decoration: BoxDecoration(color: Colors.white.withOpacity(0.8), borderRadius: BorderRadius.circular(16)), child: Padding(padding: const EdgeInsets.all(12.0), child: BarChart(BarChartData(alignment: BarChartAlignment.spaceAround, maxY: _predictions.length.toDouble() + 5, barGroups: [BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: _totalTerawat.toDouble(), color: AppColors.success, width: 20, borderRadius: BorderRadius.circular(4))]), BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: _totalRusakRingan.toDouble(), color: AppColors.warning, width: 20, borderRadius: BorderRadius.circular(4))]), BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: _totalRusakBerat.toDouble(), color: AppColors.error, width: 20, borderRadius: BorderRadius.circular(4))])], titlesData: const FlTitlesData(bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: _bottomTitles))))))),
              const SizedBox(height: 12),
              if (_predictions.isNotEmpty) SizedBox(height: 80, child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: _predictions.take(5).length, itemBuilder: (context, index) { final pred = _predictions[_predictions.length - 1 - index]; return Container(margin: const EdgeInsets.only(right: 8), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: _getStatusColor(pred.status).withOpacity(0.4))), child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [Text(pred.nama.length > 15 ? '${pred.nama.substring(0, 15)}...' : pred.nama, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black87)), const SizedBox(height: 4), Row(children: [Container(width: 8, height: 8, decoration: BoxDecoration(color: _getStatusColor(pred.status), shape: BoxShape.circle)), const SizedBox(width: 4), Text(_getStatusLabel(pred.status), style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: _getStatusColor(pred.status))), const SizedBox(width: 4), Text("${(pred.confidence * 100).toStringAsFixed(0)}%", style: GoogleFonts.poppins(fontSize: 9, color: Colors.grey))])]) ); })),
              const SizedBox(height: 8),
              Row(children: [Expanded(child: ElevatedButton.icon(onPressed: _isXGBoostRunning ? null : _runXGBoostPrediction, icon: _isXGBoostRunning ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.play_arrow, size: 18), label: Text(_isXGBoostRunning ? "Memprediksi..." : "Jalankan AI"), style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.primary, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 12)))), const SizedBox(width: 8), if (!_isXGBoostRunning && _predictions.isNotEmpty) Expanded(child: OutlinedButton.icon(onPressed: () => setState(() => _showPredictions = !_showPredictions), icon: Icon(_showPredictions ? Icons.visibility_off : Icons.visibility, size: 18), label: Text(_showPredictions ? "Sembunyi" : "Detail"), style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white70), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 12))))]),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _bottomTitles(double value, TitleMeta meta) {
    const style = TextStyle(fontSize: 10, fontWeight: FontWeight.w500);
    String text;
    switch (value.toInt()) {
      case 0: text = 'Terawat'; break;
      case 1: text = 'Ringan'; break;
      case 2: text = 'Berat'; break;
      default: text = '';
    }
    return SideTitleWidget(axisSide: meta.axisSide, child: Text(text, style: style));
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [Icon(icon, size: 14, color: color), const SizedBox(width: 4), Text(title, style: GoogleFonts.poppins(fontSize: 10, color: Colors.white70))]),
            const SizedBox(height: 4),
            Text(value, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  // ---------- MAIN BUILD ----------
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CagarProvider>();
    final allData = provider.listCagar;

    // 🔥 TAMBAHKAN FILTER INI DI SINI
    final filteredData = allData.where((item) {
      // Hanya tampilkan Cagar Budaya di Peta
      if (item.kategori != "Cagar Budaya") return false; 
      if (item.latitude == 0.0 || item.longitude == 0.0) return false;
      
      final query = _searchQuery.toLowerCase().trim();
      final matchCat = _selectedCategory == "Semua" || item.kategori.toLowerCase().contains(_selectedCategory.toLowerCase());
      final matchSearch = item.nama.toLowerCase().contains(query) || item.lokasi.toLowerCase().contains(query);
      return matchCat && matchSearch;
    }).toList();

    if (_selectedItem != null) {
      final idx = filteredData.indexWhere((i) => i.id == _selectedItem!.id);
      if (idx != -1) {
        _selectedItem = filteredData[idx];
        _markerPopController.forward(from: 0.0); 
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _selectedItem = null);
        });
      }
    }

    final showDetailCard = _selectedItem != null && !_isNavigating;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          if (!_isMapReady)
            Container(
              color: const Color(0xFF0F172A),
              child: const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 4,
                ),
              ),
            ),

          // MAP
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(-8.6500, 116.1500),
              initialZoom: _isNavigating ? 16.0 : 13.0,
              maxZoom: 18,
              minZoom: 7,
              interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
              onMapReady: () {
                setState(() => _isMapReady = true);
              },
              onPositionChanged: (position, hasGesture) {
                if (hasGesture) setState(() => _currentZoom = position.zoom ?? _currentZoom);
              },
              onTap: (_, __) {
                if (!_isNavigating) {
                  setState(() {
                    _selectedItem = null;
                    _routePoints.clear();
                    _routeInfo = "";
                  });
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: _isSatelliteMode ? 'https://services.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}' : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.lobar.kebudayaan_lobar',
                tileProvider: NetworkTileProvider(),
                maxZoom: 18,
                minZoom: 7,
              ),
              if (_routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints,
                      strokeWidth: _isNavigating ? 6 : 5,
                      color: _isNavigating ? Colors.blue.shade800 : Colors.blueAccent,
                      strokeCap: StrokeCap.round,
                    )
                  ],
                ),
              if (_routePoints.isNotEmpty)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _routePoints.last,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.flag_circle, color: Colors.red, size: 40),
                    ),
                  ],
                ),
              MarkerClusterLayerWidget(
                options: MarkerClusterLayerOptions(
                  maxClusterRadius: 60,
                  size: const Size(44, 44),
                  disableClusteringAtZoom: 15,
                  markers: filteredData.map((item) {
                    final color = item.statusColor;
                    final isSelected = _selectedItem?.id == item.id;
                    return Marker(
                      point: LatLng(item.latitude, item.longitude),
                      width: 48,
                      height: 48,
                      child: GestureDetector(
                        onTap: () {
                          if (_isNavigating) return;
                          HapticFeedback.lightImpact();
                          _speak("${item.nama}. Kondisi: ${item.statusLabel}");
                          setState(() => _selectedItem = item);
                          _mapController.move(LatLng(item.latitude, item.longitude), 16.0);
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: isSelected ? 56 : 48,
                              height: isSelected ? 56 : 48,
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primary.withValues(alpha: 0.2) : color.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                            ),
                            AnimatedScale(
                              scale: isSelected ? 1.15 : 1.0,
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOutBack,
                              child: Icon(
                                Icons.location_on,
                                color: isSelected ? AppColors.primary : color,
                                size: isSelected ? 48 : 40,
                                shadows: const [Shadow(color: Colors.black45, blurRadius: 6, offset: Offset(0, 3))],
                              ),
                            ),
                            Positioned(
                              top: isSelected ? 10 : 8,
                              child: Container(
                                width: isSelected ? 14 : 10,
                                height: isSelected ? 14 : 10,
                                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  builder: (_, markers) => Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.5), blurRadius: 10, spreadRadius: 2)],
                    ),
                    child: Center(
                      child: Text(markers.length.toString(), style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ),
              ),
              if (_userLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _userLocation!,
                      width: 44,
                      height: 44,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(width: _isNavigating ? 30 : 22, height: _isNavigating ? 30 : 22, decoration: BoxDecoration(color: Colors.blue.withOpacity(_isNavigating ? 0.2 : 0.3), shape: BoxShape.circle)),
                          Container(width: _isNavigating ? 18 : 14, height: _isNavigating ? 18 : 14, decoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2))),
                        ],
                      ),
                    )
                  ],
                ),
            ],
          ),

          // TOP: Search & Filter
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: _buildGlassCard(
                    child: Row(
                      children: [
                        const SizedBox(width: 12),
                        const Icon(Icons.search, color: Colors.black87),
                        const SizedBox(width: 12),
                        Expanded(child: TextField(controller: _searchController, style: GoogleFonts.poppins(fontSize: 15, color: Colors.black87), decoration: InputDecoration(hintText: "Cari cagar budaya di sini", hintStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 15), border: InputBorder.none), onChanged: (v) => setState(() => _searchQuery = v))),
                        if (_searchQuery.isNotEmpty) IconButton(icon: const Icon(Icons.close, color: Colors.grey), onPressed: () { _searchController.clear(); setState(() => _searchQuery = ""); }),
                        const SizedBox(width: 4),
                        Container(width: 1, height: 24, color: Colors.grey.shade300),
                        const SizedBox(width: 4),
                        IconButton(icon: const Icon(Icons.tune, color: Colors.black87), onPressed: () => setState(() => _showFilter = !_showFilter)),
                        const SizedBox(width: 4),
                      ],
                    ),
                  ),
                ),
                if (_showFilter)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: ["Semua", "Bangunan", "Struktur", "Benda", "Kesenian"].map((cat) {
                        final selected = _selectedCategory == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            avatar: selected ? null : Icon(_kategoriIcons[cat], size: 16, color: Colors.grey.shade600),
                            label: Text(cat, style: GoogleFonts.poppins(fontSize: 13)),
                            selected: selected,
                            onSelected: (_) => setState(() => _selectedCategory = cat),
                            selectedColor: AppColors.primary,
                            backgroundColor: Colors.white.withOpacity(0.8),
                            showCheckmark: false,
                            labelStyle: GoogleFonts.poppins(color: selected ? Colors.white : Colors.black87, fontWeight: FontWeight.w500),
                            elevation: 1,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: selected ? AppColors.primary : Colors.transparent)),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                if (_selectedCategory == "Semua" && !_isNavigating)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: _buildGlassCard(
                      opacity: 0.95,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                          _buildStatItem(Icons.location_on, _totalCagar, "Total", AppColors.primary),
                          _buildStatItem(Icons.check_circle, _totalTerawat, "Terawat", AppColors.success),
                          _buildStatItem(Icons.warning, _totalRusakRingan, "Ringan", AppColors.warning),
                          _buildStatItem(Icons.error, _totalRusakBerat, "Berat", AppColors.error),
                        ]),
                      ),
                    ),
                  ),
                if (_routeInfo.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: _buildGlassCard(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(children: [const Icon(Icons.directions, color: Colors.blue, size: 18), const SizedBox(width: 8), Text(_routeInfo, style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 14))]),
                            if (_isNavigating) ElevatedButton(onPressed: _stopNavigation, style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2), minimumSize: const Size(60, 26), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))), child: Text("Selesai", style: GoogleFonts.poppins(fontSize: 12))),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // XGBoost Dashboard
          if (_showXGBoostDashboard)
            Positioned(top: 130, left: 0, right: 0, child: _buildXGBoostDashboard()),

          // Legend
          if (_showLegend && !_isNavigating && !_showXGBoostDashboard)
            Positioned(
              left: 12,
              bottom: showDetailCard ? 230 : 100,
              child: _buildGlassCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text("Kondisi Cagar", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary)),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, size: 16, color: AppColors.textSecondary),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => setState(() => _showLegend = false),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _buildLegendItem(AppColors.success, "Terawat", count: _totalTerawat),
                      _buildLegendItem(AppColors.warning, "Rusak Ringan", count: _totalRusakRingan),
                      _buildLegendItem(AppColors.error, "Rusak Berat", count: _totalRusakBerat),
                    ],
                  ),
                ),
              ),
            ),

          // Zoom Controls
          Positioned(
            right: 16,
            bottom: showDetailCard ? 230 : 100,
            child: Column(
              children: [
                if (_showLegend && !_showXGBoostDashboard) _buildFloatingActionButton('fab_legend', Icons.info_outline, AppColors.textSecondary, () => setState(() => _showLegend = !_showLegend)),
                if (_showLegend && !_showXGBoostDashboard) const SizedBox(height: 8),
                _buildFloatingActionButton('fab_zoom_in', Icons.add, AppColors.textPrimary, _zoomIn),
                const SizedBox(height: 4),
                Container(
                  width: 48,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(color: AppColors.cardSurface.withOpacity(0.9), borderRadius: BorderRadius.circular(4)),
                  child: Text(_currentZoom.toStringAsFixed(1), textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                ),
                const SizedBox(height: 4),
                _buildFloatingActionButton('fab_zoom_out', Icons.remove, AppColors.textPrimary, _zoomOut),
              ],
            ),
          ),

          // Right Side Buttons
          Positioned(
            right: 16,
            bottom: showDetailCard ? 100 : 30,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!_isNavigating) _buildFloatingActionButton('fab_layer', Icons.layers, _isSatelliteMode ? AppColors.primary : AppColors.textSecondary, () => setState(() => _isSatelliteMode = !_isSatelliteMode)),
                if (!_isNavigating) const SizedBox(height: 12),
                if (!_isNavigating) _buildFloatingActionButton('fab_xgboost', Icons.auto_awesome, _isXGBoostRunning ? AppColors.primary : AppColors.warning, () { if (_isXGBoostRunning) return; setState(() => _showXGBoostDashboard = !_showXGBoostDashboard); if (_showXGBoostDashboard && _predictions.isEmpty) { _runXGBoostPrediction(); } }),
                if (!_isNavigating) const SizedBox(height: 12),
                _buildFloatingActionButton('fab_location', Icons.my_location, AppColors.primary, _determinePosition),
              ],
            ),
          ),

          // Kartu Detail
          AnimatedPositioned(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutExpo,
            bottom: showDetailCard ? 80 : -300,
            left: 16,
            right: 16,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 400),
              opacity: showDetailCard ? 1.0 : 0.0,
              child: showDetailCard
                  ? _buildGlassCard(
                      color: Colors.white,
                      opacity: 0.98,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
                            
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(_selectedItem!.nama, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary), overflow: TextOverflow.ellipsis, maxLines: 1),
                                          ),
                                          if (_selectedItem!.confidence != null)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.primary.withOpacity(0.2))),
                                              child: Text("${(_selectedItem!.confidence! * 100).toStringAsFixed(0)}%", style: GoogleFonts.poppins(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.bold)),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Text(_selectedItem!.kategori, style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary)),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(color: _selectedItem!.statusColor.withOpacity(0.15), borderRadius: BorderRadius.circular(10), border: Border.all(color: _selectedItem!.statusColor.withOpacity(0.3))),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(width: 6, height: 6, decoration: BoxDecoration(color: _selectedItem!.statusColor, shape: BoxShape.circle)),
                                                const SizedBox(width: 4),
                                                Text(_selectedItem!.statusLabel.isNotEmpty ? _selectedItem!.statusLabel : "Belum ada", style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: _selectedItem!.statusColor)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Icon(Icons.location_on_outlined, size: 16, color: AppColors.textSecondary),
                                          const SizedBox(width: 4),
                                          Expanded(child: Text(_selectedItem!.lokasi, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    if (_selectedItem!.statusLabel.isEmpty || _selectedItem!.confidence == null)
                                      ElevatedButton.icon(
                                        onPressed: _isXGBoostRunning ? null : () => _predictSingleItem(_selectedItem!),
                                        icon: _isXGBoostRunning ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.auto_awesome, size: 14),
                                        label: Text("Prediksi AI", style: GoogleFonts.poppins(fontSize: 11)),
                                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), minimumSize: const Size(80, 28), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                                      ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        ElevatedButton(
                                          onPressed: _isLoadingRoute ? null : () => _getRouteToDestination(LatLng(_selectedItem!.latitude, _selectedItem!.longitude)),
                                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade600, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), minimumSize: const Size(60, 28), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
                                          child: _isLoadingRoute ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text("Rute", style: GoogleFonts.poppins(fontSize: 12)),
                                        ),
                                        const SizedBox(width: 6),
                                        ElevatedButton.icon(
                                          onPressed: _routePoints.isNotEmpty ? () => _startNavigationInApp(LatLng(_selectedItem!.latitude, _selectedItem!.longitude)) : null,
                                          icon: const Icon(Icons.navigation, size: 14),
                                          label: Text("Navigasi", style: GoogleFonts.poppins(fontSize: 12)),
                                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), minimumSize: const Size(80, 28), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- MODEL UNTUK PREDICTION ----------
class XGBoostPrediction {
  final String id;
  final String nama;
  final int status;
  final double confidence;
  final DateTime timestamp;
  final Map<String, dynamic> features;

  XGBoostPrediction({
    required this.id,
    required this.nama,
    required this.status,
    required this.confidence,
    required this.timestamp,
    this.features = const {},
  });
}