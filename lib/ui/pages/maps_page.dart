import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

import '../../data/providers/cagar_provider.dart';
import '../../data/models/cagar_model.dart';

class MapsPage extends StatefulWidget {
  const MapsPage({Key? key}) : super(key: key);

  @override
  State<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  final MapController _mapController = MapController();
  final FlutterTts _flutterTts = FlutterTts();
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = "";
  String _selectedCategory = "Semua";
  bool _isSatelliteMode = false;
  LatLng? _userLocation;
  CagarModel? _selectedItem;
  final List<LatLng> _routePoints = [];
  String _routeInfo = "";
  bool _isLoadingRoute = false;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    _initTts();
    _determinePosition();
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    _flutterTts.stop();
    _searchController.dispose();
    super.dispose();
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
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 5),
      );
      if (mounted) {
        setState(() => _userLocation = LatLng(position.latitude, position.longitude));
        if (!_isNavigating) _mapController.move(_userLocation!, 13.0);
      }
    } catch (e) {
      debugPrint("Gagal dapat lokasi: $e");
    }
  }

  Future<void> _sinkronisasiXGBoostBackend() async {
    final collection = FirebaseFirestore.instance.collection('cagar_budaya');
    const String apiUrl = "http://192.168.1.6:5000/predict";

    try {
      final snapshot = await collection.get();
      if (snapshot.docs.isEmpty) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tidak ada data untuk disinkronkan")));
        return;
      }

      int success = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final payload = {
          "kategori": data['kategori'] ?? "Bangunan",
          "nama": data['nama'] ?? "Budaya",
          "lokasi": data['lokasi'] ?? "Lombok",
        };

        try {
          final res = await http.post(
            Uri.parse(apiUrl),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(payload),
          ).timeout(const Duration(seconds: 8));

          if (res.statusCode == 200) {
            final result = jsonDecode(res.body);
            await doc.reference.update({
              'status': result['prediction'] ?? 'Tidak diketahui',
              'kondisi': result['label'] ?? 'Belum ditentukan',
            });
            success++;
          }
        } catch (e) {
          debugPrint("API Error: $e");
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Berhasil perbarui $success data")));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error sinkronisasi: $e")));
    }
  }

  // ✅ Fungsi Buat & Tampilkan RUTE DI DALAM APLIKASI
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
        _routePoints.addAll(
          coordinates.map((point) => LatLng(point[1], point[0])).toList()
        );

        setState(() {
          _routeInfo = "Jarak: $distanceKm km | Waktu tempuh: $timeMin menit";
        });

        _mapController.fitBounds(
          LatLngBounds.fromPoints(_routePoints),
          options: const FitBoundsOptions(padding: EdgeInsets.all(60)),
        );

        _speak("Rute berhasil dibuat. Jarak sekitar $distanceKm kilometer, waktu tempuh sekitar $timeMin menit.");
      } else {
        throw Exception("Server tidak merespons");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Tidak dapat memuat rute: ${e.toString()}")));
      }
    } finally {
      if (mounted) setState(() => _isLoadingRoute = false);
    }
  }

  // ✅ Fungsi MULAI NAVIGASI DI DALAM APLIKASI
  void _startNavigationInApp(LatLng destination) {
    if (_routePoints.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Buat rute terlebih dahulu")));
      return;
    }

    setState(() {
      _isNavigating = true;
    });

    _speak("Memulai panduan arah. Ikuti garis biru di peta untuk menuju tujuan.");
  }

  // ✅ Fungsi AKHIRI NAVIGASI
  void _stopNavigation() {
    setState(() {
      _isNavigating = false;
      _routePoints.clear();
      _routeInfo = "";
      _selectedItem = null;
    });
    _speak("Navigasi diakhiri.");
  }

  Widget _buildLegendItem(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(String tag, IconData icon, Color color, VoidCallback onTap) {
    return SizedBox(
      width: 48,
      height: 48,
      child: FloatingActionButton(
        heroTag: tag,
        backgroundColor: Colors.white,
        elevation: 3,
        highlightElevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        onPressed: onTap,
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CagarProvider>();
    final allData = provider.listCagar;

    final filteredData = allData.where((item) {
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
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _selectedItem = null);
        });
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF1F3F4),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(-8.6500, 116.1500),
              initialZoom: _isNavigating ? 16.0 : 13.0,
              maxZoom: 18,
              minZoom: 7,
              interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
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
                urlTemplate: _isSatelliteMode
                    ? 'https://services.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'
                    : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.lobar.kebudayaan_lobar',
                tileProvider: NetworkTileProvider(),
                maxZoom: 18,
                minZoom: 7,
                tileSize: 256,
                keepBuffer: 3,
                panBuffer: 1,
                fallbackUrl: 'https://a.tile.openstreetmap.org/{z}/{x}/{y}.png',
              ),

              // ✅ Garis Rute di Peta
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

              MarkerClusterLayerWidget(
                options: MarkerClusterLayerOptions(
                  maxClusterRadius: 60,
                  size: const Size(40, 40),
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
                          _speak("${item.nama}. Kondisi: ${item.statusLabel}");
                          setState(() => _selectedItem = item);
                          _mapController.move(LatLng(item.latitude, item.longitude), 16.0);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(
                                Icons.location_on,
                                color: isSelected ? Colors.purple : color,
                                size: isSelected ? 48 : 38,
                                shadows: const [Shadow(color: Colors.black38, blurRadius: 4, offset: Offset(0, 2))],
                              ),
                              Positioned(
                                top: isSelected ? 8 : 6,
                                child: Container(
                                  width: isSelected ? 14 : 10,
                                  height: isSelected ? 14 : 10,
                                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  builder: (_, markers) => Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.shade700,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Center(child: Text(markers.length.toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                  ),
                ),
              ),

              // ✅ Tanda Lokasi Pengguna
              if (_userLocation != null)
                MarkerLayer(markers: [
                  Marker(
                    point: _userLocation!,
                    width: 44,
                    height: 44,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: _isNavigating ? 30 : 22,
                          height: _isNavigating ? 30 : 22,
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(_isNavigating ? 0.2 : 0.3),
                            shape: BoxShape.circle
                          ),
                        ),
                        Container(
                          width: _isNavigating ? 18 : 14,
                          height: _isNavigating ? 18 : 14,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2)
                          ),
                        ),
                      ],
                    ),
                  )
                ]),
            ],
          ),

          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))],
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        const Icon(Icons.search, color: Colors.black87),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              hintText: "Cari cagar budaya di sini",
                              hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
                              border: InputBorder.none,
                            ),
                            onChanged: (v) => setState(() => _searchQuery = v),
                          ),
                        ),
                        if (_searchQuery.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.grey),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = "");
                            },
                          ),
                        const SizedBox(width: 4),
                        Container(width: 1, height: 24, color: Colors.grey.shade300),
                        const SizedBox(width: 4),
                        IconButton(icon: const Icon(Icons.mic, color: Colors.black87), onPressed: () {}),
                        const SizedBox(width: 4),
                      ],
                    ),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: ["Semua", "Bangunan", "Struktur", "Benda", "Kesenian"].map((cat) {
                      final selected = _selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(cat),
                          selected: selected,
                          onSelected: (_) => setState(() => _selectedCategory = cat),
                          selectedColor: const Color(0xFFE8F0FE),
                          backgroundColor: Colors.white,
                          showCheckmark: false,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(color: selected ? Colors.blue.shade200 : Colors.grey.shade300, width: 1),
                          ),
                          labelStyle: TextStyle(
                            color: selected ? Colors.blue.shade700 : Colors.black87,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                          elevation: 1,
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // ✅ Tampilan Info Jarak & Waktu
                if (_routeInfo.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _routeInfo,
                            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                          ),
                          if (_isNavigating)
                            ElevatedButton(
                              onPressed: _stopNavigation,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade600,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                minimumSize: const Size(60, 26),
                              ),
                              child: const Text("Selesai", style: TextStyle(fontSize: 12)),
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Legenda Kondisi
          if (!_isNavigating)
            Positioned(
              left: 12,
              bottom: _selectedItem != null ? 220 : 100,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 2))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Kondisi Cagar Budaya", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87)),
                    const SizedBox(height: 8),
                    _buildLegendItem(Colors.green, "Terawat"),
                    _buildLegendItem(Colors.orange, "Rusak Ringan"),
                    _buildLegendItem(Colors.red, "Rusak Berat"),
                  ],
                ),
              ),
            ),

          // Tombol Aksi Kanan
          Positioned(
            right: 16,
            bottom: _selectedItem != null ? 220 : 30,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!_isNavigating)
                  _buildFloatingActionButton('fab_layer', Icons.layers, _isSatelliteMode ? Colors.blue : Colors.black54, () => setState(() => _isSatelliteMode = !_isSatelliteMode)),
                if (!_isNavigating) const SizedBox(height: 12),
                if (!_isNavigating)
                  _buildFloatingActionButton('fab_sync', Icons.auto_awesome, Colors.deepOrange, _sinkronisasiXGBoostBackend),
                if (!_isNavigating) const SizedBox(height: 12),
                _buildFloatingActionButton('fab_location', Icons.my_location, Colors.blue, _determinePosition),
              ],
            ),
          ),

          // ✅ KARTU DETAIL MENGAMBANG (TIDAK TERTUTUP NAVIGASI BAWAH)
          if (_selectedItem != null && !_isNavigating)
            Positioned(
              bottom: 80,
              left: 16,
              right: 16,
              child: Container(
                constraints: const BoxConstraints(minHeight: 110, maxHeight: 180),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 12,
                      spreadRadius: 1,
                      offset: Offset(0, 2),
                    )
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedItem!.nama,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _selectedItem!.kategori,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(Icons.location_on_outlined, size: 16, color: Colors.grey.shade600),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      _selectedItem!.lokasi,
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 12),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: _selectedItem!.statusColor.withOpacity(0.12),
                                border: Border.all(color: _selectedItem!.statusColor.withOpacity(0.3)),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  const Text("XGBoost AI", style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 2),
                                  Text(
                                    _selectedItem!.statusLabel.isNotEmpty ? _selectedItem!.statusLabel : "Belum ada",
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _selectedItem!.statusColor),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),

                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: _isLoadingRoute
                                      ? null
                                      : () => _getRouteToDestination(LatLng(_selectedItem!.latitude, _selectedItem!.longitude)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue.shade600,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    minimumSize: const Size(60, 28),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                  ),
                                  child: _isLoadingRoute
                                      ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                      : const Text("Rute", style: TextStyle(fontSize: 12)),
                                ),
                                const SizedBox(width: 6),
                                ElevatedButton.icon(
                                  onPressed: _routePoints.isNotEmpty
                                      ? () => _startNavigationInApp(LatLng(_selectedItem!.latitude, _selectedItem!.longitude))
                                      : null,
                                  icon: const Icon(Icons.navigation, size: 14),
                                  label: const Text("Navigasi", style: TextStyle(fontSize: 12)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green.shade600,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    minimumSize: const Size(80, 28),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                  ),
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
            ),
        ],
      ),
    );
  }
}