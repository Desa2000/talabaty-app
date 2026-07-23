import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { config } from '../config';
import { prisma } from '../utils/prisma';

export interface AuthenticatedRequest extends Request {
  user?: {
    id: string;
    role: string;
    email: string | null;
    phone: string;
    tokenVersion: number;
  };
}

export const authenticate = async (req: Request, res: Response, next: NextFunction) => {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'منتهي الصلاحية أو غير مصرح به، يرجى تسجيل الدخول' });
  }

  const token = authHeader.split(' ')[1];
  try {
    const decoded = jwt.verify(token, config.jwtAccessSecret) as {
      sub: string;
      role: string;
      email: string | null;
      phone: string;
      tokenVersion?: number;
    };

    // Verify tokenVersion against DB to enforce immediate session revocation on password change
    const dbUser = await prisma.user.findUnique({
      where: { id: decoded.sub },
      select: { id: true, role: true, email: true, phone: true, isActive: true, tokenVersion: true },
    });

    if (!dbUser || !dbUser.isActive) {
      return res.status(401).json({ error: 'الحساب غير متاح أو معطل' });
    }

    if (decoded.tokenVersion !== undefined && decoded.tokenVersion !== dbUser.tokenVersion) {
      return res.status(401).json({ error: 'تم تغيير كلمة المرور وإلغاء هذه الجلسة، يرجى تسجيل الدخول مجدداً' });
    }

    (req as AuthenticatedRequest).user = {
      id: dbUser.id,
      role: dbUser.role,
      email: dbUser.email,
      phone: dbUser.phone,
      tokenVersion: dbUser.tokenVersion,
    };
    return next();
  } catch (error) {
    return res.status(401).json({ error: 'جلسة العمل غير صالحة أو منتهية، يرجى تسجيل الدخول مرة أخرى' });
  }
};

export const authorizeRoles = (...roles: string[]) => {
  return (req: Request, res: Response, next: NextFunction) => {
    const user = (req as AuthenticatedRequest).user;
    if (!user || !roles.includes(user.role)) {
      return res.status(403).json({ error: '403 Forbidden: ليس لديك صلاحية للقيام بهذا الإجراء' });
    }
    return next();
  };
};

export const isAdminRole = (role?: string): boolean => {
  if (!role) return false;
  return ['SUPER_ADMIN', 'ADMIN', 'OPERATIONS', 'FINANCE', 'SUPPORT'].includes(role);
};
