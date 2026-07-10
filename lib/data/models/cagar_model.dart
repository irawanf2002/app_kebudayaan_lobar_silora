// cagar_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CagarModel {
  final String? id;
  final String nama;
  final String lokasi;
  final String alamatLengkap;
  final String deskripsi;
  final String gambarUrl;
  final String kategori;
  final double latitude;
  final double longitude;
  final String jamBuka;
  final String hargaTiket;
  final List<String> images;
  final int status;
  final double? confidence; // ✅ tambahkan

  CagarModel({
    this.id,
    required this.nama,
    required this.lokasi,
    this.alamatLengkap = '',
    required this.deskripsi,
    required this.gambarUrl,
    this.kategori = "Umum",
    this.latitude = -8.5833,
    this.longitude = 116.1167,
    this.jamBuka = "08:00 - 17:00",
    this.hargaTiket = "Gratis",
    this.images = const [],
    this.status = 2,
    this.confidence,
  });

  factory CagarModel.fromFirestore(DocumentSnapshot doc) {
    final json = doc.data() as Map<String, dynamic>? ?? {};
    int statusAkhir;
    final kondisiTeks = json['kondisi_teks']?.toString().toLowerCase().trim() ?? '';
    if (kondisiTeks.isNotEmpty) {
      if (kondisiTeks.contains('rusak berat')) statusAkhir = 0;
      else if (kondisiTeks.contains('rusak ringan')) statusAkhir = 1;
      else if (kondisiTeks.contains('terawat')) statusAkhir = 2;
      else statusAkhir = _parseStatus(json['status']);
    } else {
      statusAkhir = _parseStatus(json['status']);
    }
    double? confidence;
    if (json['confidence'] != null) {
      confidence = (json['confidence'] as num).toDouble();
    }
    return CagarModel(
      id: doc.id,
      nama: json['nama'] ?? 'Tanpa Nama',
      lokasi: json['lokasi'] ?? '-',
      alamatLengkap: json['alamat_lengkap'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      gambarUrl: json['gambar_url'] ?? 'https://via.placeholder.com/150',
      kategori: json['kategori'] ?? 'Umum',
      latitude: (json['latitude'] as num?)?.toDouble() ?? -8.5833,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 116.1167,
      jamBuka: json['jamBuka'] ?? '08:00 - 17:00',
      hargaTiket: json['hargaTiket'] ?? 'Gratis',
      images: List<String>.from(json['images'] ?? []),
      status: statusAkhir,
      confidence: confidence,
    );
  }

  static int _parseStatus(dynamic nilai) {
    if (nilai == null) return 2;
    if (nilai is int) return nilai;
    return int.tryParse(nilai.toString().trim()) ?? 2;
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nama': nama,
      'lokasi': lokasi,
      'alamat_lengkap': alamatLengkap,
      'deskripsi': deskripsi,
      'gambar_url': gambarUrl,
      'kategori': kategori,
      'latitude': latitude,
      'longitude': longitude,
      'jamBuka': jamBuka,
      'hargaTiket': hargaTiket,
      'images': images,
      'status': status,
      'confidence': confidence,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  CagarModel copyWith({
    String? id,
    String? nama,
    String? lokasi,
    String? alamatLengkap,
    String? deskripsi,
    String? gambarUrl,
    String? kategori,
    double? latitude,
    double? longitude,
    String? jamBuka,
    String? hargaTiket,
    List<String>? images,
    int? status,
    double? confidence,
  }) {
    return CagarModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      lokasi: lokasi ?? this.lokasi,
      alamatLengkap: alamatLengkap ?? this.alamatLengkap,
      deskripsi: deskripsi ?? this.deskripsi,
      gambarUrl: gambarUrl ?? this.gambarUrl,
      kategori: kategori ?? this.kategori,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      jamBuka: jamBuka ?? this.jamBuka,
      hargaTiket: hargaTiket ?? this.hargaTiket,
      images: images ?? this.images,
      status: status ?? this.status,
      confidence: confidence ?? this.confidence,
    );
  }

  String get statusLabel {
    switch (status) {
      case 0: return 'Rusak Berat';
      case 1: return 'Rusak Ringan';
      case 2: return 'Terawat';
      default: return 'Tidak Diketahui';
    }
  }

  Color get statusColor {
    switch (status) {
      case 0: return Colors.red;
      case 1: return Colors.amber;
      case 2: return Colors.green;
      default: return Colors.blue;
    }
  }
}