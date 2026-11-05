
import db from '@/lib/db';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import type { RowDataPacket } from 'mysql2';

export const runtime = 'nodejs';

interface User extends RowDataPacket {
  id: number;
  nama: string;
  email: string;
  password: string;
  status: string;
}

// CORS UNTUK FLUTTER WEB DI LOCALHOST
function getCorsHeaders(request: Request): Headers {
  const headers = new Headers();
  const origin = request.headers.get('origin');

  headers.set('Vary', 'Origin');

  if (
    origin &&
    /^http:\/\/(localhost|127\.0\.0\.1):\d+$/.test(origin)
  ) {
    headers.set('Access-Control-Allow-Origin', origin);
    headers.set('Access-Control-Allow-Methods', 'POST, OPTIONS');
    headers.set('Access-Control-Allow-Headers', 'Content-Type');
  }

  return headers;
}

// RESPONSE JSON DENGAN HEADER CORS
function sendResponse(
  request: Request,
  data: object,
  status: number = 200
) {
  return Response.json(data, {
    status,
    headers: getCorsHeaders(request),
  });
}

// MENANGANI PREFLIGHT REQUEST
export async function OPTIONS(request: Request) {
  const origin = request.headers.get('origin');

  if (
    origin &&
    !/^http:\/\/(localhost|127\.0\.0\.1):\d+$/.test(origin)
  ) {
    return new Response(null, { status: 403 });
  }

  return new Response(null, {
    status: 204,
    headers: getCorsHeaders(request),
  });
}

// API LOGIN
export async function POST(request: Request) {
  try {
    const origin = request.headers.get('origin');

    if (
      origin &&
      !/^http:\/\/(localhost|127\.0\.0\.1):\d+$/.test(origin)
    ) {
      return sendResponse(
        request,
        {
          status: false,
          message: 'Origin tidak diizinkan',
        },
        403
      );
    }

    const body = await request.json().catch(() => null);

    const email = body?.email;
    const password = body?.password;

    // VALIDASI INPUT
    if (
      typeof email !== 'string' ||
      typeof password !== 'string' ||
      !email.trim() ||
      !password
    ) {
      return sendResponse(
        request,
        {
          status: false,
          message: 'Email dan password wajib diisi',
        },
        400
      );
    }

    // AMBIL USER DARI DATABASE
    const [rows] = await db.execute<User[]>(
      'SELECT * FROM users WHERE email = ?',
      [email.trim()]
    );

    if (rows.length === 0) {
      return sendResponse(
        request,
        {
          status: false,
          message: 'Email atau password salah',
        },
        401
      );
    }

    const user = rows[0];

    // VERIFIKASI PASSWORD
    const cocok = await bcrypt.compare(
      password,
      user.password
    );

    if (!cocok) {
      return sendResponse(
        request,
        {
          status: false,
          message: 'Email atau password salah',
        },
        401
      );
    }

    // CEK STATUS AKUN
    if (user.status !== 'Aktif') {
      return sendResponse(
        request,
        {
          status: false,
          message: 'Akun tidak aktif',
        },
        403
      );
    }

    // CEK JWT SECRET
    const secret = process.env.JWT_SECRET;

    if (!secret) {
      throw new Error('JWT_SECRET belum dikonfigurasi');
    }

    // MEMBUAT TOKEN JWT
    const token = jwt.sign(
      {
        id: user.id,
        email: user.email,
      },
      secret,
      {
        expiresIn: '1h',
      }
    );

    // LOGIN BERHASIL
    return sendResponse(request, {
      status: true,
      message: 'Login berhasil',
      data: {
        id: user.id,
        nama: user.nama,
        email: user.email,
        status: user.status,
        token,
      },
    });

  } catch (error) {
    console.error('LOGIN ERROR:', error);

    return sendResponse(
      request,
      {
        status: false,
        message: 'Terjadi kesalahan pada server',
      },
      500
    );
  }
}
