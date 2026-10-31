import 'package:flutter/material.dart';

class PageDasboard extends StatelessWidget {
  const PageDasboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selamat Datang!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text('Silakan pilih menu di bawah ini.'),
            const SizedBox(height: 25),

            // Tombol Data Siswa
            menuButton(
              context,
              'Data Siswa',
              Icons.school,
              '/siswa',
            ),

            // Tombol Data User
            menuButton(
              context,
              'Data User',
              Icons.people,
              '/user',
            ),

            // Tombol Input
            menuButton(
              context,
              'Input Data',
              Icons.add_box,
              '/input',
            ),

            // Tombol Edit
            menuButton(
              context,
              'Edit Data',
              Icons.edit,
              '/edit',
            ),
          ],
        ),
      ),
    );
  }

  Widget menuButton(
      BuildContext context,
      String judul,
      IconData ikon,
      String route,
      ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.pushNamed(context, route);
        },
        icon: Icon(ikon),
        label: Text(judul),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.all(16),
        ),
      ),
    );
  }
}