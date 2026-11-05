
import db from '@/lib/db';
import { verifyToken, unauthorized } from '@/lib/auth';
import bcrypt from 'bcryptjs';
import type { RowDataPacket, ResultSetHeader } from 'mysql2';

export const runtime = 'nodejs';

type Context = {
  params: Promise<{ id: string }>;
};

interface User extends RowDataPacket {
  id: number;
  nama: string;
  email: string;
  status: string;
}

function validId(id: string) {
  return /^[1-9]\d*$/.test(id);
}

function errorServer(error: unknown) {
  console.error('USER ERROR:', error);

  return Response.json({
    status: false,
    message: 'Terjadi kesalahan pada server'
  }, { status: 500 });
}

// ======================================
// GET USER BERDASARKAN ID
// ======================================
export async function GET(
  request: Request,
  context: Context
) {
  if (!verifyToken(request)) return unauthorized();

  const { id } = await context.params;

  if (!validId(id)) {
    return Response.json({
      status: false,
      message: 'ID tidak valid'
    }, { status: 400 });
  }

  try {
    const [rows] = await db.execute<User[]>(
      `SELECT id, nama, email, status
       FROM users
       WHERE id = ?`,
      [id]
    );

    if (rows.length === 0) {
      return Response.json({
        status: false,
        message: 'User tidak ditemukan'
      }, { status: 404 });
    }

    return Response.json({
      status: true,
      message: 'Data user berhasil diambil',
      data: rows[0]
    });

  } catch (error) {
    return errorServer(error);
  }
}

// ======================================
// PUT EDIT USER
// ======================================
export async function PUT(
  request: Request,
  context: Context
) {
  if (!verifyToken(request)) return unauthorized();

  const { id } = await context.params;

  if (!validId(id)) {
    return Response.json({
      status: false,
      message: 'ID tidak valid'
    }, { status: 400 });
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
      message: 'Email tidak valid'
    }, { status: 400 });
  }

  if (
    password !== undefined &&
    password !== '' &&
    (typeof password !== 'string' || password.length < 6)
  ) {
    return Response.json({
      status: false,
      message: 'Password minimal 6 karakter'
    }, { status: 400 });
  }

  if (
    status !== undefined &&
    !['Aktif', 'Nonaktif'].includes(status)
  ) {
    return Response.json({
      status: false,
      message: 'Status tidak valid'
    }, { status: 400 });
  }

  try {
    const [users] = await db.execute<User[]>(
      `SELECT id, nama, email, status
       FROM users WHERE id = ?`,
      [id]
    );

    if (users.length === 0) {
      return Response.json({
        status: false,
        message: 'User tidak ditemukan'
      }, { status: 404 });
    }

    const [existing] = await db.execute<RowDataPacket[]>(
      'SELECT id FROM users WHERE email = ? AND id != ?',
      [email.trim(), id]
    );

    if (existing.length > 0) {
      return Response.json({
        status: false,
        message: 'Email sudah digunakan user lain'
      }, { status: 409 });
    }

    const userStatus = status ?? users[0].status;

    if (password && password.length > 0) {
      const hashedPassword = await bcrypt.hash(password, 10);

      await db.execute<ResultSetHeader>(
        `UPDATE users
         SET nama = ?, email = ?, password = ?, status = ?
         WHERE id = ?`,
        [
          nama.trim(),
          email.trim(),
          hashedPassword,
          userStatus,
          id
        ]
      );
    } else {
      await db.execute<ResultSetHeader>(
        `UPDATE users
         SET nama = ?, email = ?, status = ?
         WHERE id = ?`,
        [
          nama.trim(),
          email.trim(),
          userStatus,
          id
        ]
      );
    }

    return Response.json({
      status: true,
      message: 'Data user berhasil diupdate',
      data: {
        id: Number(id),
        nama: nama.trim(),
        email: email.trim(),
        status: userStatus
      }
    });

  } catch (error) {
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

    return errorServer(error);
  }
}

// ======================================
// DELETE USER
// ======================================
export async function DELETE(
  request: Request,
  context: Context
) {
  if (!verifyToken(request)) return unauthorized();

  const { id } = await context.params;

  if (!validId(id)) {
    return Response.json({
      status: false,
      message: 'ID tidak valid'
    }, { status: 400 });
  }

  // Khusus latihan dengan data dummy.
  if (process.env.NODE_ENV !== 'development') {
    return Response.json({
      status: false,
      message: 'Pengelolaan user belum tersedia untuk produksi'
    }, { status: 403 });
  }

  try {
    const [result] = await db.execute<ResultSetHeader>(
      'DELETE FROM users WHERE id = ?',
      [id]
    );

    if (result.affectedRows === 0) {
      return Response.json({
        status: false,
        message: 'User tidak ditemukan'
      }, { status: 404 });
    }

    return Response.json({
      status: true,
      message: 'User berhasil dihapus'
    });

  } catch (error) {
    return errorServer(error);
  }
}
