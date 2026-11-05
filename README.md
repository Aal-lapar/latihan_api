# Sistem Manajemen Sekolah

Project aplikasi manajemen sekolah menggunakan **Next.js sebagai backend REST API**, **Flutter sebagai frontend**, dan **MySQL sebagai database**.

## Teknologi

- Backend: Next.js, TypeScript
- Frontend: Flutter, Dart
- Database: MySQL
- Pengujian API: Postman
- Database Management: HeidiSQL

## Struktur Project

```text
latihan_api/
├── backend/       # REST API Next.js
├── frontend/      # Aplikasi Flutter
├── database/      # Struktur database MySQL
├── postman/       # Collection REST API
├── dokumentasi/   # Dokumentasi project
└── README.md
```

## Cara Menjalankan Backend

1. Pastikan Node.js dan MySQL sudah terinstal.
2. Masuk ke folder `backend`.
3. Jalankan `npm install`.
4. Buat file `.env.local` berdasarkan `.env.example`.
5. Isi konfigurasi database MySQL dan JWT Secret.
6. Jalankan `npm run dev`.

Alamat API: `http://localhost:3000`

## Cara Menjalankan Frontend

1. Pastikan Flutter SDK dan Android Studio sudah tersedia.
2. Buka folder `frontend` di Android Studio.
3. Jalankan `flutter pub get`.
4. Pastikan alamat API sesuai dengan perangkat yang digunakan.
5. Jalankan `flutter run`.

## Database

1. Buka HeidiSQL atau aplikasi pengelola MySQL.
2. Import file `database/schema.sql`.
3. Sesuaikan konfigurasi database di `backend/.env.local`.
4. Siapkan akun pengujian untuk mencoba fitur Login.

## Fitur REST API

- Login menggunakan JWT
- Menampilkan seluruh data pengguna
- Menampilkan pengguna berdasarkan ID
- Menambah, mengedit, dan menghapus pengguna
- Menampilkan seluruh data siswa
- Menampilkan siswa berdasarkan ID
- Menambah, mengedit, dan menghapus data siswa

## Dokumentasi Postman

Collection tersedia di:

`postman/APIsekolah2.postman_collection.json`

Import collection tersebut ke Postman untuk menguji endpoint API. Isi variabel autentikasi secara lokal dan jangan membagikan password atau token asli.

## Catatan Pengembangan

Backend sebelumnya dikembangkan menggunakan Express.js, kemudian dimigrasikan ke Next.js. Versi final menggunakan Next.js sebagai backend utama.