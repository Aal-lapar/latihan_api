
import db from '@/lib/db';
import { verifyToken, unauthorized } from '@/lib/auth';
import type { RowDataPacket, ResultSetHeader } from 'mysql2';

export const runtime = 'nodejs';

// CORS UNTUK FLUTTER WEB (LOCAL DEVELOPMENT)
function corsHeaders(request: Request): HeadersInit {
  const origin = request.headers.get('origin') ?? '';

  const allowedOrigin =
    /^http:\/\/(localhost|127\.0\.0\.1):\d+$/.test(origin)
      ? origin
      : '';

  return {
    ...(allowedOrigin
      ? { 'Access-Control-Allow-Origin': allowedOrigin }
      : {}),
    'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
    'Access-Control-Allow-Headers':
      'Content-Type, Authorization',
    'Vary': 'Origin',
  };
}

// MENAMBAHKAN HEADER CORS KE RESPONSE
function withCors(response: Response, request: Request) {
  const headers = new Headers(response.headers);

  Object.entries(corsHeaders(request)).forEach(
    ([key, value]) => {
      if (typeof value === 'string') {
        headers.set(key, value);
      }
    }
  );

  return new Response(response.body, {
    status: response.status,
    headers,
  });
}

// MENANGANI PREFLIGHT REQUEST DARI BROWSER
export async function OPTIONS(request: Request) {
  return new Response(null, {
    status: 204,
    headers: corsHeaders(request),
  });
}

const fields = [
  'nipd',
  'nama',
  'jenis_kelamin',
  'alamat',
  'kelas',
  'jurusan'
] as const;

type SiswaInput = Record<(typeof fields)[number], string>;

function validasi(body: unknown): body is SiswaInput {
  if (!body || typeof body !== 'object') {
    return false;
  }

  const data = body as Record<string, unknown>;

  return fields.every(
    (field) =>
      typeof data[field] === 'string' &&
      (data[field] as string).trim().length > 0
  );
}

// GET SEMUA SISWA
export async function GET(request: Request) {
  if (!verifyToken(request)) {
    return withCors(unauthorized(), request);
  }

  try {
    const [rows] = await db.query<RowDataPacket[]>(
      'SELECT * FROM siswa ORDER BY id DESC'
    );

    return withCors(
      Response.json({
        status: true,
        message: 'Data siswa berhasil diambil',
        data: rows
      }),
      request
    );

  } catch (error) {
    console.error('GET SISWA:', error);

    return withCors(
      Response.json(
        {
          status: false,
          message: 'Gagal mengambil data siswa'
        },
        { status: 500 }
      ),
      request
    );
  }
}

// POST TAMBAH SISWA
export async function POST(request: Request) {
  if (!verifyToken(request)) {
    return withCors(unauthorized(), request);
  }

  const body = await request.json().catch(() => null);

  if (!validasi(body)) {
    return withCors(
      Response.json(
        {
          status: false,
          message: 'Semua data siswa wajib diisi'
        },
        { status: 400 }
      ),
      request
    );
  }

  const {
    nipd,
    nama,
    jenis_kelamin,
    alamat,
    kelas,
    jurusan
  } = body;

  try {
    const [result] = await db.execute<ResultSetHeader>(
      `INSERT INTO siswa
       (nipd, nama, jenis_kelamin, alamat, kelas, jurusan)
       VALUES (?, ?, ?, ?, ?, ?)`,
      [
        nipd.trim(),
        nama.trim(),
        jenis_kelamin.trim(),
        alamat.trim(),
        kelas.trim(),
        jurusan.trim()
      ]
    );

    return withCors(
      Response.json(
        {
          status: true,
          message: 'Data siswa berhasil ditambahkan',
          data: {
            id: result.insertId,
            nipd,
            nama,
            jenis_kelamin,
            alamat,
            kelas,
            jurusan
          }
        },
        { status: 201 }
      ),
      request
    );

  } catch (error) {
    console.error('POST SISWA:', error);

    if (
      error instanceof Error &&
      'code' in error &&
      error.code === 'ER_DUP_ENTRY'
    ) {
      return withCors(
        Response.json(
          {
            status: false,
            message: 'NIPD sudah digunakan'
          },
          { status: 409 }
        ),
        request
      );
    }

    return withCors(
      Response.json(
        {
          status: false,
          message: 'Gagal menambahkan siswa'
        },
        { status: 500 }
      ),
      request
    );
  }
}
