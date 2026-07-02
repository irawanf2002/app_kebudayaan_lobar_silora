import 'package:cloud_firestore/cloud_firestore.dart';

class AgendaModel {
  // 🔥 FIX 1: ID diubah ke String? karena Firebase Document ID berupa teks
  final String? id;
  final String title;
  final String date;
  final String location;
  final String description;
  final String image;

  // Tambahan field pendukung untuk UI (Opsional, agar tidak error di widget)
  final String waktu;
  final String bulan;

  AgendaModel({
    this.id,
    required this.title,
    required this.date,
    required this.location,
    required this.description,
    required this.image,
    this.waktu = "19:30 WITA",
    this.bulan = "JAN",
  });

  // 🔥 FIX 2: Factory untuk mengambil data dari Cloud Firestore
  factory AgendaModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> json = doc.data() as Map<String, dynamic>;

    return AgendaModel(
      id: doc.id,
      title: json['title'] ?? json['nama'] ?? json['judul'] ?? '',
      date: json['date'] ?? json['tanggal'] ?? '',
      location: json['location'] ?? json['lokasi'] ?? '',
      description: json['description'] ?? json['deskripsi'] ?? '',
      image: json['image'] ??
          json['gambar'] ??
          json['imageUrl'] ??
          'https://via.placeholder.com/150',
      waktu: json['waktu'] ?? "19:30 WITA",
      bulan: json['bulan'] ?? "JAN",
    );
  }

  // 🔥 FIX 3: Method untuk mengirim data ke Firebase
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'date': date,
      'location': location,
      'description': description,
      'image': image,
      'waktu': waktu,
      'bulan': bulan,
    };
  }

  // Tetap sediakan fromJson untuk kompatibilitas data statis/API lain
  factory AgendaModel.fromJson(Map<String, dynamic> json) {
    return AgendaModel(
      id: json['id']?.toString(),
      title: json['title'] ?? json['judul'] ?? '',
      date: json['date'] ?? json['tanggal'] ?? '',
      location: json['location'] ?? json['lokasi'] ?? '',
      description: json['description'] ?? json['deskripsi'] ?? '',
      image:
          json['image'] ?? json['gambar'] ?? 'https://via.placeholder.com/150',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date,
      'location': location,
      'description': description,
      'image': image,
    };
  }
}
