
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PageSiswa extends StatefulWidget {
  final String token;

  const PageSiswa({
    super.key,
    required this.token,
  });

  @override
  State<PageSiswa> createState() => _PageSiswaState();
}

class _PageSiswaState extends State<PageSiswa> {
  static const String apiUrl = 'http://localhost:3000/api/siswa';

  List<Map<String, dynamic>> siswa = [];
  String pencarian = '';
  bool loading = true;

  @override
  void initState() {
    super.initState();
    ambilSiswa();
  }

  Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${widget.token}',
  };

  void pesan(String message, {bool error = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? Colors.red : Colors.green,
      ),
    );
  }

  String bacaPesan(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      return data['message']?.toString() ??
          'Permintaan gagal (${response.statusCode})';
    } catch (_) {
      return 'Server mengembalikan HTTP ${response.statusCode}';
    }
  }

  // READ SISWA DARI DATABASE
  Future<void> ambilSiswa() async {
    if (mounted) setState(() => loading = true);

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: headers,
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw Exception(bacaPesan(response));
      }

      final result = jsonDecode(response.body);

      if (result['status'] != true || result['data'] is! List) {
        throw Exception('Format data siswa tidak sesuai');
      }

      if (!mounted) return;

      setState(() {
        siswa = (result['data'] as List)
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      });
    } catch (e) {
      pesan('Gagal mengambil siswa: $e', error: true);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  // TAMBAH ATAU EDIT SISWA
  Future<void> formSiswa({Map<String, dynamic>? dataLama}) async {
    final edit = dataLama != null;
    final id = dataLama?['id'];

    final nipd = TextEditingController(
      text: dataLama?['nipd']?.toString() ?? '',
    );
    final nama = TextEditingController(
      text: dataLama?['nama']?.toString() ?? '',
    );
    final alamat = TextEditingController(
      text: dataLama?['alamat']?.toString() ?? '',
    );
    final kelas = TextEditingController(
      text: dataLama?['kelas']?.toString() ?? '',
    );
    final jurusan = TextEditingController(
      text: dataLama?['jurusan']?.toString() ?? '',
    );

    String? jenisKelamin = dataLama?['jenis_kelamin']?.toString();
    if (!['Laki-laki', 'Perempuan'].contains(jenisKelamin)) {
      jenisKelamin = null;
    }

    final formKey = GlobalKey<FormState>();
    bool menyimpan = false;

    try {
      await showDialog(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              Widget kolom(
                String label,
                TextEditingController controller,
                IconData icon,
              ) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: label,
                      prefixIcon: Icon(icon),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value == null || value.trim().isEmpty
                            ? '$label wajib diisi'
                            : null,
                  ),
                );
              }

              return AlertDialog(
                title: Text(edit ? 'Edit Siswa' : 'Tambah Siswa'),
                content: SizedBox(
                  width: 420,
                  child: SingleChildScrollView(
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          kolom('NIPD', nipd, Icons.badge),
                          kolom('Nama Siswa', nama, Icons.person),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: DropdownButtonFormField<String>(
                              initialValue: jenisKelamin,
                              decoration: const InputDecoration(
                                labelText: 'Jenis Kelamin',
                                prefixIcon: Icon(Icons.people),
                                border: OutlineInputBorder(),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'Laki-laki',
                                  child: Text('Laki-laki'),
                                ),
                                DropdownMenuItem(
                                  value: 'Perempuan',
                                  child: Text('Perempuan'),
                                ),
                              ],
                              onChanged: menyimpan
                                  ? null
                                  : (value) {
                                      setDialogState(() {
                                        jenisKelamin = value;
                                      });
                                    },
                              validator: (value) =>
                                  value == null
                                      ? 'Pilih jenis kelamin'
                                      : null,
                            ),
                          ),
                          kolom('Alamat', alamat, Icons.home),
                          kolom('Kelas', kelas, Icons.class_),
                          kolom('Jurusan', jurusan, Icons.school),
                        ],
                      ),
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: menyimpan
                        ? null
                        : () => Navigator.pop(dialogContext),
                    child: const Text('Batal'),
                  ),
                  ElevatedButton.icon(
                    onPressed: menyimpan
                        ? null
                        : () async {
                            if (!formKey.currentState!.validate()) return;

                            setDialogState(() => menyimpan = true);

                            final body = {
                              'nipd': nipd.text.trim(),
                              'nama': nama.text.trim(),
                              'jenis_kelamin': jenisKelamin,
                              'alamat': alamat.text.trim(),
                              'kelas': kelas.text.trim(),
                              'jurusan': jurusan.text.trim(),
                            };

                            try {
                              final uri = Uri.parse(
                                edit ? '$apiUrl/$id' : apiUrl,
                              );

                              final response = edit
                                  ? await http.put(
                                      uri,
                                      headers: headers,
                                      body: jsonEncode(body),
                                    ).timeout(const Duration(seconds: 15))
                                  : await http.post(
                                      uri,
                                      headers: headers,
                                      body: jsonEncode(body),
                                    ).timeout(const Duration(seconds: 15));

                              if (response.statusCode < 200 ||
                                  response.statusCode >= 300) {
                                throw Exception(bacaPesan(response));
                              }

                              if (!dialogContext.mounted) return;
                              Navigator.pop(dialogContext);

                              pesan(edit
                                  ? 'Data siswa berhasil diperbarui'
                                  : 'Siswa berhasil ditambahkan');

                              await ambilSiswa();
                            } catch (e) {
                              pesan('Gagal menyimpan: $e', error: true);
                              if (dialogContext.mounted) {
                                setDialogState(() => menyimpan = false);
                              }
                            }
                          },
                    icon: const Icon(Icons.save),
                    label: Text(menyimpan ? 'Menyimpan...' : 'Simpan'),
                  ),
                ],
              );
            },
          );
        },
      );
    } finally {
      // Menunggu animasi dialog selesai sebelum dispose controller.
      await Future<void>.delayed(const Duration(milliseconds: 300));
      nipd.dispose();
      nama.dispose();
      alamat.dispose();
      kelas.dispose();
      jurusan.dispose();
    }
  }

  // DELETE SISWA DI DATABASE
  Future<void> hapusSiswa(Map<String, dynamic> data) async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Yakin ingin menghapus ${data['nama']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (konfirmasi != true) return;

    try {
      final response = await http.delete(
        Uri.parse('$apiUrl/${data['id']}'),
        headers: headers,
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        throw Exception(bacaPesan(response));
      }

      pesan('Siswa berhasil dihapus');
      await ambilSiswa();
    } catch (e) {
      pesan('Gagal menghapus: $e', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasil = siswa.where((data) {
      final keyword = pencarian.toLowerCase();

      return (data['nama'] ?? '')
              .toString()
              .toLowerCase()
              .contains(keyword) ||
          (data['nipd'] ?? '')
              .toString()
              .toLowerCase()
              .contains(keyword);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F3FF),
      appBar: AppBar(
        title: const Text('Manajemen Data Siswa'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: ambilSiswa,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Data Siswa',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text('Total Siswa: ${siswa.length}'),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText: 'Cari nama atau NIPD...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() => pencarian = value);
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => formSiswa(),
              icon: const Icon(Icons.add),
              label: const Text('Tambah Siswa'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : hasil.isEmpty
                      ? const Center(
                          child: Text('Data siswa tidak ditemukan'),
                        )
                      : ListView.builder(
                          itemCount: hasil.length,
                          itemBuilder: (context, index) {
                            final data = hasil[index];

                            return Card(
                              color: Colors.white,
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${data['nama'] ?? '-'}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text('NIPD: ${data['nipd'] ?? '-'}'),
                                    Text('Jenis Kelamin: ${data['jenis_kelamin'] ?? '-'}'),
                                    Text('Alamat: ${data['alamat'] ?? '-'}'),
                                    Text('Kelas: ${data['kelas'] ?? '-'}'),
                                    Text('Jurusan: ${data['jurusan'] ?? '-'}'),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.end,
                                      children: [
                                        OutlinedButton.icon(
                                          onPressed: () =>
                                              formSiswa(dataLama: data),
                                          icon: const Icon(Icons.edit),
                                          label: const Text('Edit'),
                                        ),
                                        const SizedBox(width: 8),
                                        ElevatedButton.icon(
                                          onPressed: () => hapusSiswa(data),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            foregroundColor: Colors.white,
                                          ),
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
            ),
          ],
        ),
      ),
    );
  }
}
