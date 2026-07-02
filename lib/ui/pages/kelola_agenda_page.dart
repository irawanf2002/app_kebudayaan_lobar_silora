import 'package:flutter/material.dart';

class KelolaAgendaPage extends StatelessWidget {
  const KelolaAgendaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text("Manajemen Agenda",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Aksi tambah event nanti di sini
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Fitur Tambah Event")));
        },
        backgroundColor: Colors.purple,
        icon: const Icon(Icons.calendar_month, color: Colors.white),
        label:
            const Text("Tambah Event", style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_note, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text(
              "Daftar event akan muncul di sini",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
