import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { config } from '../config';

export interface AuthenticatedRequest extends Request {
  user?: {
    id: string;
    role: string;
    email: string | null;
    phone: string;
  };
}

export const authenticate = (req: Request, res: Response, next: NextFunction) => {
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
    };

    (req as AuthenticatedRequest).user = {
      id: decoded.sub,
      role: decoded.role,
      email: decoded.email,
      phone: decoded.phone,
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
      return res.status(403).json({ error: 'ليس لديك صلاحية للقيام بهذا الإجراء' });
    }
    return next();
  };
};
