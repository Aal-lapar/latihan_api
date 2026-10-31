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
        '/': (context) => const PageLogin(),
        '/dashboard': (context) => const PageDasboard(),
        '/siswa': (context) => const PageSiswa(),
        '/user': (context) => const PageUser(),
        '/input': (context) => const PageInput(),
        '/edit': (context) => const PageEdit(),
      },
    );
  }
}