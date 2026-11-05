
import jwt, { JwtPayload } from 'jsonwebtoken';

export function verifyToken(request: Request): JwtPayload | null {
  const header = request.headers.get('authorization');

  if (!header || !header.startsWith('Bearer ')) {
    return null;
  }

  const token = header.slice(7).trim();
  const secret = process.env.JWT_SECRET;

  if (!token || !secret) {
    return null;
  }

  try {
    const decoded = jwt.verify(token, secret);

    if (typeof decoded === 'string') {
      return null;
    }

    return decoded;
  } catch {
    return null;
  }
}

export function unauthorized() {
  return Response.json(
    {
      status: false,
      message: 'Token tidak ada, tidak valid, atau expired'
    },
    { status: 401 }
  );
}
