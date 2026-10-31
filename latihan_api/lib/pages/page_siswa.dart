import 'package:flutter/material.dart';

class PageSiswa extends StatefulWidget {
  const PageSiswa({super.key});

  @override
  State<PageSiswa> createState() => _PageSiswaState();
}

class _PageSiswaState extends State<PageSiswa> {
  // Data contoh siswa
  final List<Map<String, String>> siswa = [
    {
      'nipd': '1001',
      'nama': 'Andi',
      'kelas': 'XI RPL',
      'jurusan': 'RPL',
    },
    {
      'nipd': '1002',
      'nama': 'Budi',
      'kelas': 'X RPL',
      'jurusan': 'RPL',
    },
  ];

  // Hapus data siswa
  void hapusSiswa(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Siswa'),
        content: Text(
          'Yakin ingin menghapus ${siswa[index]['nama']}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                siswa.removeAt(index);
              });
              Navigator.pop(context);
            },
            child: const Text(
              'Hapus',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  // Tambah atau edit siswa
  void formSiswa({int? index}) {
    final nipd = TextEditingController(
      text: index == null ? '' : siswa[index]['nipd'],
    );
    final nama = TextEditingController(
      text: index == null ? '' : siswa[index]['nama'],
    );
    final kelas = TextEditingController(
      text: index == null ? '' : siswa[index]['kelas'],
    );
    final jurusan = TextEditingController(
      text: index == null ? '' : siswa[index]['jurusan'],
    );

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(index == null ? 'Tambah Siswa' : 'Edit Siswa'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nipd,
                decoration: const InputDecoration(labelText: 'NIPD'),
              ),
              TextField(
                controller: nama,
                decoration: const InputDecoration(labelText: 'Nama'),
              ),
              TextField(
                controller: kelas,
                decoration: const InputDecoration(labelText: 'Kelas'),
              ),
              TextField(
                controller: jurusan,
                decoration: const InputDecoration(labelText: 'Jurusan'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nipd.text.isEmpty ||
                  nama.text.isEmpty ||
                  kelas.text.isEmpty ||
                  jurusan.text.isEmpty) {
                return;
              }

              setState(() {
                final data = {
                  'nipd': nipd.text,
                  'nama': nama.text,
                  'kelas': kelas.text,
                  'jurusan': jurusan.text,
                };

                if (index == null) {
                  siswa.add(data);
                } else {
                  siswa[index] = data;
                }
              });

              Navigator.pop(dialogContext);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3FF),
      appBar: AppBar(
        title: const Text('Data Siswa'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),

      // Tombol tambah siswa
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => formSiswa(),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Siswa'),
      ),

      body: siswa.isEmpty
          ? const Center(child: Text('Belum ada data siswa'))
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: siswa.length,
        itemBuilder: (context, index) {
          final data = siswa[index];

          return Card(
            color: Colors.white,
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['nama']!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('NIPD: ${data['nipd']}'),
                  Text('Kelas: ${data['kelas']}'),
                  Text('Jurusan: ${data['jurusan']}'),
                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => formSiswa(index: index),
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => hapusSiswa(index),
                        icon: const Icon(Icons.delete),
                        label: const Text('Hapus'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}