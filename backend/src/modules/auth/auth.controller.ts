import { Request, Response } from 'express';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import crypto from 'crypto';
import { z } from 'zod';
import { prisma } from '../../utils/prisma';
import { config } from '../../config';

// JWT Helper functions
const generateAccessToken = (user: { id: string; role: string; email: string | null; phone: string }) => {
  return jwt.sign(
    { sub: user.id, role: user.role, email: user.email, phone: user.phone },
    config.jwtAccessSecret,
    { expiresIn: config.jwtAccessExpiresIn as any }
  );
};

const generateRefreshToken = (userId: string) => {
  return jwt.sign(
    { sub: userId },
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
  password: z.string().min(4),
});

const registerMerchantSchema = z.object({
  name: z.string().min(2),
  phone: z.string().min(6),
  email: z.string().email().optional().or(z.literal('')),
  password: z.string().min(4),
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
  password: z.string().min(4),
  vehicleType: z.enum(['BICYCLE', 'ELECTRIC_BICYCLE', 'MOTORCYCLE']),
  idNumber: z.string().min(2),
  licenseNumber: z.string().optional().or(z.literal('')),
});

const loginSchema = z.object({
  identifier: z.string().min(3), // phone or email
  password: z.string().min(4),
});

export const registerCustomer = async (req: Request, res: Response) => {
  try {
    const validated = registerCustomerSchema.parse(req.body);
    const emailVal = validated.email && validated.email !== '' ? validated.email : null;

    // Check duplicates
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

    const passwordHash = await bcrypt.hash(validated.password, 10);

    const user = await prisma.user.create({
      data: {
        name: validated.name,
        phone: validated.phone,
        email: emailVal,
        passwordHash,
        role: 'CUSTOMER',
        isVerified: true,
        customerProfile: {
          create: {},
        },
      },
    });

    const accessToken = generateAccessToken(user);
    const refreshToken = generateRefreshToken(user.id);
    const tokenHash = hashToken(refreshToken);

    // Save refresh token
    const refreshExpiry = new Date();
    refreshExpiry.setDate(refreshExpiry.getDate() + 30); // 30 days
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

    // Check duplicates
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

    const passwordHash = await bcrypt.hash(validated.password, 10);

    // Create user, profile and store atomically
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
      include: {
        merchantProfile: {
          include: {
            stores: true,
          },
        },
      },
    });

    const accessToken = generateAccessToken(user);
    const refreshToken = generateRefreshToken(user.id);
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

    // Check duplicates
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

    const passwordHash = await bcrypt.hash(validated.password, 10);

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
    const refreshToken = generateRefreshToken(user.id);
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

    if (!user) {
      return res.status(401).json({ error: 'رقم الهاتف/البريد الإلكتروني أو كلمة المرور غير صحيحة' });
    }

    const isMatch = await bcrypt.compare(validated.password, user.passwordHash);
    if (!isMatch) {
      return res.status(401).json({ error: 'رقم الهاتف/البريد الإلكتروني أو كلمة المرور غير صحيحة' });
    }

    if (!user.isActive) {
      return res.status(403).json({ error: 'هذا الحساب معطل حالياً' });
    }

    const accessToken = generateAccessToken(user);
    const refreshToken = generateRefreshToken(user.id);
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
      user: { id: user.id, name: user.name, phone: user.phone, email: user.email, role: user.role },
      accessToken,
      refreshToken,
    });
  } catch (error: any) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: 'البيانات المدخلة غير صالحة', details: error.errors });
    }
    return res.status(500).json({ error: error.message || 'حدث خطأ أثناء تسجيل الدخول' });
  }
};

export const refresh = async (req: Request, res: Response) => {
  const { refreshToken } = req.body;
  if (!refreshToken) {
    return res.status(400).json({ error: 'Refresh token required' });
  }

  try {
    // Decode and verify refresh token
    const decoded = jwt.verify(refreshToken, config.jwtRefreshSecret) as { sub: string };
    const tokenHash = hashToken(refreshToken);

    // Look up refresh token in database
    const dbToken = await prisma.refreshToken.findUnique({
      where: { tokenHash },
    });

    if (!dbToken || dbToken.revoked || dbToken.expiresAt < new Date()) {
      return res.status(401).json({ error: 'Refresh token invalid or expired' });
    }

    // Retrieve user
    const user = await prisma.user.findUnique({
      where: { id: decoded.sub },
    });

    if (!user || !user.isActive) {
      return res.status(401).json({ error: 'User is inactive or not found' });
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

    // Revoke token in DB
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
