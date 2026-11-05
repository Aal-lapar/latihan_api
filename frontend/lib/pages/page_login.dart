
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PageLogin extends StatefulWidget {
  const PageLogin({super.key});

  @override
  State<PageLogin> createState() => _PageLoginState();
}

class _PageLoginState extends State<PageLogin> {
  final email = TextEditingController();
  final password = TextEditingController();

  bool isLoading = false;
  bool showPassword = false;

  // ALAMAT API NEXT.JS
  static const String apiUrl =
      'http://localhost:3000/api/login';

  // FUNGSI LOGIN
  Future<void> login() async {
    if (email.text.trim().isEmpty ||
        password.text.isEmpty) {
      tampilPesan('Email dan Password wajib diisi');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http
          .post(
            Uri.parse(apiUrl),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'email': email.text.trim(),
              'password': password.text,
            }),
          )
          .timeout(const Duration(seconds: 15));

      final result = jsonDecode(response.body);

      if (!mounted) return;

      if (response.statusCode == 200 &&
          result is Map<String, dynamic> &&
          result['status'] == true) {

        // AMBIL TOKEN DARI BACKEND
        final token = result['data']?['token'];

        if (token is! String || token.isEmpty) {
          tampilPesan('Token login tidak ditemukan');
          return;
        }

        // KIRIM TOKEN KE DASHBOARD
        Navigator.pushReplacementNamed(
          context,
          '/dashboard',
          arguments: token,
        );
      } else {
        tampilPesan(
          result is Map<String, dynamic>
              ? result['message']?.toString() ?? 'Login gagal'
              : 'Login gagal',
        );
      }
    } catch (e) {
      if (!mounted) return;

      debugPrint('LOGIN ERROR: $e');

      tampilPesan(
        'Tidak dapat terhubung ke server. '
        'Pastikan backend berjalan.',
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // PESAN ERROR
  void tampilPesan(String pesan) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(pesan),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3FF),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // LOGO
                const Icon(
                  Icons.account_circle_outlined,
                  size: 90,
                  color: Colors.deepPurple,
                ),

                const SizedBox(height: 20),

                const Text(
                  'Silakan login untuk melanjutkan',
                  style: TextStyle(fontSize: 16),
                ),

                const SizedBox(height: 35),

                // INPUT EMAIL
                TextField(
                  controller: email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),

                const SizedBox(height: 18),

                // INPUT PASSWORD
                TextField(
                  controller: password,
                  obscureText: !showPassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          showPassword = !showPassword;
                        });
                      },
                      icon: Icon(
                        showPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // TOMBOL LOGIN
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: isLoading ? null : login,
                    child: isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'LOGIN',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
