
import db from '@/lib/db';
import { verifyToken, unauthorized } from '@/lib/auth';
import type { RowDataPacket, ResultSetHeader } from 'mysql2';

export const runtime = 'nodejs';

type Context = {
  params: Promise<{ id: string }>;
};

const fields = [
  'nipd', 'nama', 'jenis_kelamin',
  'alamat', 'kelas', 'jurusan'
] as const;

type SiswaInput = Record<(typeof fields)[number], string>;

function validasi(body: unknown): body is SiswaInput {
  if (!body || typeof body !== 'object') return false;

  const data = body as Record<string, unknown>;

  return fields.every(
    field =>
      typeof data[field] === 'string' &&
      (data[field] as string).trim().length > 0
  );
}

function validId(id: string) {
  return /^[1-9]\d*$/.test(id);
}

function errorId() {
  return Response.json(
    { status: false, message: 'ID tidak valid' },
    { status: 400 }
  );
}

function errorServer(error: unknown) {
  console.error('SISWA BY ID:', error);

  return Response.json(
    {
      status: false,
      message: 'Terjadi kesalahan pada server'
    },
    { status: 500 }
  );
}

// GET SISWA BERDASARKAN ID
export async function GET(request: Request, context: Context) {
  if (!verifyToken(request)) return unauthorized();

  const { id } = await context.params;

  if (!validId(id)) return errorId();

  try {
    const [rows] = await db.execute<RowDataPacket[]>(
      'SELECT * FROM siswa WHERE id = ?',
      [id]
    );

    if (rows.length === 0) {
      return Response.json(
        {
          status: false,
          message: 'Siswa tidak ditemukan'
        },
        { status: 404 }
      );
    }

    return Response.json({
      status: true,
      message: 'Data siswa berhasil diambil',
      data: rows[0]
    });

  } catch (error) {
    return errorServer(error);
  }
}

// PUT EDIT SISWA
export async function PUT(request: Request, context: Context) {
  if (!verifyToken(request)) return unauthorized();

  const { id } = await context.params;

  if (!validId(id)) return errorId();

  const body = await request.json().catch(() => null);

  if (!validasi(body)) {
    return Response.json(
      {
        status: false,
        message: 'Semua data siswa wajib diisi'
      },
      { status: 400 }
    );
  }

  const {
    nipd, nama, jenis_kelamin,
    alamat, kelas, jurusan
  } = body;

  try {
    const [result] = await db.execute<ResultSetHeader>(
      `UPDATE siswa
       SET nipd = ?,
           nama = ?,
           jenis_kelamin = ?,
           alamat = ?,
           kelas = ?,
           jurusan = ?
       WHERE id = ?`,
      [
        nipd.trim(),
        nama.trim(),
        jenis_kelamin.trim(),
        alamat.trim(),
        kelas.trim(),
        jurusan.trim(),
        id
      ]
    );

    if (result.affectedRows === 0) {
      return Response.json(
        {
          status: false,
          message: 'Siswa tidak ditemukan'
        },
        { status: 404 }
      );
    }

    return Response.json({
      status: true,
      message: 'Data siswa berhasil diupdate'
    });

  } catch (error) {
    console.error('PUT SISWA:', error);

    if (
      error instanceof Error &&
      'code' in error &&
      error.code === 'ER_DUP_ENTRY'
    ) {
      return Response.json(
        {
          status: false,
          message: 'NIPD sudah digunakan siswa lain'
        },
        { status: 409 }
      );
    }

    return errorServer(error);
  }
}

// DELETE SISWA
export async function DELETE(request: Request, context: Context) {
  if (!verifyToken(request)) return unauthorized();

  const { id } = await context.params;

  if (!validId(id)) return errorId();

  try {
    const [result] = await db.execute<ResultSetHeader>(
      'DELETE FROM siswa WHERE id = ?',
      [id]
    );

    if (result.affectedRows === 0) {
      return Response.json(
        {
          status: false,
          message: 'Siswa tidak ditemukan'
        },
        { status: 404 }
      );
    }

    return Response.json({
      status: true,
      message: 'Data siswa berhasil dihapus'
    });

  } catch (error) {
    return errorServer(error);
  }
}