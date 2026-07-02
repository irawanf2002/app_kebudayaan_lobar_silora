import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart'; // Ditambahkan untuk mendukung tipe data Color secara terpusat

class CagarModel {
  final String? id;
  final String nama;
  final String lokasi;
  final String deskripsi;
  final String gambarUrl;
  final String kategori;
  final double latitude;
  final double longitude;
  final String jamBuka;
  final String hargaTiket;
  final List<String> images;
  final int? status; // Variabel status kelayakan hasil klasifikasi mesin XGBoost

  CagarModel({
    this.id,
    required this.nama,
    required this.lokasi,
    required this.deskripsi,
    required this.gambarUrl,
    this.kategori = "Umum",
    this.latitude = -8.5833,
    this.longitude = 116.1167,
    this.jamBuka = "08:00 - 17:00",
    this.hargaTiket = "Gratis",
    this.images = const [],
    this.status = 2, // Default diatur ke 2 (Terawat jika merujuk pada dokumentasi Bab IV)
  });

  // Pemetaan aman dari Cloud Firestore (Dilengkapi null-safety check)
  factory CagarModel.fromFirestore(DocumentSnapshot doc) {
    // Menggunakan fallback map kosong {} jika data dokumen bernilai null
    final json = doc.data() as Map<String, dynamic>? ?? {};

    return CagarModel(
      id: doc.id,
      nama: json['nama'] ?? 'Tanpa Nama',
      lokasi: json['lokasi'] ?? '-',
      deskripsi: json['deskripsi'] ?? '',
      gambarUrl: json['gambar_url'] ?? 'https://via.placeholder.com/150',
      kategori: json['kategori'] ?? 'Umum',
      latitude: (json['latitude'] as num?)?.toDouble() ?? -8.5833,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 116.1167,
      jamBuka: json['jamBuka'] ?? '08:00 - 17:00',
      hargaTiket: json['hargaTiket'] ?? 'Gratis',
      images: List<String>.from(json['images'] ?? []),
      // Mapping field status secara aman dari database cloud
      status: json['status'] is int 
          ? json['status'] 
          : int.tryParse(json['status']?.toString() ?? '2'),
    );
  }

  // Pemetaan objek ke format map Cloud Firestore saat menyimpan data baru
  Map<String, dynamic> toFirestore() {
    return {
      'nama': nama,
      'lokasi': lokasi,
      'deskripsi': deskripsi,
      'gambar_url': gambarUrl,
      'kategori': kategori,
      'latitude': latitude,
      'longitude': longitude,
      'jamBuka': jamBuka,
      'hargaTiket': hargaTiket,
      'images': images,
      'status': status, // Memastikan status ikut tersimpan ke database
    };
  }

  // =========================================================================
  // GETTER LOGIKA CERDAS UNTUK KEMUDAHAN UI (PETA & HALAMAN DETAIL SILORA)
  // =========================================================================

  // Getter untuk konversi otomatis nilai integer menjadi teks status kondisi
  String get statusLabel {
    // CATATAN: Silakan sesuaikan urutan case angka di bawah ini 
    // dengan skema encoding yang Anda eksekusi di backend Python.
    switch (status) {
      case 0:
        return 'Rusak Berat';  // Sesuai Bab IV Skripsi Halaman 64 & 67
      case 1:
        return 'Rusak Ringan'; // Sesuai Bab IV Skripsi Halaman 64 & 67
      case 2:
        return 'Terawat';      // Sesuai Bab IV Skripsi Halaman 64 & 67
      default:
        return 'Tidak Diketahui';
    }
  }

  // Getter untuk menentukan warna secara dinamis berdasarkan nilai status
  Color get statusColor {
    switch (status) {
      case 0:
        return Colors.red;       // Warna Merah untuk kondisi kritis/rusak berat
      case 1:
        return Colors.amber;     // Warna Kuning/Oranye untuk rusak ringan
      case 2:
        return Colors.green;     // Warna Hijau untuk aset yang terawat baik
      default:
        return Colors.blue;      // Warna biru jika data status kosong
    }
  }
}