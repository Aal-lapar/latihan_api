
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PageUser extends StatefulWidget {
  final String token;

  const PageUser({
    super.key,
    required this.token,
  });

  @override
  State<PageUser> createState() => _PageUserState();
}

class _PageUserState extends State<PageUser> {
  static const String apiUrl = 'http://localhost:3000/api/user';

  List<Map<String, dynamic>> dataUser = [];
  bool loading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    ambilUser();
  }

  Future<void> ambilUser() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
      ).timeout(const Duration(seconds: 15));

      final result = jsonDecode(response.body);

      if (response.statusCode != 200 ||
          result['status'] != true) {
        throw Exception(
          result['message'] ?? 'Gagal mengambil data pengguna',
        );
      }

      if (result['data'] is! List) {
        throw const FormatException(
          'Format data pengguna tidak sesuai',
        );
      }

      if (!mounted) return;

      setState(() {
        dataUser = (result['data'] as List)
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3FF),
      appBar: AppBar(
        title: const Text('Data User'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: ambilUser,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          errorMessage!,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: ambilUser,
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                )
              : dataUser.isEmpty
                  ? const Center(
                      child: Text('Belum ada data pengguna'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: dataUser.length,
                      itemBuilder: (context, index) {
                        final user = dataUser[index];

                        return Card(
                          color: Colors.white,
                          child: ListTile(
                            leading: const CircleAvatar(
                              child: Icon(Icons.person),
                            ),
                            title: Text(
                              '${user['nama'] ?? '-'}',
                            ),
                            subtitle: Text(
                              '${user['email'] ?? '-'}\n'
                              'Status: ${user['status'] ?? '-'}',
                            ),
                            isThreeLine: true,
                          ),
                        );
                      },
                    ),
    );
  }
}
