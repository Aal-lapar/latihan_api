
import 'package:flutter/material.dart';

import 'pages/page_login.dart';
import 'pages/page_dasboard.dart';
import 'pages/page_siswa.dart';
import 'pages/page_user.dart';
import 'pages/page_input.dart';
import 'pages/page_edit.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aplikasi Guru',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        // LOGIN
        '/': (context) => const PageLogin(),

        // DASHBOARD
        '/dashboard': (context) => const PageDasboard(),

        // DATA SISWA
        '/siswa': (context) {
          final token =
              ModalRoute.of(context)?.settings.arguments;

          if (token is String && token.isNotEmpty) {
            return PageSiswa(token: token);
          }

          return const Scaffold(
            body: Center(
              child: Text(
                'Sesi login tidak ditemukan.\n'
                'Silakan login kembali.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        },

        // DATA USER
        '/user': (context) {
          final token =
              ModalRoute.of(context)?.settings.arguments;

          if (token is String && token.isNotEmpty) {
            return PageUser(token: token);
          }

          return const Scaffold(
            body: Center(
              child: Text(
                'Sesi login tidak ditemukan.\n'
                'Silakan login kembali.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        },

        // HALAMAN TAMBAH DAN EDIT
        '/input': (context) => const PageInput(),
        '/edit': (context) => const PageEdit(),
      },
    );
  }
}
