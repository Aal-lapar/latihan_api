
import 'package:flutter/material.dart';

class PageDasboard extends StatelessWidget {
  const PageDasboard({super.key});

  @override
  Widget build(BuildContext context) {
    // Ambil token yang dikirim dari halaman login
    final args = ModalRoute.of(context)?.settings.arguments;
    final String? token = args is String ? args : null;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F3FF),

      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/',
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            const Text(
              'Selamat Datang!',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),

            const SizedBox(height: 30),

            // MENU UTAMA
            const Text(
              'Menu Utama',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            // CARD DATA SISWA
            menuCard(
              context,
              judul: 'Data Siswa',
              deskripsi: 'Kelola data siswa, tambah, edit, dan hapus.',
              ikon: Icons.school,
              route: '/siswa',
              token: token,
            ),

            const SizedBox(height: 16),

            // CARD DATA USER
            menuCard(
              context,
              judul: 'Data User',
              deskripsi: 'Lihat dan kelola data pengguna.',
              ikon: Icons.people,
              route: '/user',
              token: token,
            ),
          ],
        ),
      ),
    );
  }

  // WIDGET CARD MENU
  Widget menuCard(
    BuildContext context, {
    required String judul,
    required String deskripsi,
    required IconData ikon,
    required String route,
    required String? token,
  }) {
    return Card(
      elevation: 3,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Pastikan token tersedia
          if (token == null || token.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Sesi login tidak ditemukan. Silakan login kembali.',
                ),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }

          // Kirim token ke Data Siswa atau Data User
          Navigator.pushNamed(
            context,
            route,
            arguments: token,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // ICON
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  ikon,
                  size: 32,
                  color: Colors.deepPurple,
                ),
              ),

              const SizedBox(width: 16),

              // TEXT
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      judul,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      deskripsi,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.deepPurple,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
