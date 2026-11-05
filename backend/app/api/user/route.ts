
import db from '@/lib/db';
import { verifyToken, unauthorized } from '@/lib/auth';
import bcrypt from 'bcryptjs';
import type { RowDataPacket, ResultSetHeader } from 'mysql2';

export const runtime = 'nodejs';

// ======================================
// GET SEMUA USER
// ======================================
export async function GET(request: Request) {
  if (!verifyToken(request)) {
    return unauthorized();
  }

  try {
    const [rows] = await db.query<RowDataPacket[]>(
      `SELECT id, nama, email, status
       FROM users
       ORDER BY id DESC`
    );

    return Response.json({
      status: true,
      message: 'Data user berhasil diambil',
      data: rows
    });

  } catch (error) {
    console.error('GET USER ERROR:', error);

    return Response.json({
      status: false,
      message: 'Gagal mengambil data user'
    }, { status: 500 });
  }
}

// ======================================
// POST TAMBAH USER
// ======================================
export async function POST(request: Request) {
  if (!verifyToken(request)) {
    return unauthorized();
  }

  // Khusus latihan dengan data dummy.
  if (process.env.NODE_ENV !== 'development') {
    return Response.json({
      status: false,
      message: 'Pengelolaan user belum tersedia untuk produksi'
    }, { status: 403 });
  }

  const body = await request.json().catch(() => null);
  const { nama, email, password, status } = body ?? {};

  if (
    typeof nama !== 'string' ||
    !nama.trim()
  ) {
    return Response.json({
      status: false,
      message: 'Nama wajib diisi'
    }, { status: 400 });
  }

  if (
    typeof email !== 'string' ||
    !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email.trim())
  ) {
    return Response.json({
      status: false,
      message: 'Format email tidak valid'
    }, { status: 400 });
  }

  if (
    typeof password !== 'string' ||
    password.length < 6
  ) {
    return Response.json({
      status: false,
      message: 'Password minimal 6 karakter'
    }, { status: 400 });
  }

  const userStatus = status ?? 'Aktif';

  if (!['Aktif', 'Nonaktif'].includes(userStatus)) {
    return Response.json({
      status: false,
      message: 'Status harus Aktif atau Nonaktif'
    }, { status: 400 });
  }

  try {
    const [existing] = await db.execute<RowDataPacket[]>(
      'SELECT id FROM users WHERE email = ?',
      [email.trim()]
    );

    if (existing.length > 0) {
      return Response.json({
        status: false,
        message: 'Email sudah digunakan'
      }, { status: 409 });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const [result] = await db.execute<ResultSetHeader>(
      `INSERT INTO users
       (nama, email, password, status)
       VALUES (?, ?, ?, ?)`,
      [
        nama.trim(),
        email.trim(),
        hashedPassword,
        userStatus
      ]
    );

    return Response.json({
      status: true,
      message: 'User berhasil ditambahkan',
      data: {
        id: result.insertId,
        nama: nama.trim(),
        email: email.trim(),
        status: userStatus
      }
    }, { status: 201 });

  } catch (error) {
    console.error('POST USER ERROR:', error);

    if (
      error instanceof Error &&
      'code' in error &&
      error.code === 'ER_DUP_ENTRY'
    ) {
      return Response.json({
        status: false,
        message: 'Email sudah digunakan'
      }, { status: 409 });
    }

    return Response.json({
      status: false,
      message: 'Gagal menambahkan user'
    }, { status: 500 });
  }
}
