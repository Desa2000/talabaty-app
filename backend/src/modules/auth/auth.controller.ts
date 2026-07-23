import { Request, Response } from 'express';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import crypto from 'crypto';
import { z } from 'zod';
import { prisma } from '../../utils/prisma';
import { config } from '../../config';
import { AuthenticatedRequest } from '../../middleware/auth.middleware';

// JWT Helper functions
const generateAccessToken = (user: { id: string; role: string; email: string | null; phone: string; tokenVersion: number }) => {
  return jwt.sign(
    { sub: user.id, role: user.role, email: user.email, phone: user.phone, tokenVersion: user.tokenVersion },
    config.jwtAccessSecret,
    { expiresIn: config.jwtAccessExpiresIn as any }
  );
};

const generateRefreshToken = (userId: string, tokenVersion: number) => {
  return jwt.sign(
    { sub: userId, v: tokenVersion },
    config.jwtRefreshSecret,
    { expiresIn: config.jwtRefreshExpiresIn as any }
  );
};

const hashToken = (token: string): string => {
  return crypto.createHash('sha256').update(token).digest('hex');
};

// Validation schemas
const registerCustomerSchema = z.object({
  name: z.string().min(2),
  phone: z.string().min(6),
  email: z.string().email().optional().or(z.literal('')),
  password: z.string().min(6),
});

const registerMerchantSchema = z.object({
  name: z.string().min(2),
  phone: z.string().min(6),
  email: z.string().email().optional().or(z.literal('')),
  password: z.string().min(6),
  businessName: z.string().min(2),
  businessDescription: z.string().optional(),
  businessArea: z.string().optional(),
  storeName: z.string().min(2),
  storeCategory: z.enum(['RESTAURANT', 'SUPERMARKET', 'PHARMACY']),
  storeAddress: z.string().optional(),
  latitude: z.number().optional().default(15.5007),
  longitude: z.number().optional().default(32.5599),
});

const registerCourierSchema = z.object({
  name: z.string().min(2),
  phone: z.string().min(6),
  email: z.string().email().optional().or(z.literal('')),
  password: z.string().min(6),
  vehicleType: z.enum(['BICYCLE', 'ELECTRIC_BICYCLE', 'MOTORCYCLE']),
  idNumber: z.string().min(2),
  licenseNumber: z.string().optional().or(z.literal('')),
});

const loginSchema = z.object({
  identifier: z.string().min(3),
  password: z.string().min(4),
});

const changePasswordSchema = z.object({
  currentPassword: z.string().min(4),
  newPassword: z.string().min(8),
});

export const registerCustomer = async (req: Request, res: Response) => {
  try {
    const validated = registerCustomerSchema.parse(req.body);
    const emailVal = validated.email && validated.email !== '' ? validated.email : null;

    const existing = await prisma.user.findFirst({
      where: {
        OR: [
          { phone: validated.phone },
          ...(emailVal ? [{ email: emailVal }] : []),
        ],
      },
    });

    if (existing) {
      return res.status(400).json({ error: 'رقم الهاتف أو البريد الإلكتروني مسجل بالفعل' });
    }

    const passwordHash = await bcrypt.hash(validated.password, 12);

    const user = await prisma.user.create({
      data: {
        name: validated.name,
        phone: validated.phone,
        email: emailVal,
        passwordHash,
        role: 'CUSTOMER',
        isVerified: true,
        customerProfile: { create: {} },
      },
    });

    const accessToken = generateAccessToken(user);
    const refreshToken = generateRefreshToken(user.id, user.tokenVersion);
    const tokenHash = hashToken(refreshToken);

    const refreshExpiry = new Date();
    refreshExpiry.setDate(refreshExpiry.getDate() + 30);
    await prisma.refreshToken.create({
      data: {
        userId: user.id,
        tokenHash,
        expiresAt: refreshExpiry,
      },
    });

    return res.status(201).json({
      user: { id: user.id, name: user.name, phone: user.phone, email: user.email, role: user.role },
      accessToken,
      refreshToken,
    });
  } catch (error: any) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: 'البيانات المدخلة غير صالحة', details: error.errors });
    }
    return res.status(500).json({ error: error.message || 'حدث خطأ أثناء التسجيل' });
  }
};

export const registerMerchant = async (req: Request, res: Response) => {
  try {
    const validated = registerMerchantSchema.parse(req.body);
    const emailVal = validated.email && validated.email !== '' ? validated.email : null;

    const existing = await prisma.user.findFirst({
      where: {
        OR: [
          { phone: validated.phone },
          ...(emailVal ? [{ email: emailVal }] : []),
        ],
      },
    });

    if (existing) {
      return res.status(400).json({ error: 'رقم الهاتف أو البريد الإلكتروني مسجل بالفعل' });
    }

    const passwordHash = await bcrypt.hash(validated.password, 12);

    const user = await prisma.user.create({
      data: {
        name: validated.name,
        phone: validated.phone,
        email: emailVal,
        passwordHash,
        role: 'MERCHANT',
        isVerified: true,
        merchantProfile: {
          create: {
            businessName: validated.businessName,
            businessDescription: validated.businessDescription,
            businessArea: validated.businessArea,
            stores: {
              create: {
                name: validated.storeName,
                category: validated.storeCategory,
                description: validated.businessDescription,
                address: validated.storeAddress,
                latitude: validated.latitude,
                longitude: validated.longitude,
              },
            },
          },
        },
      },
    });

    const accessToken = generateAccessToken(user);
    const refreshToken = generateRefreshToken(user.id, user.tokenVersion);
    const tokenHash = hashToken(refreshToken);

    const refreshExpiry = new Date();
    refreshExpiry.setDate(refreshExpiry.getDate() + 30);
    await prisma.refreshToken.create({
      data: {
        userId: user.id,
        tokenHash,
        expiresAt: refreshExpiry,
      },
    });

    return res.status(201).json({
      user: { id: user.id, name: user.name, phone: user.phone, email: user.email, role: user.role },
      accessToken,
      refreshToken,
    });
  } catch (error: any) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: 'البيانات المدخلة غير صالحة', details: error.errors });
    }
    return res.status(500).json({ error: error.message || 'حدث خطأ أثناء التسجيل' });
  }
};

export const registerCourier = async (req: Request, res: Response) => {
  try {
    const validated = registerCourierSchema.parse(req.body);
    const emailVal = validated.email && validated.email !== '' ? validated.email : null;

    const existing = await prisma.user.findFirst({
      where: {
        OR: [
          { phone: validated.phone },
          ...(emailVal ? [{ email: emailVal }] : []),
        ],
      },
    });

    if (existing) {
      return res.status(400).json({ error: 'رقم الهاتف أو البريد الإلكتروني مسجل بالفعل' });
    }

    const passwordHash = await bcrypt.hash(validated.password, 12);

    const user = await prisma.user.create({
      data: {
        name: validated.name,
        phone: validated.phone,
        email: emailVal,
        passwordHash,
        role: 'COURIER',
        isVerified: true,
        courierProfile: {
          create: {
            vehicleType: validated.vehicleType,
            idNumber: validated.idNumber,
            licenseNumber: validated.licenseNumber && validated.licenseNumber !== '' ? validated.licenseNumber : null,
          },
        },
      },
    });

    const accessToken = generateAccessToken(user);
    const refreshToken = generateRefreshToken(user.id, user.tokenVersion);
    const tokenHash = hashToken(refreshToken);

    const refreshExpiry = new Date();
    refreshExpiry.setDate(refreshExpiry.getDate() + 30);
    await prisma.refreshToken.create({
      data: {
        userId: user.id,
        tokenHash,
        expiresAt: refreshExpiry,
      },
    });

    return res.status(201).json({
      user: { id: user.id, name: user.name, phone: user.phone, email: user.email, role: user.role },
      accessToken,
      refreshToken,
    });
  } catch (error: any) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: 'البيانات المدخلة غير صالحة', details: error.errors });
    }
    return res.status(500).json({ error: error.message || 'حدث خطأ أثناء التسجيل' });
  }
};

export const login = async (req: Request, res: Response) => {
  try {
    const validated = loginSchema.parse(req.body);

    const user = await prisma.user.findFirst({
      where: {
        OR: [
          { phone: validated.identifier },
          { email: validated.identifier },
        ],
      },
    });

    // Generic error message for timing & enumeration resistance
    const invalidCredsMsg = 'بيانات الدخول غير صحيحة';

    if (!user) {
      return res.status(401).json({ error: invalidCredsMsg });
    }

    // Check account lockout
    if (user.lockoutUntil && user.lockoutUntil > new Date()) {
      const remainingMinutes = Math.ceil((user.lockoutUntil.getTime() - Date.now()) / 60000);
      return res.status(429).json({
        error: `الحساب مقفل مؤقتاً لعدة محاولات فاشلة. يرجى المحاولة بعد ${remainingMinutes} دقيقة`,
      });
    }

    if (!user.isActive) {
      return res.status(403).json({ error: 'هذا الحساب معطل حالياً' });
    }

    const isMatch = await bcrypt.compare(validated.password, user.passwordHash);
    if (!isMatch) {
      const failedCount = user.failedLoginAttempts + 1;
      const lockoutData: any = { failedLoginAttempts: failedCount };

      if (failedCount >= 5) {
        const lockoutTime = new Date();
        lockoutTime.setMinutes(lockoutTime.getMinutes() + 15); // 15-minute temporary lockout
        lockoutData.lockoutUntil = lockoutTime;
      }

      await prisma.user.update({
        where: { id: user.id },
        data: lockoutData,
      });

      return res.status(401).json({ error: invalidCredsMsg });
    }

    // On successful login, reset failed attempts & lockout
    if (user.failedLoginAttempts > 0 || user.lockoutUntil !== null) {
      await prisma.user.update({
        where: { id: user.id },
        data: { failedLoginAttempts: 0, lockoutUntil: null },
      });
    }

    const accessToken = generateAccessToken(user);
    const refreshToken = generateRefreshToken(user.id, user.tokenVersion);
    const tokenHash = hashToken(refreshToken);

    const refreshExpiry = new Date();
    refreshExpiry.setDate(refreshExpiry.getDate() + 30);
    await prisma.refreshToken.create({
      data: {
        userId: user.id,
        tokenHash,
        expiresAt: refreshExpiry,
      },
    });

    return res.json({
      user: {
        id: user.id,
        name: user.name,
        phone: user.phone,
        email: user.email,
        role: user.role,
        forcePasswordChange: user.forcePasswordChange,
      },
      accessToken,
      refreshToken,
      requirePasswordChange: user.forcePasswordChange,
    });
  } catch (error: any) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: 'البيانات المدخلة غير صالحة', details: error.errors });
    }
    return res.status(500).json({ error: error.message || 'حدث خطأ أثناء تسجيل الدخول' });
  }
};

// CHANGE PASSWORD & REVOKE ALL SESSIONS
export const changePassword = async (req: Request, res: Response) => {
  try {
    const userId = (req as AuthenticatedRequest).user?.id!;
    const validated = changePasswordSchema.parse(req.body);

    const user = await prisma.user.findUnique({ where: { id: userId } });
    if (!user) {
      return res.status(404).json({ error: 'المستخدم غير موجود' });
    }

    const isMatch = await bcrypt.compare(validated.currentPassword, user.passwordHash);
    if (!isMatch) {
      return res.status(400).json({ error: 'كلمة المرور الحالية غير صحيحة' });
    }

    const newPasswordHash = await bcrypt.hash(validated.newPassword, 12);
    const newVersion = user.tokenVersion + 1;

    // Update password, reset forcePasswordChange, increment tokenVersion (invalidates all active JWT tokens)
    await prisma.user.update({
      where: { id: userId },
      data: {
        passwordHash: newPasswordHash,
        tokenVersion: newVersion,
        forcePasswordChange: false,
        passwordChangedAt: new Date(),
      },
    });

    // Revoke all refresh tokens for this user in DB
    await prisma.refreshToken.updateMany({
      where: { userId },
      data: { revoked: true },
    });

    // Generate new fresh token for current session
    const updatedUser = { ...user, tokenVersion: newVersion };
    const newAccessToken = generateAccessToken(updatedUser);
    const newRefreshToken = generateRefreshToken(userId, newVersion);
    const tokenHash = hashToken(newRefreshToken);

    const refreshExpiry = new Date();
    refreshExpiry.setDate(refreshExpiry.getDate() + 30);
    await prisma.refreshToken.create({
      data: {
        userId,
        tokenHash,
        expiresAt: refreshExpiry,
      },
    });

    return res.json({
      message: 'تم تغيير كلمة المرور وإلغاء كافة الجلسات الأخرى بنجاح',
      accessToken: newAccessToken,
      refreshToken: newRefreshToken,
    });
  } catch (error: any) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: 'كلمة المرور الجديدة يجب أن تكون 8 أحرف على الأقل', details: error.errors });
    }
    return res.status(500).json({ error: error.message || 'فشل تغيير كلمة المرور' });
  }
};

export const refresh = async (req: Request, res: Response) => {
  const { refreshToken } = req.body;
  if (!refreshToken) {
    return res.status(400).json({ error: 'Refresh token required' });
  }

  try {
    const decoded = jwt.verify(refreshToken, config.jwtRefreshSecret) as { sub: string; v?: number };
    const tokenHash = hashToken(refreshToken);

    const dbToken = await prisma.refreshToken.findUnique({
      where: { tokenHash },
    });

    if (!dbToken || dbToken.revoked || dbToken.expiresAt < new Date()) {
      return res.status(401).json({ error: 'Refresh token invalid or expired' });
    }

    const user = await prisma.user.findUnique({
      where: { id: decoded.sub },
    });

    if (!user || !user.isActive || (decoded.v !== undefined && decoded.v !== user.tokenVersion)) {
      return res.status(401).json({ error: 'User session has been revoked' });
    }

    const newAccessToken = generateAccessToken(user);

    return res.json({
      accessToken: newAccessToken,
    });
  } catch (error: any) {
    return res.status(401).json({ error: 'Refresh token invalid' });
  }
};

export const logout = async (req: Request, res: Response) => {
  const { refreshToken } = req.body;
  if (!refreshToken) {
    return res.status(400).json({ error: 'Refresh token required' });
  }

  try {
    const tokenHash = hashToken(refreshToken);

    await prisma.refreshToken.updateMany({
      where: { tokenHash },
      data: { revoked: true },
    });

    return res.json({ message: 'Logged out successfully' });
  } catch (error: any) {
    return res.status(500).json({ error: 'Logout failed' });
  }
};

export const getMe = async (req: Request, res: Response) => {
  try {
    const userId = (req as any).user?.id;
    if (!userId) {
      return res.status(401).json({ error: 'Unauthorized' });
    }

    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        name: true,
        phone: true,
        email: true,
        role: true,
        isVerified: true,
        isActive: true,
        forcePasswordChange: true,
        firstTimeSetupCompleted: true,
        createdAt: true,
      },
    });

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    return res.json(user);
  } catch (error: any) {
    return res.status(500).json({ error: 'Failed to retrieve profile' });
  }
};

export const verifySetupToken = async (req: Request, res: Response) => {
  try {
    const token = req.query.token as string;
    if (!token) {
      return res.status(400).json({ valid: false, error: 'رابط التفعيل غير صالح أو ناقص' });
    }

    const tokenHash = crypto.createHash('sha256').update(token).digest('hex');
    const user = await prisma.user.findFirst({
      where: {
        activationTokenHash: tokenHash,
        firstTimeSetupCompleted: false,
      },
    });

    if (!user) {
      return res.status(400).json({ valid: false, error: 'رابط التفعيل غير صالح أو تم استخدامه سابقاً' });
    }

    if (!user.activationTokenExpiresAt || user.activationTokenExpiresAt < new Date()) {
      return res.status(400).json({ valid: false, error: 'انتهت صلاحية رابط التفعيل. يرجى توليد رابط جديد' });
    }

    return res.json({
      valid: true,
      email: user.email || 'superadmin@talabaty.com',
      name: user.name,
    });
  } catch (error: any) {
    return res.status(500).json({ valid: false, error: 'فشل التحقق من رابط التفعيل' });
  }
};

export const completeFirstTimeSetup = async (req: Request, res: Response) => {
  try {
    const { token, newPassword } = req.body;
    if (!token || !newPassword) {
      return res.status(400).json({ error: 'جميع البيانات مطلوبة' });
    }

    const tokenHash = crypto.createHash('sha256').update(token).digest('hex');
    const user = await prisma.user.findFirst({
      where: {
        activationTokenHash: tokenHash,
        firstTimeSetupCompleted: false,
      },
    });

    if (!user) {
      return res.status(400).json({ error: 'رابط التفعيل غير صالح أو تم استخدامه من قبل' });
    }

    if (!user.activationTokenExpiresAt || user.activationTokenExpiresAt < new Date()) {
      return res.status(400).json({ error: 'انتهت صلاحية رابط التفعيل، يرجى طلب رابط جديد' });
    }

    // Password requirements: Min 12 chars, upper, lower, digit, special char
    if (newPassword.length < 12) {
      return res.status(400).json({ error: 'يجب ألا تقل كلمة المرور عن 12 حرفاً' });
    }
    if (!/[A-Z]/.test(newPassword)) {
      return res.status(400).json({ error: 'يجب أن تحتوي كلمة المرور على حرف كبير واحد على الأقل (A-Z)' });
    }
    if (!/[a-z]/.test(newPassword)) {
      return res.status(400).json({ error: 'يجب أن تحتوي كلمة المرور على حرف صغير واحد على الأقل (a-z)' });
    }
    if (!/[0-9]/.test(newPassword)) {
      return res.status(400).json({ error: 'يجب أن تحتوي كلمة المرور على رقم واحد على الأقل (0-9)' });
    }
    if (!/[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]/.test(newPassword)) {
      return res.status(400).json({ error: 'يجب أن تحتوي كلمة المرور على رمز خاص واحد على الأقل' });
    }

    const passwordHash = await bcrypt.hash(newPassword, 12);
    const newVersion = user.tokenVersion + 1;

    const updatedUser = await prisma.user.update({
      where: { id: user.id },
      data: {
        passwordHash,
        firstTimeSetupCompleted: true,
        activationTokenHash: null,
        activationTokenExpiresAt: null,
        tokenVersion: newVersion,
        forcePasswordChange: false,
        failedLoginAttempts: 0,
        lockoutUntil: null,
        passwordChangedAt: new Date(),
      },
    });

    // Revoke all existing refresh tokens
    await prisma.refreshToken.updateMany({
      where: { userId: user.id },
      data: { revoked: true },
    });

    const accessToken = generateAccessToken({
      id: updatedUser.id,
      role: updatedUser.role,
      email: updatedUser.email,
      phone: updatedUser.phone,
      tokenVersion: newVersion,
    });

    const refreshToken = generateRefreshToken(updatedUser.id, newVersion);
    const expiresAt = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000);

    await prisma.refreshToken.create({
      data: {
        userId: updatedUser.id,
        tokenHash: hashToken(refreshToken),
        expiresAt,
      },
    });

    return res.json({
      message: 'تم إنشاء كلمة المرور وإكمال إعداد الحساب بنجاح! 🚀',
      token: accessToken,
      refreshToken,
      user: {
        id: updatedUser.id,
        name: updatedUser.name,
        email: updatedUser.email,
        phone: updatedUser.phone,
        role: updatedUser.role,
        firstTimeSetupCompleted: true,
      },
    });
  } catch (error: any) {
    return res.status(500).json({ error: 'فشل تفعيل كلمة المرور' });
  }
};
